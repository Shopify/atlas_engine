# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module De
    class AddressParserTest < ActiveSupport::TestCase
      include ValidationTranscriber

      test "German addresses" do
        [
          # No unit number
          [:de, "Hauptstraße 137", [{ building_num: "137", street: "Hauptstraße" }]],
        ].each do |country_code, input, expected|
          check_parsing(country_code, input, nil, expected)
        end
      end

      private

      def check_parsing(country_code, address1, address2, expected, components = nil)
        components ||= {}
        components.merge!(country_code: country_code.to_s.upcase, address1: address1, address2: address2)
        address = AddressValidation::Address.new(**components)

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
