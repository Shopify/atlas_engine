# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NotExceedMaxTokenCountTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          test "when is valid" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            assert_nil NotExceedMaxTokenCount.new(field: :address1, address: address).evaluate
          end

          test "when address1 exceeds length limit" do
            address = build_address_obj(
              address1:  "A A A A A A A A A A A A A A A A",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )
            concern = NotExceedMaxTokenCount.new(field: :address1, address: address).evaluate

            expected_concern = {
              field_names: [:address1],
              message: "Address line 1 is recommended to have less than 15 words",
              code: :address1_contains_too_many_words,
              type: "warning",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when address2 exceeds length limit" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              address2: "A A A A A A A A A A A A A A A A",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NotExceedMaxTokenCount.new(field: :address2, address: address).evaluate

            expected_concern = {
              field_names: [:address2],
              message: "Address line 2 is recommended to have less than 15 words",
              code: :address2_contains_too_many_words,
              type: "warning",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when city exceeds length limit" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "V V V V V V V V V V V V V V V V",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NotExceedMaxTokenCount.new(field: :city, address: address).evaluate

            expected_concern = {
              field_names: [:city],
              message: "City cannot have more than 15 words",
              code: :city_contains_too_many_words,
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
