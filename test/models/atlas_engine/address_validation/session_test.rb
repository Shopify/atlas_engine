# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class SessionTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper
      include AddressValidation::TokenHelper

      test "exposes address input fields" do
        session = AddressValidation::Session.new(address: address)
        assert_equal "123 Main Street", session.address1
        assert_equal "Entrance B", session.address2
        assert_equal "Springfield", session.city
        assert_equal "ME", session.province_code
        assert_equal "US", session.country_code
        assert_equal "04487", session.zip
        assert_equal "1234567890", session.phone
      end

      private

      def address
        build_address(
          address1: "123 Main Street",
          address2: "Entrance B",
          city: "Springfield",
          province_code: "ME",
          country_code: "US",
          zip: "04487",
          phone: "1234567890",
        )
      end

      def address_ch
        build_address(
          address1: "Vordere Gasse 7",
          address2: "",
          city: "Busslingen",
          province_code: "",
          country_code: "CH",
          zip: "5453",
          phone: "1234567890",
        )
      end
    end
  end
end
