# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Street
          class BuildingNumberInAddress1OrAddress2Test < ActiveSupport::TestCase
            include AddressValidationTestHelper
            test "when is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )
              assert_nil BuildingNumberInAddress1OrAddress2.new(field: :address1, address: address).evaluate
            end

            test "when missing building number in address1 and address2" do
              address = build_address_obj(
                address1: "Singel",
                address2: "Foo",
                city: "Amsterdam",
                zip: "1017 AZ",
                country_code: "NL",
              )

              concern = BuildingNumberInAddress1OrAddress2.new(field: :address1, address: address).evaluate

              expected_concern =
                {
                  field_names: [:address1, :address2, :country],
                  message: "Add a building number if you have one.",
                  code: :missing_building_number,
                  type: "warning",
                  type_level: 3,
                  suggestion_ids: [],
                }

              assert_equal expected_concern, concern&.attributes
            end

            test "when missing building number in address1 but it's present (and allowed) in address2" do
              address = build_address_obj(
                address1: "Marinierskade",
                address2: "7",
                city: "Amsterdam",
                zip: "1018 HX",
                country_code: "NL",
              )

              assert_nil BuildingNumberInAddress1OrAddress2.new(field: :address1, address: address).evaluate
            end
          end
        end
      end
    end
  end
end
