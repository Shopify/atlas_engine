# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownAddressConcernTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::UnknownAddressConcern
            @suggestion_ids = []
          end

          test "#attributes concern" do
            concern = @klass.new(build_address(country_code: "us"))

            expected_attributes = {
              field_names: [:address1],
              message: "Address not found or does not exist",
              code: :address_unknown,
              type: "warning",
              type_level: 1,
              suggestion_ids: [],
            }
            assert_equal expected_attributes, concern.attributes
          end
        end
      end
    end
  end
end
