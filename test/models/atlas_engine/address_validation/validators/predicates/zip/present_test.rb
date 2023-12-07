# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class PresentTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil Present.new(field: :zip, address: address).evaluate
            end

            test "when zip is not present but country and province are present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: nil,
                country_code: "CA",
              )
              concern = Present.new(field: :zip, address: address).evaluate

              expected_concern = {
                field_names: [:zip],
                code: :zip_blank,
                message: I18n.t(
                  "worldwide._default.addresses.zip.errors.invalid_for_province",
                  province: "British Columbia",
                ),
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end

            test "when zip is not present but only country is present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: nil,
                zip: nil,
                country_code: "CA",
              )
              concern = Present.new(field: :zip, address: address).evaluate

              expected_concern = {
                field_names: [:zip],
                code: :zip_blank,
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

            test "when zip is valid (optional, not present zip, province_code)" do
              address = build_address_obj(
                address1: "J87H+39C",
                city: "Kinhasa",
                country_code: "CG",
              )
              assert_nil Present.new(field: :zip, address: address).evaluate
            end

            test "when zip is valid (optional, not present zip)" do
              address = build_address_obj(
                address1: "Calle Independencia entre Munoz y",
                city: "San Fernando de Apure 7001",
                province_code: "VE-C",
                country_code: "VE",
              )
              assert_nil Present.new(field: :zip, address: address).evaluate
            end

            test "when is valid (optional zip, value provided in zip field)" do
              address = build_address_obj(
                address1: "Tahir Guest Palace",
                address2: "4 Ibrahim Natsugune Road",
                city: "Kano",
                zip: "700213",
                country_code: "NG",
              )
              assert_nil Present.new(field: :zip, address: address).evaluate
            end

            test "when country has no postal code" do
              address = build_address_obj(
                country_code: "AO",
              )
              assert_nil Present.new(field: :zip, address: address).evaluate
            end

            test "zip may be null in countries where there's an autofill defined" do
              address = build_address_obj(
                address1: "236 Poon Saan Rd",
                address2: nil,
                city: "Christmas Island",
                zip: nil, # should autofill to "6798"
                country_code: "CX",
              )

              assert_nil Present.new(field: :zip, address: address).evaluate
            end
          end
        end
      end
    end
  end
end
