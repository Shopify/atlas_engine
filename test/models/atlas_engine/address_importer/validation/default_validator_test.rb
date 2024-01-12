# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      class DefaultValidatorTest < ActiveSupport::TestCase
        test ".new initializes a validator with the expected params" do
          expected_validations = {
            province_code: [AddressImporter::Validation::FieldValidations::Province],
            zip: [AddressImporter::Validation::FieldValidations::Zip],
            city: [AddressImporter::Validation::FieldValidations::City],
          }

          actual = DefaultValidator.new(country_code: "CA")
          assert_equal expected_validations, actual.field_validations
        end

        test ".new initializes the base_validator with additional_field_validations" do
          original_additional_validations = AtlasEngine.address_importer_additional_field_validations

          {
            province_code: [AddressImporter::Validation::FieldValidations::Province],
            zip: [AddressImporter::Validation::FieldValidations::Zip],
            city: [AddressImporter::Validation::FieldValidations::City],
          }

          expected_additional_validations = {
            zip: [AddressImporter::Validation::FieldValidations::Zip],
          }

          AtlasEngine.address_importer_additional_field_validations = expected_additional_validations

          actual = DefaultValidator.new(country_code: "CA")
          assert_equal(expected_additional_validations, actual.additional_field_validations)
        ensure
          AtlasEngine.address_importer_additional_field_validations = original_additional_validations
        end
      end
    end
  end
end
