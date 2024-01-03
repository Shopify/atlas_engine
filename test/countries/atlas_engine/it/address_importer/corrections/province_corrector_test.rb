# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module It
    module AddressImporter
      module Corrections
        module OpenAddress
          class ProvinceCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = ProvinceCorrector
            end

            test "apply sets BZ as the province code when region2 is bolzano/bozen" do
              input_address = {
                source_id: "OA-13800034123078",
                locale: "IT",
                country_code: "IT",
                province_code: nil,
                region1: "TRENTINO-ALTO ADIGE/SUDTIROL",
                region2: "BOLZANO/BOZEN",
                city: ["Lasa"],
                suburb: nil,
                zip: "39023",
                street: "Via Tanas",
                longitude: 10.6504,
                latitude: 46.6308,
              }

              expected = input_address.merge({ province_code: "BZ" })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply sets FC as the province code when region2 is forli'-cesena" do
              input_address = {
                source_id: "OA-13800020725960",
                locale: "IT",
                country_code: "IT",
                province_code: nil,
                region1: "EMILIA-ROMAGNA",
                region2: "FORLI'-CESENA",
                city: ["Cesena"],
                suburb: nil,
                zip: "47521",
                street: "Via Nello Casali",
                longitude: 12.2504,
                latitude: 44.1498,
              }
              expected = input_address.merge({ province_code: "FC" })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply sets RC as the province code when region2 is reggio di calabria" do
              input_address = {
                source_id: "OA-13800072834442",
                locale: "IT",
                country_code: "IT",
                province_code: nil,
                region2: "REGGIO DI CALABRIA",
                city: ["Seminara"],
                suburb: nil,
                zip: "89028",
                street: "Via Taureana",
                longitude: 15.8708,
                latitude: 38.3353,
              }
              expected = input_address.merge({ province_code: "RC" })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing for any other region2" do
              input_address = {
                source_id: "OA-13800024155518",
                locale: "IT",
                country_code: "IT",
                province_code: "AG",
                region1: "SICILIA",
                region2: "AGRIGENTO",
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
