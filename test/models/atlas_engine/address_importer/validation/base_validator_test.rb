# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/address_importer_test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      class BaseValidatorTest < ActiveSupport::TestCase
        include AddressImporterTestHelper

        module FieldValidations
          class MockValidValidator
            def initialize(address:, allow_partial_zip:)
            end

            def validation_errors
              []
            end
          end

          class MockInvalidValidator
            def initialize(address:, allow_partial_zip:)
            end

            def validation_errors
              ["this is invalid"]
            end
          end

          class MockAnotherInvalidValidator
            def initialize(address:, allow_partial_zip:)
            end

            def validation_errors
              ["this is also invalid"]
            end
          end
        end

        def setup
          @address = build_post_address_struct
        end

        test "#validation_errors returns a hash with empty values when address is valid" do
          validator = BaseValidator.new(
            country_code: @address.country_code,
            field_validations: { province_code: [FieldValidations::MockValidValidator] },
          )
          expected = { province_code: [] }
          assert_equal expected, validator.validation_errors(address: @address)
        end

        test "#validation_errors stops after first error is encountered" do
          validator = BaseValidator.new(
            country_code: @address.country_code,
            field_validations: {
              province_code: [FieldValidations::MockValidValidator],
              zip: [FieldValidations::MockInvalidValidator],
              city: [FieldValidations::MockInvalidValidator],
            },
          )

          expected = {
            province_code: [],
            zip: ["this is invalid"],
          }
          assert_equal expected, validator.validation_errors(address: @address)
        end

        test "#validation_errors resets errors on each call" do
          validator = BaseValidator.new(
            country_code: @address.country_code,
            field_validations: {
              province_code: [FieldValidations::MockValidValidator],
              zip: [FieldValidations::MockInvalidValidator],
            },
          )
          validator.validation_errors(address: @address)

          validation_errors = validator.validation_errors(address: @address)

          assert_equal [], validation_errors[:province_code]
          assert_equal ["this is invalid"], validation_errors[:zip]
        end

        test "#validation_errors passes allow_partial_zip: setting to individual validators" do
          invalid_validator_mock = mock
          invalid_validator_mock.stubs(:validation_errors).returns([])

          FieldValidations::MockInvalidValidator.expects(:new).with(
            address: @address,
            allow_partial_zip: true,
          ).returns(invalid_validator_mock)

          validator = BaseValidator.new(
            country_code: "IE",
            field_validations: {
              province_code: [FieldValidations::MockInvalidValidator],
            },
          )
          validator.validation_errors(address: @address)
        end

        test "#validation_errors validates and merges results from additional_field_validations if provided" do
          validator = BaseValidator.new(
            country_code: @address.country_code,
            field_validations: {
              province_code: [FieldValidations::MockValidValidator],
              zip: [FieldValidations::MockValidValidator],

            },
            additional_field_validations: {
              zip: [FieldValidations::MockAnotherInvalidValidator],
            },
          )

          expected = {
            province_code: [],
            zip: ["this is also invalid"],
          }
          assert_equal expected, validator.validation_errors(address: @address)
        end
      end
    end
  end
end
