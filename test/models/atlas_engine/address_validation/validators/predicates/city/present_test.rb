# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module City
          class PresentTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(
                address1: "7 Ch des Loisirs",
                city: "Baie-Sainte-Catherine",
                province_code: "QC",
                zip: "G0T 1A0",
                country_code: "CA",
              )

              assert_nil Present.new(field: :city, address: address).evaluate
            end

            test "when city is not present" do
              address = build_address_obj(
                address1: "777 Pacific Blvd",
                city: nil,
                province_code: "BC",
                zip: "V6B 4Y8",
                country_code: "CA",
              )
              concern = Present.new(field: :city, address: address).evaluate

              expected_concern = {
                field_names: [:city],
                message: I18n.t("worldwide._default.addresses.city.errors.blank"),
                code: :city_blank,
                type: "error",
                type_level: 3,
                suggestion_ids: [],
              }

              assert_equal expected_concern, concern&.attributes
            end

            test "when city is not present, but country only has one city" do
              address = build_address_obj(
                country_code: "GI",
              )

              assert_nil Present.new(field: :city, address: address).evaluate
            end
          end
        end
      end
    end
  end
end
