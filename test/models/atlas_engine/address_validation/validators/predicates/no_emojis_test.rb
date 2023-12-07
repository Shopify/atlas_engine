# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class NoEmojisTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          test "when is valid" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            assert_nil NoEmojis.new(field: :address1, address: address).evaluate
          end

          test "when address1 contains an emoji" do
            address = build_address_obj(
              address1: "777 Pacific ⛔️ Blvd",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NoEmojis.new(field: :address1, address: address).evaluate

            expected_concern = {
              field_names: [:address1],
              message: I18n.t("worldwide._default.addresses.address1.errors.contains_emojis"),
              code: :address1_contains_emojis,
              type: "error",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when address2 contains an emoji" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              address2: "⛔️",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NoEmojis.new(field: :address2, address: address).evaluate

            expected_concern = {
              field_names: [:address2],
              message: I18n.t("worldwide._default.addresses.address2.errors.contains_emojis"),
              code: :address2_contains_emojis,
              type: "error",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when zip contains an emoji" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "Vancouver",
              province_code: "BC",
              zip: "V6B ⛔️4Y8",
              country_code: "CA",
            )

            concern = NoEmojis.new(field: :zip, address: address).evaluate

            expected_concern = {
              field_names: [:zip],
              message: I18n.t("worldwide._default.addresses.zip.errors.contains_emojis"),
              code: :zip_contains_emojis,
              type: "error",
              type_level: 3,
              suggestion_ids: [],
            }

            assert_equal expected_concern, concern&.attributes
          end

          test "when city contains an emoji" do
            address = build_address_obj(
              address1: "777 Pacific Blvd",
              city: "Vanc⛔️uver",
              province_code: "BC",
              zip: "V6B 4Y8",
              country_code: "CA",
            )

            concern = NoEmojis.new(field: :city, address: address).evaluate

            expected_concern = {
              field_names: [:city],
              message: "City cannot contain emojis",
              code: :city_contains_emojis,
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
