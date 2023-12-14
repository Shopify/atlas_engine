# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Fr
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityCorrector
            end

            test "apply removes arrondissement when present" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "FR",
                country_code: "FR",
                province_code: "",
                region1: "",
                city: ["Paris 2e Arrondissement"],
                suburb: nil,
                zip: "75002",
                street: "Rue Saint-Denis",
                longitude: 4.83494,
                latitude: 45.7688,
                building_and_unit_ranges: { "106" => {} },
              }

              expected = input_address.merge({ city: ["Paris"] })

              @klass.apply(input_address)

              assert_equal expected, input_address
            end

            test "apply does nothing when no arrondissement present" do
              input_address = {
                source_id: "OA#9ac45faa4a783dbf",
                locale: "FR",
                country_code: "FR",
                province_code: "",
                region1: "",
                city: ["Nantes"],
                suburb: nil,
                zip: "44000",
                street: "Rue de Strasbourg",
                longitude: -1.55074,
                latitude: 47.2153,
                building_and_unit_ranges: { "15" => {} },
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
