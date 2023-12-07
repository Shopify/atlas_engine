# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Province
          class ValidForCountryTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "does not create a concern when province code is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end

            test "recognizes territories and does not create a concern" do
              address = build_address_obj(
                province_code: "PR",
                country_code: "US",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province code is absent" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province code is provided as subdivision code" do
              address = build_address_obj(
                address1: "2 Chome-10-19 Minamiazabu",
                city: "Minato",
                province_code: "13",
                zip: "106-0047",
                country_code: "JP",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end

            test "creates a concern when province code is present and is invalid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "XX",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              expected_concern =
                {
                  field_names: [:province, :country],
                  message: I18n.t("worldwide.CA.addresses.province.errors.blank"),
                  code: :province_invalid,
                  type: "error",
                  type_level: 3,
                  suggestion_ids: [],
                }

              concern = ValidForCountry.new(field: :province, address: address).evaluate
              assert_equal expected_concern, concern&.attributes
            end

            test "does not create a concern when province code is present but country has no defined zones" do
              address = build_address_obj(
                address1: "RTL Television 1",
                city: "Berlin",
                province_code: "BE",
                zip: "10117",
                country_code: "DE",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end

            test "does not create a concern when province code is present but country hides zones from address" do
              address = build_address_obj(
                address1: "14-28 Oxford St",
                city: "London",
                province_code: "ZZ",
                zip: "W1D 1AU",
                country_code: "GB",
              )

              assert_nil ValidForCountry.new(field: :province, address: address).evaluate
            end
          end
        end
      end
    end
  end
end
