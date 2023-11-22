# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    class AddressTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper

      test "#from_address_input" do
        partial_address = build_address(
          address1: "123 Main St.",
          city: "Baltimore",
          province_code: "MD",
          zip: "21201",
          country_code: "US",
        )

        address = Address.from_address(address: partial_address)

        assert_equal "123 Main St.", address.address1
        assert_equal "Baltimore", address.city
        assert_equal "MD", address.province_code
        assert_equal "21201", address.zip
        assert_equal "US", address.country_code
      end
    end
  end
end
