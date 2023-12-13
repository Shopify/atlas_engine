# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Services
    class ValidationEligibilityTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper

      class DummyService
        include ValidationEligibility
      end

      setup do
        @country_code = "CA"
        @locale = "en"
        @address = "123 Test St"
        @address_input = build_address(country_code: @country_code)
      end

      test "validation enabled returns false if country is nil" do
        nil_country = build_address(country_code: nil)
        assert_not DummyService.new.validation_enabled?(nil_country)
      end

      test "validation enabled returns false if country is blank" do
        nil_country = build_address(country_code: "")
        assert_not DummyService.new.validation_enabled?(nil_country)
      end

      test "validation enabled returns true if validation is enabled on country profile" do
        CountryProfile.expects(:for).with(@country_code).returns(mock(validation: mock(enabled: true)))

        assert DummyService.new.validation_enabled?(@address_input)
      end

      test "validation enabled returns false if validation is disabled on country profile" do
        CountryProfile.expects(:for).with(@country_code).returns(mock(validation: mock(enabled: false)))

        assert_not DummyService.new.validation_enabled?(@address_input)
      end
    end
  end
end
