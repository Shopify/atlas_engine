# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParserBaseTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper

      test "raises ArgumentError if country_code is blank in address" do
        address = build_address(address1: "123 Main St")
        error = assert_raises(ArgumentError) do
          AddressParserBase.new(address: address).parse
        end
        assert_equal("country_code cannot be blank in address", error.message)
      end

      test "#parse returns empty parsings if no country_regex_formats are defined" do
        address = build_address(
          address1: "123 Main St",
          address2: "Apt 45",
          city: "New York",
          province_code: "NY",
          zip: "10001",
          country_code: "US",
        )
        assert_equal([], AddressParserBase.new(address: address).parse)
      end
    end
  end
end
