# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Restrictions
    class UnsupportedScriptTest < ActiveSupport::TestCase
      include AtlasEngine::AddressValidation::AddressValidationTestHelper

      test "#apply? returns true if the address contains a non-supported script" do
        addresses = [
          build_address(address1: "74, Toegye-ro 90-gil", city: "서울"), # Hangul
          build_address(address1: "شارع العجمي 7319", city: "Riyadh"), # Arabic
        ]

        addresses.each do |address|
          assert UnsupportedScript.apply?(address: address, params: { supported_script: :Latn })
        end
      end

      test "#apply? returns false if the address contains only supported script" do
        addresses = [
          build_address(address1: "1589 Dupont Street", city: "Toronto"),
          build_address(address1: "239 College Street", city: "Toronto"),
        ]

        addresses.each do |address|
          assert_not UnsupportedScript.apply?(address: address, params: { supported_script: :Latn })
        end
      end

      test "#apply? returns false is no script is detected in the address" do
        empty_address = build_address(address1: "", city: "")
        assert_not UnsupportedScript.apply?(address: empty_address, params: { supported_script: :Latn })
      end

      test "#apply? returns false if supported script is not passed in" do
        empty_address = build_address(address1: "", city: "")
        assert_not UnsupportedScript.apply?(address: empty_address)
      end
    end
  end
end
