# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Gg
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include ValidationTranscriber

        test "CountryProfile for GG loads the correct address parser" do
          assert_equal(AddressParser, CountryProfile.for("GG").validation.address_parser)
        end

        test "Parses one line Guernsey addresses" do
          [
            [
              :gg,
              "Apartment 15, La Charrotterie Mills, St Peter Port, Guernsey",
              [{ street: "Apartment 15, La Charrotterie Mills", city: "St Peter Port" }],
            ],
          ].each do |country_code, address1, expected|
            check_parsing(country_code, address1, nil, expected)
          end
        end

        test "Two line Guernsey addresses" do
          [
            [
              :gg,
              "L'etacq",
              "Le Petit Bas Courtil, St Saviour's",
              [
                { street: "L'etacq" },
                { street: "Le Petit Bas Courtil", city: "St Saviour's" },
              ],
            ],

          ].each do |country_code, address1, address2, expected|
            check_parsing(country_code, address1, address2, expected)
          end
        end

        private

        def check_parsing(country_code, address1, address2, expected, components = nil)
          components ||= {}
          components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
          address = AtlasEngine::AddressValidation::Address.new(**components)

          actual = AddressParser.new(address: address).parse

          assert(
            expected.to_set.subset?(actual.to_set),
            "For input ( address1: #{address1.inspect}, address2: #{address2.inspect} )\n\n " \
              "#{expected.inspect} \n\n" \
              "Must be included in: \n\n" \
              "#{actual.inspect}",
          )
        end
      end
    end
  end
end
