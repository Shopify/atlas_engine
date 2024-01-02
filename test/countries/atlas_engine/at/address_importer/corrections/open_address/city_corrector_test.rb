# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module At
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply fills Wien as the city for applicable zip" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "de",
                country_code: "AT",
                province_code: "",
                region1: "",
                city: [],
                suburb: nil,
                zip: "1010",
                street: "Naglergasse",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "31" => {} },
              }

              expected = input_address.merge({ city: ["Wien"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for non-applicable zip" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "de",
                country_code: "AT",
                province_code: "",
                region1: "",
                city: ["Innsbruck"],
                suburb: nil,
                zip: "6080",
                street: "Bachgangweg",
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
