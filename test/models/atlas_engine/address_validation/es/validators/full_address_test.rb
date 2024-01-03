# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddressTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          include StatsD::Instrument::Assertions

          setup do
            @klass = AddressValidation::Es::Validators::FullAddress
            @address = address
            @session = AddressValidation::Session.new(address: @address)
            # prime session cache to avoid calls to the DB in Datastore
            @session.datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.city)
            @session.datastore.street_sequences = [
              AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.address1),
            ]
          end

          test "does not modify the result if there are existing error concerns related to other address fields" do
            @session.expects(:datastore).never

            [:country, :province, :zip, :city, :address1, :address2].each do |scope|
              result = AddressValidation::Result.new
              concern = result.add_concern(
                code: :i_r_teh_winnar,
                type: Concern::TYPES[:error],
                type_level: 1,
                suggestion_ids: [],
                field_names: [scope],
                message: "I R teH winn4rrr !!11!",
              )

              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
              assert_equal [concern], result.concerns
            end
          end

          test "does not modify the result if there are addrees1 or address2 tokens exceed max count" do
            @session.expects(:datastore).never

            [:address1, :address2].each do |scope|
              result = AddressValidation::Result.new
              concern = result.add_concern(
                code: "#{scope}_contains_too_many_words".to_sym,
                type: Concern::TYPES[:warning],
                type_level: 1,
                suggestion_ids: [],
                field_names: [scope],
                message: "I R teH winn4rrr !!11!",
              )

              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
              assert_equal [concern], result.concerns
            end
          end

          test "proceeds with full address validation when there are only warning-level concerns" do
            @session.datastore.candidates = [candidate] # candidate is a perfect match.

            result = AddressValidation::Result.new
            result.add_concern(
              field_names: [:address1, :country],
              message: :missing_building_number.to_s.humanize,
              code: :missing_building_number,
              type: Concern::TYPES[:warning],
              type_level: 1,
              suggestion_ids: [],
            )

            AddressValidation::Validators::FullAddress::CandidateResult.any_instance.expects(:update_result)
            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate
            assert_equal 1, result.concerns.size
            assert_equal :missing_building_number, result.concerns.first.code
          end

          test "asynchronously fetches city and street sequences" do
            @session.datastore.candidates = [candidate] # candidate is a perfect match.

            result = AddressValidation::Result.new
            @session.datastore.expects(:fetch_street_sequences_async)
              .returns(Concurrent::Promises.fulfilled_future([]))
            @session.datastore.expects(:fetch_city_sequence_async)
              .returns(
                Concurrent::Promises.fulfilled_future(AtlasEngine::AddressValidation::Token::Sequence.from_string("")),
              )

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate
            assert_empty(result.concerns)
          end

          test "does not query es if the address script is unsupported" do
            @address = address(
              country_code: "KR",
              address1: "123 Main Street", # only the Hangul script is supported in KR
              zip: "94102",
              city: "서울",
            )

            @session = AddressValidation::Session.new(address: @address)
            result = AddressValidation::Result.new

            @session.expects(:datastore).never

            @klass.new(address: @address, result: result).validate
          end

          test "does not query es if validation restrictions apply" do
            @address = address(
              country_code: "GG",
              address1: "1 La Clôture de Bas",
              zip: "GY9 1SD",
              city: "Sark", # Sark is not supported in GG
            )

            @session = AddressValidation::Session.new(address: @address)
            result = AddressValidation::Result.new

            @session.expects(:datastore).never

            @klass.new(address: @address, result: result).validate
          end

          test "queries es when the address script is supported and no validation restrictions apply" do
            @address = address(
              country_code: "KR",
              address1: "자하문로",
              zip: "94102",
              city: "서울",
            )

            @session.datastore.candidates = [candidate]

            result = AddressValidation::Result.new

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate
          end

          test "returns address_unknown if the full address query produces no results" do
            @session.datastore.candidates = []

            result = AddressValidation::Result.new

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :address_unknown, result.concerns.first.code
          end

          test "picks the candidate having the best merged comparison compared to the address" do
            @session.datastore.candidates = [
              candidate(city: "San Fransauceco"), # close
              candidate(city: "Man Francisco"), # best match, off by one letter on one field
              candidate(city: "Saint Fransauceco"),
            ]

            result = AddressValidation::Result.new
            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :city_inconsistent, result.concerns.first.code
            assert_equal "Man Francisco", result.suggestions.first.attributes[:city]
          end

          test "returns invalid_zip_and_province if province is valid and zip prefix is incompatible" do
            @address = address(zip: "84102") # invalid for California
            @session = AddressValidation::Session.new(address: @address)

            @session.datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.city)
            @session.datastore.street_sequences = [
              AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.address1),
            ]
            @session.datastore.candidates = [candidate(zip: "94102")]

            result = AddressValidation::Result.new

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate

            assert_equal 1, result.concerns.size
            assert_equal :zip_invalid_for_province, result.concerns.first.code
            assert_equal "94102", result.suggestions.first.attributes[:zip]
          end

          test "tracks the initial position of the top candidate when candidates are defined" do
            @session.datastore.candidates = [
              candidate(city: "San Fransauceco"), # close
              candidate(city: "Man Francisco"), # best match, off by one letter on one field
              candidate(city: "Saint Fransauceco"),
            ]

            result = AddressValidation::Result.new

            assert_statsd_distribution("AddressValidation.query.initial_position_top_candidate", 2) do
              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
            end
          end

          test "tracks an initial position of 0 when there are no candidates" do
            @session.datastore.candidates = []

            result = AddressValidation::Result.new

            assert_statsd_distribution("AddressValidation.query.initial_position_top_candidate", 0) do
              full_address = @klass.new(address: @address, result: result)
              full_address.session = @session
              full_address.validate
            end
          end

          test "atlas-engine.address_validation.validation_completed notifications event fires for nil best_candidate" do
            @session.datastore.candidates = [] # candidate is nil.
            result = AddressValidation::Result.new(client_request_id: "1234", origin: "https://checkout.shopify.com")

            ActiveSupport::Notifications.expects(:instrument)

            full_address = @klass.new(address: @address, result: result)
            full_address.session = @session
            full_address.validate
          end

          private

          def address(address1: "123 Main Street", zip: "94102", country_code: "US", city: "San Francisco")
            build_address(
              address1: address1,
              city: city,
              province_code: "CA",
              country_code: country_code,
              zip: zip,
            )
          end

          def candidate(overrides = {})
            candidate_hash = @address.to_h.transform_keys(address1: :street).merge(overrides)
            AddressValidation::Candidate.new(id: "A", source: candidate_hash)
          end
        end
      end
    end
  end
end
