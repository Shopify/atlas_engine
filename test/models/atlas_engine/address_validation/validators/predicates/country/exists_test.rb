# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Country
          class ExistsTest < ActiveSupport::TestCase
            include AddressValidationTestHelper

            test "when is valid" do
              address = build_address_obj(country_code: "CA")

              assert_nil Exists.new(field: :country, address: address).evaluate
            end

            test "when is invalid" do
              address = build_address_obj(country_code: "XX")

              concern = Exists.new(field: :country, address: address).evaluate

              expected_concern =
                {
                  field_names: [:country],
                  message: I18n.t("worldwide._default.addresses.country.errors.blank"),
                  code: :country_blank,
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
