# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ComponentsToValidateTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          include AddressValidation::TokenHelper
          include StatsD::Instrument::Assertions

          class DummyExclusion
            class << self
              def apply?(_session, _candidate)
                true
              end
            end
          end

          setup do
            @address = create_address
            @session = session(@address, AddressValidation::MatchingStrategies::EsStreet)
            @candidate = candidate(@address)
            @street_comparison = default_street_comparison
            @all_components = ComponentsToValidate::ALL_SUPPORTED_COMPONENTS
          end

          test "#run returns an array of all supported components" do
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components,
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without the street component when matching strategy is not EsStreet" do
            session = session(@address, AddressValidation::MatchingStrategies::Es)

            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:street],
                ComponentsToValidate.new(session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without the street component when there is no street comparison" do
            assert_statsd_increment(
              "AddressValidation.skip",
              times: 1,
              tags: { component: "street", reason: "not_found", country: @session.country_code },
            ) do
              assert_equal @all_components - [:street],
                ComponentsToValidate.new(@session, @candidate, nil).run
            end
          end

          test "#run returns an array without the street component when a street exclusion applies" do
            validation = mock
            validation.expects(:validation_exclusions).with(component: "street").returns([DummyExclusion])
            mock_profile = instance_double(CountryProfile)
            mock_profile.stubs(:validation).returns(validation)

            CountryProfile.expects(:for).with(@session.country_code).returns(mock_profile)

            assert_statsd_increment(
              "AddressValidation.skip",
              times: 1,
              tags: { component: "street", reason: "excluded", country: @session.country_code },
            ) do
              assert_equal @all_components - [:street],
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without province_code when a country does not use provinces in addresses" do
            @address = create_address(
              address1: "237 Rue de la Convention",
              zip: "75015",
              country_code: "FR",
              city: "Paris",
            )
            @session = session(@address, AddressValidation::MatchingStrategies::EsStreet)
            @candidate = candidate(@address)
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code],
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without province_code when a country hides provinces" do
            @address = create_address(
              address1: "Easter Shian Farm 1",
              city: "Dunkeld",
              zip: "PH8 0DB",
              province_code: "SCT",
              country_code: "GB",
            )
            @session = session(@address, AddressValidation::MatchingStrategies::EsStreet)
            @candidate = candidate(@address)
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code],
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without zip when a country does not use zips in addresses" do
            @address = create_address(address1: "34-6th Crescent", country_code: "ZW", city: "Harare")
            @session = session(@address, AddressValidation::MatchingStrategies::EsStreet)
            @candidate = candidate(@address)
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:province_code, :zip],
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          test "#run returns an array without city when a country does not use cities in addresses" do
            @address = create_address(address1: "Apostolic Palace", country_code: "VA", city: "Harare", zip: "00120")
            @session = session(@address, AddressValidation::MatchingStrategies::EsStreet)
            @candidate = candidate(@address)
            assert_no_statsd_calls("AddressValidation.skip") do
              assert_equal @all_components - [:city, :province_code, :zip],
                ComponentsToValidate.new(@session, @candidate, @street_comparison).run
            end
          end

          private

          def session(address, matching_strategy)
            AddressValidation::Session.new(
              address: address,
              matching_strategy: matching_strategy,
            ).tap do |session|
              # setting the street and city sequences leads the Datastore to skip the actual ES _analyze requests.
              sequences_for(session)
            end
          end

          def sequences_for(session)
            session.datastore.street_sequences = [
              AtlasEngine::AddressValidation::Token::Sequence.from_string(session.address1),
            ]
            session.datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(session.city)
          end

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

          def default_street_comparison
            sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "street"), right: token(value: "street")),
              ],
            )
          end

          def building_comparison(numbers:, candidate_ranges:)
            NumberComparison.new(numbers: numbers, candidate_ranges: candidate_ranges)
          end
        end
      end
    end
  end
end
