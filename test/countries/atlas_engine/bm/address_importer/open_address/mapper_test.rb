# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Bm
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" => {
                "hash" => "6395316d288050c9",
                "number" => "1",
                "street" => "Adams Lane",
                "unit" => "",
                "city" => "",
                "district" => "Warwick",
                "region" => "",
                "postcode" => "WK06",
                "id" => "14208",
              },
              "geometry" => { "type" => "Point", "coordinates" => [-64.8043272, 32.2687166] },
            }
            @klass = Mapper.new(country_code: "BM")
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA-14208",
              locale: nil,
              country_code: "BM",
              province_code: nil,
              city: ["Warwick"],
              suburb: nil,
              zip: "WK 06",
              street: "Adams Lane",
              building_and_unit_ranges: { "1" => {} },
              latitude: 32.2687166,
              longitude: -64.8043272,
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
