# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Province
          class ExistsTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "does not create a concern when province code is present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil Exists.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province code is present and is invalid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "XX",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil Exists.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province_code is not present but it is optional" do
              address = build_address_obj(address1: "239 Main Highway", city: "Otaki", zip: "5512", country_code: "NZ")

              assert_nil Exists.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province_code is not present and country has no provinces" do
              address = build_address_obj(country_code: "GB")

              assert_nil Exists.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province code is present and is optional" do
              address = build_address_obj(
                address1: "239 Main Highway",
                city: "Otaki",
                province_code: "WGN",
                zip: "5512",
                country_code: "NZ",
              )

              assert_nil Exists.new(field: :province, address: address).evaluate
            end

            test "creates a concern when province code is not present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: nil,
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              expected_concern =
                {
                  field_names: [:province],
                  message: I18n.t("worldwide.CA.addresses.province.errors.blank"),
                  code: :province_blank,
                  type: "error",
                  type_level: 3,
                  suggestion_ids: [],
                }

              concern = Exists.new(field: :province, address: address).evaluate

              assert_equal(expected_concern, concern&.attributes)
            end
          end
        end
      end
    end
  end
end
