# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class CityComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#sequence_comparison compares the analyzed city with the candidate city field" do
            candidate = Candidate.new(id: "A", source: { "city" => ["Bronx"] })
            address = build_address(city: "The Bronx", country_code: "US")

            datastore = Es::Datastore.new(address: address)
            input_city_sequence = Token::Sequence.from_string(address.city)
            datastore.city_sequence = input_city_sequence

            city_comparison = CityComparison.new(address:, candidate:, datastore:, component: :city)

            comparison = city_comparison.sequence_comparison
            candidate_city_sequences = candidate.component(:city).sequences

            comparisons = comparison.token_comparisons

            i_the, i_bronx = input_city_sequence.tokens
            c_bronx = candidate_city_sequences.first.tokens.first

            assert_equal [i_the], comparison.unmatched_tokens
            assert_equal ["Bronx"], candidate_city_sequences.map(&:raw_value)
            assert_equal input_city_sequence, comparison.left_sequence
            assert_equal candidate_city_sequences.first, comparison.right_sequence
            assert_comparison(i_bronx, :equal, c_bronx, comparisons[0])
          end

          test "#sequence_comparison compares the analyzed city with the candidate city field that has multiple values" do
            candidate = Candidate.new(
              id: "A",
              source: { "city" => ["Bronx", "The Bronx", "El Bronxo"] },
            )
            address = build_address(city: "El Bronxo", country_code: "US")
            datastore = Es::Datastore.new(address: address)

            input_city_sequence = Token::Sequence.from_string(address.city)
            datastore.city_sequence = input_city_sequence

            city_comparison = CityComparison.new(address:, candidate:, datastore:, component: :city)

            comparison = city_comparison.sequence_comparison
            candidate_city_sequences = candidate.component(:city).sequences

            comparisons = comparison.token_comparisons
            i_el, i_bronxo = input_city_sequence.tokens
            c_el, c_bronxo = candidate_city_sequences.third.tokens

            assert_predicate comparison.unmatched_tokens, :empty?
            assert_equal ["Bronx", "The Bronx", "El Bronxo"], candidate_city_sequences.map(&:raw_value)
            assert_equal input_city_sequence, comparison.left_sequence
            assert_equal candidate_city_sequences.third, comparison.right_sequence
            assert_comparison(i_el, :equal, c_el, comparisons[0])
            assert_comparison(i_bronxo, :equal, c_bronxo, comparisons[1])
          end
        end
      end
    end
  end
end
