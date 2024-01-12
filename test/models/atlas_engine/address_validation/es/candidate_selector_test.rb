# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class CandidateSelectorTest < ActiveSupport::TestCase
        include AddressValidationTestHelper
        include StatsD::Instrument::Assertions

        setup do
          @address = build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
          @datastore = Es::Datastore.new(address: @address)
          @datastore.city_sequence = Token::Sequence.from_string(@address.city)
          @datastore.street_sequences = [
            Token::Sequence.from_string(@address.address1),
          ]
        end

        test "picks the candidate having the best merged comparison compared to the address" do
          @datastore.candidates = [
            candidate(city: "San Fransauceco"), # close
            candidate(city: "Man Francisco"), # best match, off by one letter on one field
            candidate(city: "Saint Fransauceco"),
          ]

          best_candidate = CandidateSelector.new(datastore: @datastore, address: @address).best_candidate

          assert_equal "Man Francisco", best_candidate.candidate.component(:city).value
        end

        test "asynchronously determines the candidate having the best merged comparison compared to the address" do
          @datastore.candidates = [
            candidate(city: "San Fransauceco"), # close
            candidate(city: "Man Francisco"), # best match, off by one letter on one field
            candidate(city: "Saint Fransauceco"),
          ]

          best_candidate = CandidateSelector.new(datastore: @datastore, address: @address).best_candidate_async.value!

          assert_equal "Man Francisco", best_candidate.candidate.component(:city).value
        end

        test "asynchronously fetches city and street sequences" do
          @datastore.candidates = [candidate] # candidate is a perfect match.
          @datastore.expects(:fetch_street_sequences_async)
            .returns(Concurrent::Promises.fulfilled_future([]))
          @datastore.expects(:fetch_city_sequence_async)
            .returns(
              Concurrent::Promises.fulfilled_future(Token::Sequence.from_string("")),
            )

          best_candidate = CandidateSelector.new(datastore: @datastore, address: @address).best_candidate

          assert_equal candidate.id, best_candidate.candidate.id
          assert_equal 1, best_candidate.position
          assert best_candidate.address_comparison.present?
        end

        test "tracks the initial position of the top candidate when candidates are defined" do
          @datastore.candidates = [
            candidate(city: "San Fransauceco"), # close
            candidate(city: "Man Francisco"), # best match, off by one letter on one field
            candidate(city: "Saint Fransauceco"),
          ]

          assert_statsd_distribution("AddressValidation.query.initial_position_top_candidate", 2) do
            CandidateSelector.new(datastore: @datastore, address: @address).best_candidate
          end
        end

        test "tracks an initial position of 0 when there are no candidates" do
          @datastore.candidates = []

          assert_statsd_distribution("AddressValidation.query.initial_position_top_candidate", 0) do
            CandidateSelector.new(datastore: @datastore, address: @address).best_candidate
          end
        end

        private

        def candidate(overrides = {})
          candidate_hash = @address.to_h.transform_keys(address1: :street).merge(overrides)
          AddressValidation::Candidate.new(id: "A", source: candidate_hash)
        end
      end
    end
  end
end
