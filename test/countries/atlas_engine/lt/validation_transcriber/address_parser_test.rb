# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Lt
    class AddressParserTest < ActiveSupport::TestCase
      include ValidationTranscriber

      test "#parse can extract building number and street correctly from address1" do
        examples = [
          {
            address1: "Griniaus 9",
            expected: { building_num: "9", street: "Griniaus" },
            comment: "simple building number and street",
          },
          {
            address1: "Maumedžių g. 37",
            expected: { building_num: "37", street: "Maumedžių g." },
            comment: "simple building number and street",
          },
          {
            address1: "Klevų g. 4, 99152 Grabupiai, Šilutės raj.",
            expected: { building_num: "4", street: "Klevų g." },
            comment: "building followed by comma and trailing info",
          },
          {
            address1: "Klevų g. 4,99152 Grabupiai, Šilutės raj.",
            expected: { building_num: "4", street: "Klevų g." },
            comment: "building followed by comma and trailing info",
          },
          {
            address1: "Trakėnų gvė 11-4",
            expected: { unit_num: "4", building_num: "11", street: "Trakėnų gvė" },
            comment: "unit number",
          },
          {
            address1: "Liepų g. 27-16, Biržų k ., Biržų r.",
            expected: { unit_num: "16", building_num: "27", street: "Liepų g." },
            comment: "unit number followed by comma and trailing info",
          },
          {
            address1: "Liepų g. 27-16,Biržų k ., Biržų r.",
            expected: { unit_num: "16", building_num: "27", street: "Liepų g." },
            comment: "unit number followed by comma and trailing info",
          },
        ]
        examples.each do |sample|
          address = AddressValidation::Address.new(
            address1: sample[:address1],
            address2: sample[:address2],
            country_code: "LT",
          )
          assert_parsings_include(address: address, expected: sample[:expected], comment: sample[:comment])
        end
      end

      private

      def assert_parsings_include(address:, expected:, comment:)
        actual = ValidationTranscriber::AddressParser.new(address: address).parse
        assert(actual.include?(expected), "Actual does not contain expected for : #{comment}")
      end
    end
  end
end
