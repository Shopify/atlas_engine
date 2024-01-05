# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Tt
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" => {
                "hash" => "e87056547310c1c6",
                "number" => "386",
                "street" => "Southern Main Road",
                "unit" => "",
                "city" => "Warrenville",
                "district" => "",
                "region" => "",
                "postcode" => "520330",
                "id" => "",
              },
              "geometry" => { "type" => "Point", "coordinates" => [147.8614333, -37.8364884] },
            }
            @klass = Mapper.new(country_code: "TT")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA#e87056547310c1c6",
              locale: nil,
              country_code: "TT",
              province_code: nil,
              city: ["Chaguanas"],
              suburb: "Warrenville",
              zip: "520330",
              street: "Southern Main Road",
              building_and_unit_ranges: { "386" => {} },
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
