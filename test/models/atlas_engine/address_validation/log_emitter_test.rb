# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "address_validation_test_helper"
require "helpers/atlas_engine/log_assertion_helper"

module AtlasEngine
  module AddressValidation
    class LogEmitterTest < ActiveSupport::TestCase
      include AddressValidationTestHelper
      include LogAssertionHelper

      def setup
        @address = build_address(province_code: "BC", country_code: "CA")
        @result = AddressValidation::Result.new

        @concern_codes = [
          :zip_inconsistent,
          :zip_invalid_for_country,
          :city_inconsistent,
          :country_blank,
          :province_blank,
          :phone_invalid,
          :missing_building_number,
          :street_inconsistent,
          :address1_contains_html_tags,
          :address2_contains_html_tags,
        ]

        @log_emitter = AddressValidation::LogEmitter.new(
          address: @address,
          result: @result,
        )
      end

      test "#run returns the correct log when there are concerns with suggestions" do
        suggestion = Suggestion.new(
          address1: "777 Pacific Blvd",
          address2: "",
          city: "Vancouver",
          province_code: "BC",
          zip: "V6B 4Y8",
          country_code: "CA",
        )

        @result.add_suggestions([suggestion])

        @concern_codes.each do |code|
          @result.add_concern(
            field_names: [],
            message: "foo",
            code: code,
            type: "foo",
            type_level: 3,
            suggestion_ids: [suggestion.id],
          )
        end

        expected_concern_codes = [
          :country_blank,
          :province_blank,
          :zip_inconsistent,
          :zip_invalid_for_country,
          :city_inconsistent,
          :missing_building_number,
          :street_inconsistent,
          :address1_contains_html_tags,
          :address2_contains_html_tags,
          :phone_invalid,
        ]

        assert_log_append(
          :info,
          "AtlasEngine::AddressValidation::LogEmitter",
          "[AddressValidation] Concern(s) found when validating address",
          {
            country_code: "CA",
            formatted_address: "BC, Canada",
            concerns: expected_concern_codes,
            suggestions: [suggestion.attributes],
            candidate: nil,
            validation_id: @result.id,
          },
        )

        @log_emitter.run
      end

      test "#run returns the correct log when there are no concerns" do
        assert_log_append(
          :info,
          "AtlasEngine::AddressValidation::LogEmitter",
          "[AddressValidation] Address validated, no concerns returned",
          {
            country_code: "CA",
            formatted_address: "BC, Canada",
            concerns: [],
            suggestions: [],
            candidate: nil,
            validation_id: @result.id,
          },
        )

        @log_emitter.run
      end
    end
  end
end
