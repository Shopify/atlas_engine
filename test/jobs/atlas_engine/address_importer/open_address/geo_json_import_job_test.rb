# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class GeoJsonImportJobTest < ActiveSupport::TestCase
        setup do
          @import = FactoryBot.create(:country_import, :dk_in_progres)
          @locale = "EN"
          @params = {
            geojson_file_path: "/dev/null",
            country_code: @import.country_code,
            locale: @locale,
          }

          @job = GeoJsonImportJob.new(**@params)

          @one_batch_of_blank_objects = "{}\n" * GeoJsonImportJob::CHUNK_SIZE
          @loader = Loader.new
          @transformer = Transformer.new(country_import: @import, locale: @locale)
          @job.stubs(
            io: StringIO.new(@one_batch_of_blank_objects),
            country_import: @import,
            country_profile: CountryProfile.new(code: "ZZ"),
            loader: @loader,
            transformer: @transformer,
          )
        end

        test "#build_enumerator returns an enumerator and not an Array" do
          enum = @job.build_enumerator(@params, cursor: nil)
          assert_kind_of Enumerator, enum
          assert_not_kind_of Array, enum
        end

        test "#perform reads gzipped files" do
          Tempfile.create(["geojson", ".gz"]) do |path|
            Zlib::GzipWriter.open(path) do |gz|
              gz.write("{}\n" * 10)
            end
            params = {
              country_code: "ZZ",
            }
            job = GeoJsonImportJob.new(**params)
            import = CountryImport.new(country_code: "ZZ")
            import.start!
            job.stubs(
              country_import: import,
              geojson_path: Pathname.new(path),
              country_profile: CountryProfile.new(code: "ZZ"),
            )
            job.expects(:each_iteration).once
            job.stubs(:import_log_info)
            job.perform(cursor: nil)
          end
        end

        test "#perform calls each_iteration 5 times when input has 50_000 entries" do
          @loader = Loader.new
          @job.stubs(
            io: StringIO.new(@one_batch_of_blank_objects * 5),
            country_import: @import,
            country_profile: CountryProfile.new(code: "ZZ"),
            loader: @loader,
          )
          @job.expects(:log_final_stats).once
          @job.expects(:each_iteration).times(5)
          @job.expects(:import_log_info).twice # at start, and for the first chunk
          @job.perform(cursor: nil)
        end

        test "#attributes_from_batch parses properties" do
          inputs = [
            {
              "type" => "Feature",
              "properties" => {
                "hash" => "9ac45faa4a783dbf",
                "number" => "13",
                "street" => "Isefjords Alle",
                "unit" => "11 3",
                "city" => "Holbæk",
                "district" => "",
                "region" => "Region Sjælland",
                "postcode" => "4300",
                "id" => "",
              },
              "geometry" => {
                "type" => "Point",
                "coordinates" => [11.7165786, 55.7202219],
              },
            },
            {
              "type" => "Feature",
              "properties" => {
                "hash" => "7b59d9c9e460a188",
                "number" => "17",
                "street" => "Isefjordsvej",
                "unit" => "",
                "city" => "Nykøbing Sj",
                "district" => "",
                "region" => "Region Sjælland",
                "postcode" => "4500",
                "id" => "",
              },
              "geometry" => { "type" => "Point", "coordinates" => [11.6629396, 55.9192613] },
            },
          ]
          holbaek_addr = @job.attributes_from_batch(inputs).first
          nykobing_addr = @job.attributes_from_batch(inputs).last

          assert_equal(
            {
              source_id: "OA#9ac45faa4a783dbf",
              locale: @locale,
              country_code: @import.country_code,
              province_code: nil,
              region1: "Region Sjælland",
              city: ["Holbæk"],
              suburb: nil,
              zip: "4300",
              street: "Isefjords Alle",
              longitude: 11.7165786,
              latitude: 55.7202219,
              building_and_unit_ranges: { "13" => { "11 3" => {} } },
            },
            holbaek_addr,
          )

          assert_equal(
            {
              source_id: "OA#7b59d9c9e460a188",
              locale: @locale,
              country_code: @import.country_code,
              province_code: nil,
              region1: "Region Sjælland",
              city: ["Nykøbing Sj"],
              suburb: nil,
              zip: "4500",
              street: "Isefjordsvej",
              longitude: 11.6629396,
              latitude: 55.9192613,
              building_and_unit_ranges: { "17" => {} },
            },
            nykobing_addr,
          )
        end

        test "#each_iteration condenses the batch on building_and_unit_range" do
          a1 = {
            source_id: "OA#9ac45faa4a783dbf",
            locale: @locale,
            country_code: @import.country_code,
            province_code: "",
            region1: "Region Sjælland",
            city: ["Holbæk"],
            suburb: nil,
            zip: "4300",
            street: "Isefjords Alle",
            longitude: 11.7165786,
            latitude: 55.7202219,
            building_and_unit_ranges: { "13" => {} },
          }
          a2 = a1.dup.merge(building_and_unit_ranges: { "14" => {} })
          a3 = a1.dup.merge(zip: "4301")
          batch = [a1, a2, a3]

          condensed_addresses = [
            {
              source_id: "OA#9ac45faa4a783dbf",
              locale: @locale,
              country_code: @import.country_code,
              province_code: "",
              region1: "Region Sjælland",
              city: ["Holbæk"],
              suburb: nil,
              zip: "4300",
              street: "Isefjords Alle",
              longitude: 11.7165786,
              latitude: 55.7202219,
              building_and_unit_ranges: { "13" => {}, "14" => {} },
            },
            {
              source_id: "OA#9ac45faa4a783dbf",
              locale: @locale,
              country_code: @import.country_code,
              province_code: "",
              region1: "Region Sjælland",
              city: ["Holbæk"],
              suburb: nil,
              zip: "4301",
              street: "Isefjords Alle",
              longitude: 11.7165786,
              latitude: 55.7202219,
              building_and_unit_ranges: { "13" => {} },
            },
          ]

          @job.expects(:attributes_from_batch).once.returns(batch)
          @loader.expects(:load).once.with(condensed_addresses)
          @job.expects(:log_final_stats).once

          @job.perform(cursor: nil)
        end
      end
    end
  end
end
