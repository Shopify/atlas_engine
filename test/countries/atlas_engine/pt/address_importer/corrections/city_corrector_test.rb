# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pt
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply adds city aliases for applicable cities" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: nil,
                country_code: "PT",
                province_code: "PT-13",
                region1: "",
                city: ["Vila Nova De Gaia"],
                suburb: nil,
                zip: "4430-037",
                street: "Pct Camélias",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "31" => {} },
              }

              expected = input_address.merge({ city: ["Vila Nova De Gaia", "Gaia"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for non-applicable city" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: nil,
                country_code: "PT",
                province_code: "PT-11",
                region1: "",
                city: ["Lisboa"],
                suburb: nil,
                zip: "1200-158",
                street: "R Duque",
                longitude: -1.55074,
                latitude: 47.2153,
                building_and_unit_ranges: { "21" => {} },
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
