# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pt
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" => {
                "hash" => "e8f7c3d68c88bb6d",
                "number" => "1",
                "street" => "R PRINCIPAL",
                "unit" => "",
                "city" => "MACINHATA DO VOUGA",
                "district" => "",
                "region" => "",
                "postcode" => "3750-601",
                "id" => "",
              },
              "geometry" => { "type" => "Point", "coordinates" => [147.8614333, -37.8364884] },
            }

            @klass = Mapper.new(country_code: "PT")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA#e8f7c3d68c88bb6d",
              locale: nil,
              country_code: "PT",
              province_code: "PT-01",
              city: ["Macinhata Do Vouga"],
              suburb: nil,
              zip: "3750-601",
              street: "R Principal",
              longitude: 147.8614333,
              latitude: -37.8364884,
              building_and_unit_ranges: { "1" => {} },
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
