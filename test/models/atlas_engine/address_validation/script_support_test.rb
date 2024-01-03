# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    class ScriptSupportTest < ActiveSupport::TestCase
      include AddressValidationTestHelper

      class TestClass
        include ScriptSupport
      end

      test "#supported_script? returns false when the address has no country" do
        address = build_address(address1: "123 Main St", city: "Vancouver")
        assert_not TestClass.new.supported_script?(address)
      end

      test "#supported_script? returns true when there are no restrictions defined for the country" do
        address = build_address(country_code: "CA", address1: "123 Main St", city: "Vancouver")
        assert TestClass.new.supported_script?(address)
      end

      test "#supported_script? returns true when the address contains no scripts" do
        address = build_address(country_code: "CA", address1: "", address2: "", city: "")
        assert TestClass.new.supported_script?(address)
      end

      test "#supported_script? returns true when the address contains only supported scripts" do
        address = build_address(country_code: "KR", address1: "자하문로", city: "서울")
        assert TestClass.new.supported_script?(address)
      end

      test "#supported_script? returns false and logs when the address contains unsupported scripts" do
        address = build_address(country_code: "KR", address1: "Latin script", city: "서울")
        StatsD.expects(:increment).with("AddressValidation.unsupported_script", sample_rate: 1.0, tags: [
          "country_code:KR",
          "scripts:Hangul, Latn",
        ])
        assert_not TestClass.new.supported_script?(address)
      end
    end
  end
end
