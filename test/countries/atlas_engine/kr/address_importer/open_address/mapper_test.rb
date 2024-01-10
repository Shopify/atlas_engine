# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Kr
    module AddressImporter
      module OpenAddress
        class MapperTest < ActiveSupport::TestCase
          setup do
            @feature = {
              "type" => "Feature",
              "properties" =>
             {
               "hash" => "6770d4633e3a1688",
               "number" => "94",
               "street" => "자하문로",
               "unit" => "",
               "city" => "종로구",
               "district" => "청운동",
               "region" => "서울특별시",
               "postcode" => "03047",
               "id" => "1111010100-760",
             },
              "geometry" => { "type" => "Point", "coordinates" => [126.97, 37.5842] },
            }
            @locale = "KO"
            @klass = Mapper.new(country_code: "KR", locale: @locale)
          end

          test "#map returns a hash with the expected mapping" do
            expected = {
              source_id: "OA-1111010100-760",
              locale: @locale,
              country_code: "KR",
              province_code: "KR-11",
              region1: "서울특별시",
              city: ["종로구"],
              suburb: "청운동",
              zip: "03047",
              street: "자하문로",
              building_and_unit_ranges: { "94" => {} },
              latitude: 37.5842,
              longitude: 126.97,
            }

            assert_equal(expected, @klass.map(@feature))
          end
        end
      end
    end
  end
end
