# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Fr
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for FR loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("FR").validation.address_parser)
        end

        test "#parse can extract building number and street correctly from address1" do
          examples = [
            {
              address1: "13 Rue Principale",
              expected: { building_num: "13", street: "Rue Principale" },
              comment: "simple building number and street",
            },
            {
              address1: "6b Rue de Cadix",
              expected: { building_num: "6b", street: "Rue de Cadix" },
              comment: "building number with a letter",
            },
            {
              address1: "6b Rue de Cadix",
              expected: { building_num: "6b", street: "Rue de Cadix" },
              comment: "building number with a letter separated by space",
            },
            {
              address1: "6ter Chemin du Néron",
              expected: { building_num: "6ter", street: "Chemin du Néron" },
              comment: "building number with subdivision",
            },
            {
              address1: "126 bis Rue de Lannoy",
              expected: { building_num: "126 bis", street: "Rue de Lannoy" },
              comment: "building number with subdivision separated by space",
            },
            {
              address1: "126 Rue de Lannoy, apt 12",
              expected: { building_num: "126", street: "Rue de Lannoy" },
              comment: "building number and street followed by comma and extra information",
            },
          ]
          examples.each do |sample|
            address = AddressValidation::Address.new(
              address1: sample[:address1],
              address2: sample[:address2],
              country_code: "FR",
            )
            assert_parsings_include(address: address, expected: sample[:expected], comment: sample[:comment])
          end
        end

        private

        def build_address(address1: nil, address2: nil)
          AddressValidation::Address.new(
            address1: address1,
            address2: address2,
            country_code: "FR",
          )
        end

        def assert_parsings_include(address:, expected:, comment:)
          actual = AddressParser.new(address: address).parse
          assert(actual.include?(expected), "Actual does not contain expected for : #{comment}")
        end
      end
    end
  end
end
