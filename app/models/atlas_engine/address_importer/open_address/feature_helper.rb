# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      module FeatureHelper
        extend T::Sig
        extend T::Helpers

        sig { params(feature: T::Hash[String, T.untyped]).returns(T.nilable(String)) }
        def openaddress_source_id(feature)
          objid, hash = feature["properties"].values_at("id", "hash")
          if objid.present?
            # OA indicates an OpenAddresses-provided ID
            "OA-#{objid}"
          elsif hash.present?
            # Which may come from a different field, hence the hash sign
            "OA##{hash}"
          else
            # AT signifies an Atlas-calculated hash
            "AT-#{signature(feature)}"
          end
        end

        sig do
          params(number: T.nilable(String), unit: T.nilable(String))
            .returns(T.nilable(T::Hash[T.untyped, T.untyped]))
        end
        def housenumber_and_unit(number, unit)
          return {} if number.blank?

          { number => unit.present? ? { unit => {} } : {} }
        end

        sig { params(feature: Feature).returns(T.nilable([Numeric, Numeric])) }
        def geometry(feature)
          geom = feature["geometry"]
          if geom.present? && geom["type"] == "Point"
            geom["coordinates"]
          end
        end

        sig { params(zip: String).returns(String) }
        def normalize_zip(zip)
          Worldwide::Zip.normalize(
            country_code: @country_code,
            zip: zip,
            strip_extraneous_characters: true,
          )
        end

        sig { params(district: String).returns(T.nilable(String)) }
        def province_code_from_name(district) = zones_mapping[district.downcase]

        sig { params(region: String).returns(T.nilable(String)) }
        def province_from_code(region) = zone_codes.include?(region) ? region : nil

        sig { params(zip: String).returns(T.nilable(String)) }
        def province_code_from_zip(zip)
          @zip_to_province_mapping ||= {}
          unless @zip_to_province_mapping.key?(zip)
            province = Worldwide.region(code: @country_code).zone(zip: zip)
            @zip_to_province_mapping[zip] = province.province? ? province.iso_code : nil
          end
          @zip_to_province_mapping[zip]
        end

        private

        sig { params(feature: T::Hash[String, T.untyped]).returns(String) }
        def signature(feature)
          Digest::MD5.hexdigest(
            feature["properties"].map { "#{_1}=#{_2}" }.join("\n"),
          )
        end

        sig { returns(T::Hash[String, String]) }
        def zones_mapping
          @zones_mapping ||= legacy_zone_names.merge(full_zone_names).merge(name_alternates)
        end

        sig { returns(T::Array[Worldwide::Region]) }
        def zones = @zones ||= Worldwide.region(code: @country_code).zones

        sig { returns(T::Hash[String, String]) }
        def legacy_zone_names
          zones.to_h { |z| [z.legacy_name.downcase, z.legacy_code] }
        end

        sig { returns(T::Hash[String, String]) }
        def full_zone_names
          zones.to_h { |z| [z.full_name.downcase, z.legacy_code] }
        end

        sig { returns(T::Hash[String, String]) }
        def name_alternates
          zones_with_alternates = zones.select { |z| z.name_alternates.present? }
          zones_with_alternates.each_with_object({}) do |zone, hash|
            zone.name_alternates.each { |name| hash[name.downcase] = zone.legacy_code }
          end
        end

        def zone_codes
          @zone_codes ||= Worldwide.region(code: @country_code).zones.to_set(&:legacy_code)
        end
      end
    end
  end
end
