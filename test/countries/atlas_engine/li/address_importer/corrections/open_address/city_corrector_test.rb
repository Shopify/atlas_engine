# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Li
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply adds village/town to city field for applicable municipality" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: nil,
                country_code: "LI",
                province_code: "",
                region1: "",
                city: ["Gamprin-Bendern"],
                suburb: nil,
                zip: "9492",
                street: "Bühl",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "61" => {} },
              }

              expected = input_address.merge({ city: ["Gamprin-Bendern", "Gamprin", "Bendern"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for non-applicable municipality" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: nil,
                country_code: "LI",
                province_code: "",
                region1: "",
                city: ["Vaduz"],
                suburb: nil,
                zip: "9495",
                street: "Mitteldorf",
                longitude: -1.55074,
                latitude: 47.2153,
                building_and_unit_ranges: { "32" => {} },
              }

              expected = input_address

              @klass.apply(input_address)

              assert_equal expected, input_address
            end
          end
        end
      end
    end
  end
end
