# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Country
          class ValidForZipTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is not valid for zip code" do
              address = build_address_obj(zip: "ASCN 1ZZ", country_code: "GB")

              concern = ValidForZip.new(field: :country, address: address).evaluate

              expected_concern =
                {
                  field_names: [:country, :zip],
                  message: I18n.t("worldwide.GB.addresses.zip.errors.invalid_for_country"),
                  code: :country_invalid_for_zip,
                  type: "error",
                  type_level: 1,
                }

              expected_suggestion =
                {
                  address1: "",
                  address2: "",
                  city: "",
                  zip: "ASCN 1ZZ",
                  province_code: "",
                  province: nil,
                  country_code: "AC",
                }

              assert_equal expected_concern, concern&.attributes&.except(:suggestion_ids)
              assert_equal expected_suggestion, concern&.suggestion&.attributes&.except(:id)
            end

            test "does not return a concern when zip is invalid for all countries" do
              address = build_address_obj(zip: "XXXXX", country_code: "GB")
              assert_nil ValidForZip.new(field: :country, address: address).evaluate
            end
          end
        end
      end
    end
  end
end
