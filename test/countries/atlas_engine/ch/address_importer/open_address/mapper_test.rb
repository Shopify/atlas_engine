# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Ch
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" =>
            {
              "hash" => "9ac45faa4a783dbf",
              "number" => "2",
              "street" => "Hauptstrasse",
              "unit" => "",
              "city" => "Lüscherz",
              "district" => "",
              "region" => "BE",
              "postcode" => "2576",
              "id" => "",
            },
              "geometry" => { "type" => "Point", "coordinates" => [11.7165786, 55.7202219] },
            }
            @klass = Mapper.new(country_code: "CH", locale: "de")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA#9ac45faa4a783dbf",
              locale: "de",
              country_code: "CH",
              province_code: "BE",
              region1: nil,
              city: ["Lüscherz"],
              suburb: nil,
              zip: "2576",
              street: "Hauptstrasse",
              longitude: 11.7165786,
              latitude: 55.7202219,
              building_and_unit_ranges: { "2" => {} },
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
