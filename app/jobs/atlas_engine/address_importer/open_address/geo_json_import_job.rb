# typed: true
# frozen_string_literal: true

# The GeoJsonImportJob loads a GeoJSON file into the PostAddress table.
# It is designed to be resumable, according to JobIteration best practices.
# The input file may optionally be gzip-compressed. It's read in chunks of 10_000 rows.
# The ETL process is as follows:
# - Extract: each row is evaluated with JSON.parse. Next, the GeoJSON feature contained
#   is passed to a Filter instance, which may return false to reject the row. The Filter class
#   is specified in country_profile under open_address/filter.
# - Transform: a Transformer instance receives the feature, and returns zero or more hashes
#   that match the PostAddress table/schema. The Transformer class is also specified in
#   country_profile, under open_address/filter.
# - Transform: after the Transformer, addresses are passed to a Corrections::Corrector, which runs one or
#   more dedicated Correctors. These modify the passed address inline, and may clear the address hash to reject it.
#   The Corrector classes are specified in country_profile under ingestion/correctors/open_address.
# - Load: addresses are upserted into the PostAddresses table. When two addresses have the same
#   province + locale + city + street + zip (a conflict on index_post_addresses_on_pc_zp_st_ct_lc),
#   the building_and_unit_ranges field is merged using JSON_MERGE and other fields (like lat, lon) are overwritten.
module AtlasEngine
  module AddressImporter
    module OpenAddress
      class GeoJsonImportJob < AddressImporter::ResumableImportJob
        extend T::Sig
        include HandlesInterruption
        include PreparesGeoJsonFile
        attr_reader :geojson_path, :country_import, :country_code, :loader, :transformer

        CHUNK_SIZE = 10_000
        REPORT_STEP = 5

        around_perform :setup_and_download

        # Setup boilerplate: JobIteration doesn't let us override #perform. Instead
        # the around_perform callback is used for that.
        def setup_and_download(&block)
          @loader = Loader.new
          @country_code = argument(:country_code)
          @geojson_path = Pathname.new(argument(:geojson_file_path))
          @locale = argument(:locale)&.downcase
          @country_import = CountryImport.find(argument(:country_import_id))
          @transformer = Transformer.new(country_import: country_import, locale: @locale)

          import_log_info(
            country_import: country_import,
            message: "Downloading geojson file",
            additional_params: { file_path: geojson_path.to_s },
          )

          download_geojson(&block)
        end

        StringProps = T.type_alias { T::Hash[String, T.untyped] }
        BatchOfRows = T.type_alias { T::Array[StringProps] }

        # Part of JobIteration: returns an Enumerator that yields batches of addresses, and the cursor position.
        # If cursor is present, the enumerator starts at that position. This stage does extraction (parsing JSON)
        # and filtering.
        sig do
          params(
            params: T::Hash[Symbol, T.untyped],
            cursor: T.untyped,
          ).returns(T::Enumerator[[BatchOfRows, Integer]])
        end
        def build_enumerator(params, cursor:)
          start_at = if cursor.nil?
            import_log_info(country_import: country_import, message: "Importing whole file")
            0
          else
            import_log_info(country_import: country_import, message: "Starting import at chunk #{cursor}")
            cursor.to_i
          end

          io.each
            # NOTE: The bigger the chunk size, the less rountrips to MySQL, and therefore faster.
            .each_slice(CHUNK_SIZE)
            .lazy
            .drop(start_at) # Cursor is chunk number. When resuming, skip that many chunks.
            .with_index(start_at) # Include skipped chunks in numbering
            .map do |lines, chunk_num|
              track_progress(chunk_num)
              [lines.map { JSON.parse(_1) }, chunk_num]
            end
            .map do |features, chunk_num|
              [features.select(&row_filter), chunk_num]
            end
        end

        # Part of JobIteration: ran for each batch of rows. This stage does transformation
        # (converting a GeoJSON feature into a hash, then applying correctors) and loading (upserting into PostAddress).
        sig { params(batch: BatchOfRows, element_id: T.untyped).void }
        def each_iteration(batch, element_id)
          exit_if_interrupted!(country_import)

          addresses = attributes_from_batch(batch)
          return if addresses.blank?

          condensed = condense_addresses(addresses)

          loader.load(condensed)
        end

        sig do
          params(addresses: T::Array[T::Hash[Symbol,
            T.untyped]]).returns(T::Array[T.nilable(T::Hash[Symbol, T.untyped])])
        end
        def condense_addresses(addresses)
          addresses
            .group_by { |attrs| [attrs[:province_code], attrs[:locale], attrs[:city], attrs[:street], attrs[:zip]] }
            .map do |(_province_code, _locale, _city, _street, _zip), matched_addresses|
              matched_addresses.reduce do |acc, matched_address|
                acc.merge(matched_address) do |key, oldval, newval|
                  if key == :building_and_unit_ranges
                    oldval.merge(newval)
                  else
                    newval
                  end
                end
              end
            end
        end

        sig { params(batch: BatchOfRows).returns(T::Array[T::Hash[Symbol, T.untyped]]) }
        def attributes_from_batch(batch)
          batch
            .filter_map do |feature|
              attrs = transformer.transform(feature)
              if attrs.nil?
                incr_invalid_lines
                next
              end

              attrs
            end
        end

        sig { params(chunk_num: Integer).void }
        def track_progress(chunk_num)
          return unless chunk_num % REPORT_STEP == 0

          lines_parsed = chunk_num * CHUNK_SIZE
          import_log_info(
            country_import: country_import,
            message: "Processing chunk #{chunk_num}, lines parsed so far: #{lines_parsed}",
          )

          if lines_parsed != invalid_lines
            import_log_info(
              country_import: country_import,
              message: "Lines discarded: #{invalid_lines}",
              category: :invalid_address,
            )
          end
        end

        sig { returns(CountryProfile) }
        def country_profile
          @country_profile ||= CountryProfile.for(country_code)
        end

        FilterType = T.type_alias { T.proc.params(arg0: StringProps).returns(T::Boolean) }
        # Returns a callable that takes a row and returns true if it should be imported
        sig { returns(FilterType) }
        def row_filter
          @row_filter ||= case country_profile.open_address[:filter]
          in nil # Undefined: let everything through
            ->(_row) { true }
          in /\w+(::\w+)+/ => sym # Class name
            cls = sym.constantize
            inst = cls.new(country_import: country_import)
            inst.method(:filter).to_proc
          end
        end

        Corrector = AddressImporter::Corrections::Corrector
        # Returns a Corrector instance, or nil if no correctors are defined for this country.
        sig { returns(T.nilable(Corrector)) }
        def corrector
          @corrector ||= if country_profile.ingestion.correctors(source: "open_address").empty?
            nil
          else
            Corrector.new(
              country_code: country_code,
              source: "open_address",
            )
          end
        end

        # Returns an IO-like object that reads the geojson file.
        # Returns untyped because GzipReader is IO-like, but not a subclass of IO.
        sig { returns(T.untyped) }
        def io
          Zlib::GzipReader.new(geojson_path.open("rb"))
        end

        sig { void }
        def incr_invalid_lines
          if @invalid_lines.nil?
            @invalid_lines = 0
          else
            @invalid_lines += 1
          end
        end

        sig { returns(Integer) }
        def invalid_lines
          @invalid_lines || 0
        end
      end
    end
  end
end
