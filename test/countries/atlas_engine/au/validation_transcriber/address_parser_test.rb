# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Au
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for AU loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("AU").validation.address_parser)
        end

        test "#country_regex_formats matches an address string as expected" do
          examples = [
            { string: "", expected: nil, comment: "empty string" },
            { string: "Main St", expected: nil, comment: "missing building number" },
            {
              string: "100 Main St",
              expected: { building_num: "100", street: "Main St" },
              comment: "with simple building number",
            },
            {
              string: "100B Main St",
              expected: { building_num: "100B", street: "Main St" },
              comment: "building number with letter",
            },
            {
              string: "100-102 Main St",
              expected: { building_num: "100-102", street: "Main St" },
              comment: "building number range",
            },
            {
              string: "5 100-102 Main St",
              expected: { unit_num: "5", building_num: "100-102", street: "Main St" },
              comment: "unit number with range",
            },
            {
              string: "5 100 Main St",
              expected: { unit_num: "5", building_num: "100", street: "Main St" },
              comment: "unit number with space",
            },
            {
              string: "5/100 Main St",
              expected: { unit_num: "5", building_num: "100", street: "Main St" },
              comment: "unit number with slash",
            },
            {
              string: "flat 6 100 Main St",
              expected: { unit_type: "flat", unit_num: "6", building_num: "100", street: "Main St" },
              comment: "unit number with unit type",
            },
            {
              string: "Unit 4701, 93 Liverpool St",
              expected: { unit_type: "Unit", unit_num: "4701", building_num: "93", street: "Liverpool St" },
              comment: "unit with comma",
            },
            {
              string: "wrongtype 7 100 Main St",
              expected: { unit_num: "7", building_num: "100", street: "Main St" },
              comment: "unit number with wrong unit type",
            },
            {
              string: "ebay:d3rcvcv 149A Fitzroy St",
              expected: { building_num: "149A", street: "Fitzroy St" },
              comment: "reference number at start of address1",
            },
            {
              string: "22A/53-59 Balmoral Road",
              expected: { unit_num: "22A", building_num: "53-59", street: "Balmoral Road" },
              comment: "subunit with alphabet",
            },
            {
              string: "B103/20 Burnley street",
              expected: { unit_num: "B103", building_num: "20", street: "Burnley street" },
              comment: "subunit with prepended alphabet",
            },
          ]

          examples.each do |sample|
            parser = AddressParser.new(address: AddressValidation::Address.new(country_code: "AU"))
            assert_regex_captures(
              string: sample[:string],
              regex: parser.country_regex_formats.first,
              expected: sample[:expected],
              comment: sample[:comment],
            )
          end
        end
        test "#parse returns the correct address components for an AU address" do
          address = AddressValidation::Address.new(
            address1: "984 River Road",
            city: "Ferney",
            zip: "4650",
            province_code: "qld",
            country_code: "AU",
          )

          parser = AddressParser.new(address: address)
          assert_equal([{ building_num: "984", street: "River Road" }], parser.parse)
        end

        test "#parse can extract building number and street correctly from address1" do
          examples = [
            {
              address1: "17 Jones St",
              expected: { building_num: "17", street: "Jones St" },
              comment: "simple building number and street",
            },
            {
              address1: "11B Waterman Ave",
              expected: { building_num: "11B", street: "Waterman Ave" },
              comment: "building number with a letter",
            },
            {
              address1: "101-105 WENTWORTH RD",
              expected: { building_num: "101-105", street: "WENTWORTH RD" },
              comment: "building number as range",
            },
            {
              address1: "2 17 Jones St",
              expected: { unit_num: "2", building_num: "17", street: "Jones St" },
              comment: "unit number with space",
            },
            {
              address1: "2/17 Jones St",
              expected: { unit_num: "2", building_num: "17", street: "Jones St" },
              comment: "unit number with slash",
            },
            {
              address1: "unit 2, 17 Jones St",
              expected: { unit_type: "unit", unit_num: "2", building_num: "17", street: "Jones St" },
              comment: "unit number with comma",
            },
            {
              address1: "Parcel Locker 10104 92938",
              address2: "65-69 TALBRAGAR ST",
              expected: { building_num: "65-69", street: "TALBRAGAR ST" },
              comment: "extra reference data in address1, street in address2",
            },
            {
              address1: "23/400",
              address2: "Glenmore Parkway",
              expected: { unit_num: "23", building_num: "400", street: "Glenmore Parkway" },
              comment: "building and street on different lines",
            },
          ]
          examples.each do |sample|
            address = AddressValidation::Address.new(
              address1: sample[:address1],
              address2: sample[:address2],
              country_code: "AU",
            )
            assert_parsings_include(address: address, expected: sample[:expected], comment: sample[:comment])
          end
        end

        private

        def build_address(address1: nil, address2: nil)
          AddressValidation::Address.new(
            address1: address1,
            address2: address2,
            country_code: "AU",
          )
        end

        def assert_parsings_include(address:, expected:, comment:)
          actual = AddressParser.new(address: address).parse
          assert(actual.include?(expected), "Actual does not contain expected for : #{comment}")
        end

        def assert_regex_captures(regex:, string:, expected:, comment:)
          actual = regex.match(string)&.named_captures&.compact&.symbolize_keys

          if expected.nil?
            assert_nil(actual, comment)
          else
            assert_equal(
              expected,
              actual,
              comment,
            )
          end
        end
      end
    end
  end
end
