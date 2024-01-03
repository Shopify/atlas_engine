# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Dk
    class AddressParserTest < ActiveSupport::TestCase
      include ValidationTranscriber

      test "Danish addresses" do
        [
          # Unit number, standard format including a space
          [:dk, "Tietensgade 137, 2", [{ building_num: "137", street: "Tietensgade", unit_num: "2" }]],

          # Unit number with space omitted
          [:dk, "Tietensgade 137,2", [{ building_num: "137", street: "Tietensgade", unit_num: "2" }]],

          # Unit number with designator - currently does not distinguish between unit number and unit type
          [
            :dk,
            "Theodore roosevelts vej 19, 7. Tv",
            [{ building_num: "19", street: "Theodore roosevelts vej", unit_num: "7. Tv" }],
          ],

          # No unit number
          [:dk, "Tietensgade 137", [{ building_num: "137", street: "Tietensgade" }]],
        ].each do |country_code, input, expected|
          check_parsing(country_code, input, nil, expected)
        end
      end

      private

      def check_parsing(country_code, address1, address2, expected, components = nil)
        components ||= {}
        components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
        address = AddressValidation::Address.new(**components)

        actual = ValidationTranscriber::AddressParser.new(address: address).parse

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
