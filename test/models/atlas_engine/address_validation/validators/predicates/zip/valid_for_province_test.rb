# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class ValidForProvinceTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil ValidForProvince.new(field: :zip, address: address).evaluate
            end

            test "when zip is not valid for province" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Toronto",
                province_code: "ON",
                zip: "V6B 4Y8",
                country_code: "CA",
              )
              concern = ValidForProvince.new(field: :zip, address: address).evaluate

              expected_concern = {
                field_names: [:zip, :country, :province],
                message: I18n.t(
                  "worldwide._default.addresses.zip.errors.invalid_for_province",
                  province: Worldwide.region(code: "CA").zone(code: "ON").full_name,
                ),
                code: :zip_invalid_for_province,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end
            test "is not valid for province message translates the country name" do
              address = build_address_obj(
                # Gyeongbokgung Palace
                address1: "사직로 161", # 161 Sajik-ro
                city: "종로구", # Jongno-gu
                province_code: "KR-11", # Seoul
                country_code: "KR",
                zip: "47333", # This is in Busan, the other end of the country, therefore invalid for Seoul
              )
              I18n.with_locale(:ko) do
                concern = ValidForProvince.new(field: :zip, address: address).evaluate

                expected_concern = {
                  field_names: [:zip, :country, :province],
                  message: I18n.t(
                    "worldwide._default.addresses.zip.errors.invalid_for_province",
                    province: Worldwide.region(code: "KR").zone(code: "KR-11").full_name,
                  ),
                  code: :zip_invalid_for_province,
                  type: "error",
                  type_level: 3,
                  suggestion_ids: [],
                }

                assert_equal expected_concern, concern&.attributes
              end
            end

            test "when zip won't match due to lack of source data, but province is a US territory" do
              address = build_address_obj(
                zip: "00725",
                province_code: "PR",
                country_code: "US",
              )

              assert_nil ValidForProvince.new(field: :zip, address: address).evaluate
            end

            test "no concerns when matching_validation request paramater defaults to false" do
              address = build_address_obj(
                zip: "35000", province_code: "AL", country_code: "US",
              )
              assert_nil(ValidForProvince.new(field: :zip, address: address).evaluate)
            end

            test "when is not valid for province, but country hides provinces" do
              # province should be SCT, but it's hidden anyway
              address = build_address_obj(
                zip: "PH8 0DB", province_code: "ENG", country_code: "GB",
              )

              assert_nil(ValidForProvince.new(field: :zip, address: address).evaluate)
            end
          end
        end
      end
    end
  end
end
