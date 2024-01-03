# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Nl
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply appends Den Haag as city alias when city is 's-Gravenhage" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "NL",
                country_code: "NL",
                province_code: "",
                region1: "",
                city: ["'s-Gravenhage"],
                suburb: nil,
                zip: "2514 KP",
                street: "Kerkstraat",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "19" => {} },
              }

              expected = input_address.merge({ city: ["'s-Gravenhage", "Den Haag"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for any other city" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "NL",
                country_code: "NL",
                province_code: "",
                region1: "",
                city: ["Eindhoven"],
                suburb: nil,
                zip: "5631 HP",
                street: "Euterpestraat",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "93" => {} },
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
