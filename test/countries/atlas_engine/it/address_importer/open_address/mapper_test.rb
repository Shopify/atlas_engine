# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module It
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" =>
             {
               "hash" => "924942534778cb4f",
               "number" => "55",
               "street" => "LocalitÃ  Pontone Rocchi",
               "unit" => "",
               "city" => "CIVITAVECCHIA",
               "district" => "ROME",
               "region" => "LAZIO",
               "postcode" => "00053",
               "id" => "13800054839073",
             },
              "geometry" => { "type" => "Point", "coordinates" => [11.793187, 42.107467] },
            }
            @klass = Mapper.new(country_code: "IT", locale: "IT")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA-13800054839073",
              locale: "IT",
              country_code: "IT",
              province_code: "RM", # province code from district
              region1: "LAZIO",
              region2: "ROME",
              city: ["Civitavecchia"], # the city has been titleized
              suburb: nil,
              zip: "00053",
              street: "Localitã  Pontone Rocchi",
              building_and_unit_ranges: { "55" => {} },
              latitude: 42.107467,
              longitude: 11.793187,
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
