# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Phone
          class ValidTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(
                country_code: "US",
                phone: "+16046626000",
              )

              assert_nil Valid.new(field: :phone, address: address).evaluate
            end

            test "when is invalid" do
              address = build_address_obj(
                country_code: "CA",
                phone: "23699685",
              )
              concern = Valid.new(field: :phone, address: address).evaluate

              expected_concern = {
                field_names: [:phone],
                message: I18n.t("worldwide._default.addresses.phone.errors.invalid"),
                code: :phone_invalid,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end

            test "when phone contains html tags, can detect as invalid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
                phone: "<script>123",
              )
              concern = Valid.new(field: :phone, address: address).evaluate

              expected_concern = {
                field_names: [:phone],
                message: I18n.t("worldwide._default.addresses.phone.errors.invalid"),
                code: :phone_invalid,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end

            test "when phone contains a URL, can detect as invalid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
                phone: "https://123",
              )
              concern = Valid.new(field: :phone, address: address).evaluate

              expected_concern = {
                field_names: [:phone],
                message: I18n.t("worldwide._default.addresses.phone.errors.invalid"),
                code: :phone_invalid,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end

            test "when phone contains an emoji, can detect as invalid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
                phone: "123⛔️",
              )
              concern = Valid.new(field: :phone, address: address).evaluate

              expected_concern = {
                field_names: [:phone],
                message: I18n.t("worldwide._default.addresses.phone.errors.invalid"),
                code: :phone_invalid,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end
          end
        end
      end
    end
  end
end
