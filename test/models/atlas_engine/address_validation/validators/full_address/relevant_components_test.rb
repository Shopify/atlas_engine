# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class RelevantComponentsTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          include AddressValidation::TokenHelper
          include StatsD::Instrument::Assertions

          class DummyExclusion
            class << self
              def apply?(_candidate, mock_address_comparison)
                true
              end
            end
          end

          setup do
            @address = create_address
            @matching_strategy = AddressValidation::MatchingStrategies::EsStreet
            @candidate = candidate(@address)
            @all_components = [
              :province_code,
              :city,
              :zip,
              :street,
            ]
            @address_comparison = mock_address_comparison
          end

          test "#components_to_compare returns an array of all supported components" do
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components,
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
            end
          end

          test "#components_to_validate returns an array without the street component when matching strategy is not EsStreet" do
            matching_strategy = AddressValidation::MatchingStrategies::Es

            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components,
                RelevantComponents.new(@address_comparison, matching_strategy).components_to_compare
              assert_equal @all_components - [:street],
                RelevantComponents.new(@address_comparison, matching_strategy).components_to_validate
            end
          end

          test "#components_to_validate returns an array without the street component when there is no street comparison" do
            @address_comparison.street_comparison.stubs(:sequence_comparison).returns(nil)

            assert_statsd_increment(
              "AddressValidation.skip",
              times: 1,
              tags: { component: "street", reason: "not_found", country: @address.country_code },
            ) do
              assert_equal @all_components,
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
              assert_equal @all_components - [:street],
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_validate
            end
          end

          test "#components_to_validate returns an array without excluded components when exclusions apply" do
            validation = mock
            validation.expects(:validation_exclusions).with(component: :province_code).returns([])
            validation.expects(:validation_exclusions).with(component: :zip).returns([])
            validation.expects(:validation_exclusions).with(component: :street).returns([DummyExclusion])
            validation.expects(:validation_exclusions).with(component: :city).returns([DummyExclusion])

            mock_profile = instance_double(CountryProfile)
            mock_profile.stubs(:validation).returns(validation)

            CountryProfile.expects(:for).with(@address.country_code).returns(mock_profile)

            assert_statsd_increment(
              "AddressValidation.skip",
              times: 1,
              tags: { component: "street", reason: "excluded", country: @address.country_code },
            ) do
              assert_statsd_increment(
                "AddressValidation.skip",
                times: 1,
                tags: { component: "city", reason: "excluded", country: @address.country_code },
              ) do
                assert_equal @all_components,
                  RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
                assert_equal @all_components - [:street, :city],
                  RelevantComponents.new(@address_comparison, @matching_strategy).components_to_validate
              end
            end
          end

          test "#components_to_compare returns an array without province_code when a country does not use provinces in addresses" do
            @address = create_address(
              address1: "237 Rue de la Convention",
              zip: "75015",
              country_code: "FR",
              city: "Paris",
            )
            @candidate = candidate(@address)
            @address_comparison = mock_address_comparison
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code],
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
            end
          end

          test "#components_to_compare returns an array without province_code when a country hides provinces" do
            @address = create_address(
              address1: "Easter Shian Farm 1",
              city: "Dunkeld",
              zip: "PH8 0DB",
              province_code: "SCT",
              country_code: "GB",
            )
            @candidate = candidate(@address)
            @address_comparison = mock_address_comparison

            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code],
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
            end
          end

          test "#components_to_compare returns an array without zip when a country does not use zips in addresses" do
            @address = create_address(address1: "34-6th Crescent", country_code: "ZW", city: "Harare")
            @candidate = candidate(@address)
            @address_comparison = mock_address_comparison

            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code, :zip],
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
            end
          end

          test "#components_to_compare returns an array without city when a country does not use cities in addresses" do
            @address = create_address(address1: "Apostolic Palace", country_code: "VA", city: "Harare", zip: "00120")
            @candidate = candidate(@address)
            @address_comparison = mock_address_comparison

            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:city, :province_code, :zip],
                RelevantComponents.new(@address_comparison, @matching_strategy).components_to_compare
            end
          end

          private

          def candidate(address)
            candidate_hash = address.to_h.transform_keys(address1: :street)
            AddressValidation::Candidate.new(id: "A", source: candidate_hash)
          end

          def create_address(address1: "123 Main Street", zip: "94102", country_code: "US", city: "San Francisco",
            province_code: "CA")
            build_address(
              address1: address1,
              city: city,
              province_code: province_code,
              country_code: country_code,
              zip: zip,
            )
          end

          def mock_address_comparison
            street_comparison_mock = mock
            street_comparison_mock.stubs(:sequence_comparison).returns(sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "street"), right: token(value: "street")),
              ],
            ))

            typed_mock(AddressComparison).tap do |mock|
              mock.stubs(:street_comparison).returns(street_comparison_mock)
              mock.stubs(:relevant_components).returns(@all_components)
              mock.stubs(:candidate).returns(@candidate)
              mock.stubs(:address).returns(@address)
            end
          end

          def building_comparison(numbers:, candidate_ranges:)
            NumberComparison.new(numbers: numbers, candidate_ranges: candidate_ranges)
          end
        end
      end
    end
  end
end
