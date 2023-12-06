# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NotExceedMaxLengthTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          test "when is valid" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            assert_nil NotExceedMaxLength.new(field: :address1, address: address).evaluate
          end

          test "when address1 exceeds length limit" do
            address = build_address_obj(
              address1:  "A" * 256,
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )
            concern = NotExceedMaxLength.new(field: :address1, address: address).evaluate

            expected_concern = {
              field_names: [:address1],
              message: I18n.t("worldwide._default.addresses.address1.errors.too_long"),
              code: :address1_too_long,
              type: "error",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when address2 exceeds length limit" do
            address = build_address_obj(
              address1: "Pacific Blvd",
              address2: "A" * 256,
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NotExceedMaxLength.new(field: :address2, address: address).evaluate

            expected_concern = {
              field_names: [:address2],
              message: I18n.t("worldwide._default.addresses.address2.errors.too_long"),
              code: :address2_too_long,
              type: "error",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when city exceeds length limit" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "V" * 256,
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NotExceedMaxLength.new(field: :city, address: address).evaluate

            expected_concern = {
              field_names: [:city],
              message: I18n.t("worldwide._default.addresses.city.errors.too_long"),
              code: :city_too_long,
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
