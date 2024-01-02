# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Ch
    module AddressImporter
      module Corrections
        module OpenAddress
          class LocaleCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = LocaleCorrector
            end

            test "apply sets locale to German for German cantons/zips" do
              input_addresses = [
                {
                  source_id: "OA-1-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "BE",
                  region1: nil,
                  city: ["Lüscherz"],
                  suburb: nil,
                  zip: "2576",
                  street: "Hauptstrasse",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-11513751-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "FR",
                  region1: nil,
                  city: ["Courtaman"],
                  suburb: nil,
                  zip: "1791",
                  street: "Schulweg",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-101154937-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "VS",
                  region1: nil,
                  city: ["Brigerbad"],
                  suburb: nil,
                  zip: "3900",
                  street: "Badhaltestrasse",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-11526735-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "GR",
                  region1: nil,
                  city: ["Chur"],
                  suburb: nil,
                  zip: "7000",
                  street: "Pulvermühlestrasse",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-101177966-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "GR",
                  region1: nil,
                  city: ["Ilanz"],
                  suburb: nil,
                  zip: "7130",
                  street: "Brineggweg",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ locale: "de" })

                @klass.apply(input_address)

                assert_equal expected, input_address
              end
            end

            test "apply sets locale to French for French cantons/zips" do
              input_addresses = [
                {
                  source_id: "OA-1000378-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "GE",
                  region1: nil,
                  city: ["Anières"],
                  suburb: nil,
                  zip: "1247",
                  street: "Chemin des Avallons",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-11515215-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "FR",
                  region1: nil,
                  city: ["Les Sciernes-d'Albeuve"],
                  suburb: nil,
                  zip: "1669",
                  street: "Route de la Tsarère",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-101162756-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "VS",
                  region1: nil,
                  city: ["Mayens-de-Chamoson"],
                  suburb: nil,
                  zip: "1955",
                  street: "Route de la Lacha",
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

            test "apply sets locale to Italian for Italian cantons/zips" do
              input_addresses = [
                {
                  source_id: "OA-11100006-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "TI",
                  region1: nil,
                  city: ["Castro"],
                  suburb: nil,
                  zip: "6723",
                  street: "Via Traversa",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-101000062-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "GR",
                  region1: nil,
                  city: ["Platta"],
                  suburb: nil,
                  zip: "7185",
                  street: "Via Foppas",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
                {
                  source_id: "OA-101177963-0",
                  locale: nil,
                  country_code: "CH",
                  province_code: "GR",
                  region1: nil,
                  city: ["Ilanz"],
                  suburb: nil,
                  zip: "7130",
                  street: "Via Schlifras",
                  longitude: 10.6366,
                  latitude: 44.6877,
                  building_and_unit_ranges: { "2": {} },
                },
              ]

              input_addresses.each do |input_address|
                expected = input_address.merge({ locale: "it" })

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
