# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Au
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" => {
                "hash" => "a194350bf021de51",
                "number" => "39",
                "street" => "METUNG ROAD",
                "unit" => "",
                "city" => "SWAN REACH",
                "district" => "",
                "region" => "VIC",
                "postcode" => "3903",
                "id" => "GAVIC424472726",
              },
              "geometry" => { "type" => "Point", "coordinates" => [147.8614333, -37.8364884] },
            }
            @klass = Mapper.new(country_code: "AU")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA-GAVIC424472726",
              locale: nil,
              country_code: "AU",
              province_code: "VIC",
              city: ["Swan Reach"],
              suburb: nil,
              zip: "3903",
              street: "Metung Road",
              building_and_unit_ranges: { "39" => {} },
              latitude: -37.8364884,
              longitude: 147.8614333,
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
