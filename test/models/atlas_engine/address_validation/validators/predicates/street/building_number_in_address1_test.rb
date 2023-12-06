# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Street
          class BuildingNumberInAddress1Test < ActiveSupport::TestCase
            include AddressValidationTestHelper
            test "when is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )
              assert_nil BuildingNumberInAddress1.new(field: :address1, address: address).evaluate
            end

            test "when building number is not required" do
              address = build_address_obj(
                address1: "Noor Khan Bazar Rd",
                address2: "near United Bakery",
                city: "Hyderabad",
                province_code: "TG",
                zip: "500024",
                country_code: "IN",
              )
              assert_nil BuildingNumberInAddress1.new(field: :address1, address: address).evaluate
            end

            test "when missing building number in address1" do
              address = build_address_obj(
                address1: "Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              concern = BuildingNumberInAddress1.new(field: :address1, address: address).evaluate

              expected_concern = {
                field_names: [:address1, :country],
                message: "Add a building number if you have one.",
                code: :missing_building_number,
                type: "warning",
                type_level: 1,
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
