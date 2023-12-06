# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Street
          class PresentTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )

              assert_nil Present.new(field: :address1, address: address).evaluate
            end

            test "when street is not present" do
              address = build_address_obj(
                address1: nil,
                city: "Vancouver",
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )
              concern = Present.new(field: :address1, address: address).evaluate

              expected_concern = {
                field_names: [:address1],
                message: I18n.t("worldwide._default.addresses.address1.errors.blank"),
                code: :address1_blank,
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
