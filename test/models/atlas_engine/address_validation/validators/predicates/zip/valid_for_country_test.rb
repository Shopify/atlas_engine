# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class ValidForCountryTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil ValidForCountry.new(field: :zip, address: address).evaluate
            end

            test "when zip is not valid for country" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "XXXYYY",
                country_code: "CA",
              )
              concern = ValidForCountry.new(field: :zip, address: address).evaluate

              expected_concern = {
                field_names: [:zip, :country],
                code: :zip_invalid_for_country,
                message: I18n.t(
                  "worldwide._default.addresses.zip.errors.invalid_for_country",
                  country: "Canada",
                ),
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end
            test "is not valid message translates the country name" do
              address = build_address_obj(
                address1: "上野公園１３−9",
                city: "台東区",
                province_code: "JP-13",
                zip: "Bogus",
                country_code: "JP",
              )
              I18n.with_locale(:ja) do
                concern = ValidForCountry.new(field: :zip, address: address).evaluate

                expected_concern = {
                  field_names: [:zip, :country],
                  code: :zip_invalid_for_country,
                  message: I18n.t("worldwide._default.addresses.zip.errors.invalid_for_country", country: "日本"),
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
end
