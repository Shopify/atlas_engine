# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class DefaultMapperTest < ActiveSupport::TestCase
        setup do
          @country_code = "DK"
          @locale = "DA"
          @feature = {
            "type" => "Feature",
            "properties" =>
            {
              "hash" => "9ac45faa4a783dbf",
              "number" => "13",
              "street" => "Isefjords Alle",
              "unit" => "11 3",
              "city" => "Holbæk",
              "district" => "",
              "region" => "Region Sjælland",
              "postcode" => "DK-4 3 0 0", # unnormalized
              "id" => "",
            },
            "geometry" => { "type" => "Point", "coordinates" => [11.7165786, 55.7202219] },
          }
        end

        test "#map returns a hash with the expected keys" do
          expected = {
            source_id: "OA#9ac45faa4a783dbf",
            locale: @locale,
            country_code: @country_code,
            province_code: nil,
            region1: "Region Sjælland",
            city: ["Holbæk"],
            suburb: nil,
            zip: "4300",
            street: "Isefjords Alle",
            longitude: 11.7165786,
            latitude: 55.7202219,
            building_and_unit_ranges: { "13" => { "11 3" => {} } },
          }

          mapper = DefaultMapper.new(country_code: @country_code, locale: @locale)

          assert_equal(expected, mapper.map(@feature))
        end

        test "#map returns a hash with the expected keys when no locale is specified" do
          expected = {
            source_id: "OA#9ac45faa4a783dbf",
            locale: nil,
            country_code: @country_code,
            province_code: nil,
            region1: "Region Sjælland",
            city: ["Holbæk"],
            suburb: nil,
            zip: "4300",
            street: "Isefjords Alle",
            longitude: 11.7165786,
            latitude: 55.7202219,
            building_and_unit_ranges: { "13" => { "11 3" => {} } },
          }

          mapper = DefaultMapper.new(country_code: @country_code)

          assert_equal(expected, mapper.map(@feature))
        end

        test "#map handles empty building and unit ranges" do
          @feature["properties"]["number"] = ""
          @feature["properties"]["unit"] = ""

          expected = {
            source_id: "OA#9ac45faa4a783dbf",
            locale: @locale,
            country_code: @country_code,
            province_code: nil,
            region1: "Region Sjælland",
            city: ["Holbæk"],
            suburb: nil,
            zip: "4300",
            street: "Isefjords Alle",
            longitude: 11.7165786,
            latitude: 55.7202219,
            building_and_unit_ranges: {},
          }

          mapper = DefaultMapper.new(country_code: @country_code, locale: @locale)

          assert_equal(expected, mapper.map(@feature))
        end
      end
    end
  end
end
