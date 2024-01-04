# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownZipForAddressConcernTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::UnknownZipForAddressConcern
            @suggestion_ids = []
          end

          test "#attributes concern" do
            concern = @klass.new(build_address(address1: "123 Some St W", city: "Some Town"), @suggestion_ids)

            expected_attributes = {
              field_names: [:zip],
              message: "Enter a valid ZIP for 123 Some St W, Some Town",
              code: :zip_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end
        end
      end
    end
  end
end
