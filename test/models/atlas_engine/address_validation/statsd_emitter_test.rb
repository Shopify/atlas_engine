# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    class StatsdEmitterTest < ActiveSupport::TestCase
      include AddressValidationTestHelper
      include StatsD::Instrument::Assertions

      def setup
        @address = build_address(province_code: "BC", country_code: "CA")
        @result = AddressValidation::Result.new

        concern_codes = [
          :zip_inconsistent,
          :city_inconsistent,
          :country_blank,
          :province_blank,
          :phone_invalid,
          :missing_building_number,
          :street_inconsistent,
          :address1_contains_html_tags,
          :address2_contains_html_tags,
        ]
        concern_codes.each do |code|
          @result.add_concern(
            field_names: [],
            message: "foo",
            code: code,
            type: "foo",
            type_level: 3,
            suggestion_ids: [],
          )
        end

        @statsd_emitter = AddressValidation::StatsdEmitter.new(
          address: @address,
          result: @result,
        )
      end

      test "#run emits when valid, in english" do
        components = [:country, :province, :zip, :city, :street, :building_number, :phone]
        I18n.with_locale(:de) do
          components.each do |component|
            assert_statsd_increment(
              "AddressValidation.valid",
              times: 1,
              tags: {
                country: "CA",
                component: component,
              },
            ) do
              AddressValidation::StatsdEmitter.new(
                address: @address,
                result: AddressValidation::Result.new,
              ).run
            end
          end
        end
      end

      test "#emits when country is nil" do
        address = build_address(province_code: "BC")

        I18n.with_locale(:de) do
          assert_statsd_increment(
            "AddressValidation.valid",
            times: 1,
            tags: {
              country: "no_country",
              component: "city",
            },
          ) do
            AddressValidation::StatsdEmitter.new(
              address: address,
              result: AddressValidation::Result.new,
            ).run
          end
        end
      end

      test "#run emits invalid when atleast 1 relevant concern found" do
        expected_concern = AddressValidation::Concern.new(
          field_names: [:city, :country],
          code: :address1_a_valid_concern,
          message: "",
          type: AddressValidation::Concern::TYPES[:warning],
          type_level: 2,
          suggestion_ids: [],
        )

        assert_statsd_increment(
          "AddressValidation.invalid",
          times: 1,
          tags: {
            country: "CA",
            component: "street",
            code: :address1_a_valid_concern,
            type: AddressValidation::Concern::TYPES[:warning],
          },
        ) do
          AddressValidation::StatsdEmitter.new(
            address: @address,
            result: AddressValidation::Result.new(concerns: [expected_concern]),
          ).run
        end
      end

      test "#component_concerns returns the correct concerns" do
        components = [:country, :province, :zip, :city, :street, :building_number, :phone]
        expected_return_values = {
          country: [:country_blank],
          province: [:province_blank],
          zip: [:zip_inconsistent],
          city: [:city_inconsistent],
          street: [
            :street_inconsistent,
            :address1_contains_html_tags,
            :address2_contains_html_tags,
          ],
          building_number: [:missing_building_number],
          phone: [:phone_invalid],
        }
        actual_return_values = {}

        components.each do |component|
          actual_return_values[component] = @statsd_emitter.component_concerns(component).map do |concern|
            concern.attributes[:code]
          end
        end

        assert_equal expected_return_values, actual_return_values
      end
    end
  end
end
