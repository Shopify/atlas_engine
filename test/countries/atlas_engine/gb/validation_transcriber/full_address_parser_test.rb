# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Gb
    module ValidationTranscriber
      class FullAddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "identifies the parts of UK addresses as expected" do
          [
            [
              {
                address1: "1 High Street",
                address2: "",
                city: "Banchory",
                zip: "AB31 5RP",
                province_code: "SCT",
                country_code: "GB",
              },
              [
                ParsedAddress.new(
                  building_num: "1",
                  street: "High Street",
                  post_town: "Banchory",
                  zip: "AB31 5RP",
                  province_code: "SCT",
                  country_code: "GB",
                ),
              ],
            ],
            [
              {
                address1: "2 Elm Avenue",
                address2: "Runcorn Road",
                city: "Birmingham",
                zip: "B12 8QX",
                province_code: "ENG",
                country_code: "GB",
              },
              [
                ParsedAddress.new(
                  building_num: "2",
                  street: "Elm Avenue",
                  dependent_locality: "Runcorn Road",
                  post_town: "Birmingham",
                  zip: "B12 8QX",
                  province_code: "ENG",
                  country_code: "GB",
                ),
                ParsedAddress.new(
                  building_num: "2",
                  dependent_street: "Elm Avenue",
                  street: "Runcorn Road",
                  post_town: "Birmingham",
                  zip: "B12 8QX",
                  province_code: "ENG",
                  country_code: "GB",
                ),
              ],
            ],
            [
              {
                address1: "310 Derrylin Road",
                address2: "Drumbrughas, Mackan",
                city: "ENNISKILLEN",
                zip: "BT92 3DP",
                province_code: "NIR",
                country_code: "GB",
              },
              [
                ParsedAddress.new(
                  building_num: "310",
                  street: "Derrylin Road",
                  double_dependent_locality: "Drumbrughas",
                  dependent_locality: "Mackan",
                  post_town: "ENNISKILLEN",
                  zip: "BT92 3DP",
                  province_code: "NIR",
                  country_code: "GB",
                ),
                ParsedAddress.new(
                  building_num: "310",
                  dependent_street: "Derrylin Road",
                  street: "Drumbrughas",
                  dependent_locality: "Mackan",
                  post_town: "ENNISKILLEN",
                  zip: "BT92 3DP",
                  province_code: "NIR",
                  country_code: "GB",
                ),
                ParsedAddress.new(
                  building_num: "310",
                  dependent_street: "Derrylin Road",
                  street: "Drumbrughas, Mackan",
                  post_town: "ENNISKILLEN",
                  zip: "BT92 3DP",
                  province_code: "NIR",
                  country_code: "GB",
                ),
              ],
            ],
          ].each do |input, expected|
            address = build_address(**input)
            actual = FullAddressParser.new(address: address).parse
            assert_equal(expected, actual)
          end
        end

        test "parse does not fall over when faced with a `nil` city" do
          input = build_address(
            address1: "The Whiteway",
            address2: nil,
            city: nil, # should be Cirencester
            zip: "GL7 2BX",
            country_code: "GB",
          )
          expected = ParsedAddress.new(
            street: "The Whiteway",
            zip: "GL7 2BX",
            country_code: "GB",
          )

          actual = FullAddressParser.new(address: input).parse

          assert actual.include?(expected)
        end
      end
    end
  end
end
