# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Lu
    module AddressImporter
      module Corrections
        module OpenAddress
          class LocaleCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = LocaleCorrector
            end

            test "apply sets locale to French for French streets" do
              input_addresses = [
                {
                  source_id: "OA-1-0",
                  locale: nil,
                  country_code: "LU",
                  province_code: "",
                  region1: nil,
                  city: ["Luxembourg"],
                  suburb: nil,
                  zip: "1125",
                  street: "Avenue Amélie",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-11513751-0",
                  locale: nil,
                  country_code: "LU",
                  province_code: "",
                  region1: nil,
                  city: ["Arsdorf"],
                  suburb: nil,
                  zip: "8809",
                  street: "Rue du Cimetière",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ locale: "fr" })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply sets locale to Luxembourgish for other streets" do
              input_addresses = [
                {
                  source_id: "OA-1000378-0",
                  locale: nil,
                  country_code: "LU",
                  province_code: "",
                  region1: nil,
                  city: ["Këppenhaff"],
                  suburb: nil,
                  zip: "9378",
                  street: "Hammwee",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-11515215-0",
                  locale: nil,
                  country_code: "LU",
                  province_code: "",
                  region1: nil,
                  city: ["Brandenbourg"],
                  suburb: nil,
                  zip: "9360",
                  street: "Haaptstrooss",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ locale: "lb" })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end
          end
        end
      end
    end
  end
end
