# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply appends Reggio Emilia as a city alias when the city is Reggio Nell'emilia" do
              input_address = {
                source_id: "OA-13800020926269",
                locale: "IT",
                country_code: "IT",
                province_code: "RE",
                region1: "REGGIO NELL'EMILIA",
                city: ["Reggio Nell'emilia"],
                suburb: nil,
                zip: "42122",
                street: "Via Leonida Bissolati",
                longitude: 10.6366,
                latitude: 44.6877,
                building_and_unit_ranges: { "2": {}, "3": {}, "5": {}, "6": {} },
              }

              expected = input_address.merge({ city: ["Reggio Nell'emilia", "Reggio Emilia"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "#apply sets Sissa Trecasali as a city alias when the city is Sissa" do
              input_address = {
                source_id: "OA-13800033606107",
                locale: "IT",
                country_code: "IT",
                province_code: "PR",
                region2: "EMILIA-ROMAGNA",
                city: ["Sissa"],
                suburb: nil,
                zip: "43018",
                street: "Via Gramigna",
                longitude: 10.2556,
                latitude: 44.9866,
              }
              expected = input_address.merge({ city: ["Sissa Trecasali"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for any other city" do
              input_address = {
                source_id: "OA-13800024155518",
                locale: "IT",
                country_code: "IT",
                province_code: "AG",
                region1: "SICILIA",
                city: ["Agrigento"],
                suburb: nil,
                zip: "92100",
                street: "Via Argento",
                longitude: 13.5845,
                latitude: 37.3106,
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
