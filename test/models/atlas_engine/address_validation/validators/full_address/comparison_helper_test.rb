# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ComparisonHelperTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          test "#street_comparison compares the session street sequences with the candidate street sequences" do
            candidate = Candidate.new(id: "A", source: { "street" => "County Road 34" })
            address = build_address(address1: "1234 County Road 34", country_code: "US")
            datastore = Es::Datastore.new(address: address)
            input_street_sequences = [Token::Sequence.from_string(address.address1)]
            datastore.street_sequences = input_street_sequences

            comparison = ComparisonHelper.street_comparison(datastore: datastore, candidate: candidate)
            candidate_street_sequences = candidate.component(:street).sequences

            comparisons = comparison.token_comparisons
            i_1234, i_county, i_road, i_34 = input_street_sequences.first.tokens
            c_county, c_road, c_34 = candidate_street_sequences.first.tokens

            assert_equal [i_1234], comparison.unmatched_tokens
            assert_equal ["County Road 34"], candidate_street_sequences.map(&:raw_value)
            assert_equal input_street_sequences.first, comparison.left_sequence
            assert_equal candidate_street_sequences.first, comparison.right_sequence
            assert_comparison(i_county, :equal, c_county, comparisons[0])
            assert_comparison(i_road, :equal, c_road, comparisons[1])
            assert_comparison(i_34, :equal, c_34, comparisons[2])
          end

          test "#city_comparison compares the analyzed city with the candidate city field" do
            candidate = Candidate.new(id: "A", source: { "city" => ["Bronx"] })
            address = build_address(city: "The Bronx", country_code: "US")

            datastore = Es::Datastore.new(address: address)
            input_city_sequence = Token::Sequence.from_string(address.city)
            datastore.city_sequence = input_city_sequence

            comparison = ComparisonHelper.city_comparison(datastore: datastore, candidate: candidate)
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

          test "#city_comparison compares the analyzed city with the candidate city field that has multiple values" do
            candidate = Candidate.new(
              id: "A",
              source: { "city" => ["Bronx", "The Bronx", "El Bronxo"] },
            )
            address = build_address(city: "El Bronxo", country_code: "US")
            datastore = Es::Datastore.new(address: address)

            input_city_sequence = Token::Sequence.from_string(address.city)
            datastore.city_sequence = input_city_sequence

            comparison = ComparisonHelper.city_comparison(datastore: datastore, candidate: candidate)
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

          test "#province_code_comparison compares the session province with the candidate province field" do
            candidate = Candidate.new(
              id: "A",
              source: { "country_code" => "US", "province_code" => "TX" },
            )
            address = build_address(province_code: "US-TX", country_code: "US")
            comparison = ComparisonHelper.province_code_comparison(address: address, candidate: candidate)

            assert_empty comparison.unmatched_tokens

            stubbed_sequence = Token::Sequence.from_string("US-TX")
            assert_equal stubbed_sequence, comparison.left_sequence
            assert_equal stubbed_sequence, comparison.right_sequence
          end

          test "#province_code_comparison handles US terriories " do
            candidate = AddressValidation::Candidate.new(
              id: "A",
              source: { "country_code" => "US", "province_code" => "PR" },
            )
            address = build_address(province_code: "US-PR", country_code: "US")

            comparison = ComparisonHelper.province_code_comparison(address: address, candidate: candidate)

            assert_empty comparison.unmatched_tokens

            expected_sequence = Token::Sequence.from_string("PR")
            assert_equal expected_sequence, comparison.left_sequence
            assert_equal expected_sequence, comparison.right_sequence
          end

          test "#zip_comparison compares the session zip with the candidate zip field" do
            candidate = Candidate.new(id: "A", source: { "zip" => "J9A 2V2" })
            address = build_address(country_code: "CA", zip: "j9a2v2")

            comparison = ComparisonHelper.zip_comparison(address: address, candidate: candidate)
            candidate_zip_sequences = candidate.component(:zip).sequences

            assert_predicate comparison, :match?
            assert_equal ["J9A 2V2"], candidate_zip_sequences.map(&:raw_value)
            assert_equal ["j9a", "2v2"], comparison.left_sequence.tokens.map(&:value)
            assert_equal candidate_zip_sequences.first, comparison.right_sequence
          end

          test "#zip_comparison compares the session zip with a truncated candidate zip field when applicable" do
            candidate = Candidate.new(id: "A", source: { "zip" => "S2919 BNA" })
            address = build_address(country_code: "AR", zip: "S2919")

            comparison = ComparisonHelper.zip_comparison(address: address, candidate: candidate)

            candidate.component(:zip).value = "S2919"
            expected_candidate_zip_sequences = candidate.component(:zip).sequences

            assert_predicate comparison, :match?
            assert_equal ["S2919"], expected_candidate_zip_sequences.map(&:raw_value)
            assert_equal ["s2919"], comparison.left_sequence.tokens.map(&:value)
            assert_equal expected_candidate_zip_sequences.first, comparison.right_sequence
          end

          test "#building_comparison compares the session building number with the candidate building number ranges" do
            candidate = Candidate.new(
              id: "A",
              source: { "building_and_unit_ranges" => "{\"(0..99)/1\": {}}" },
            )
            address = build_address(country_code: "CA", address1: "1 Main St")
            datastore = Es::Datastore.new(address: address)

            comparison = ComparisonHelper.building_comparison(datastore: datastore, candidate: candidate)

            assert comparison.match?
          end

          test "returns nil comparison for candidate when there is no field value to compare" do
            candidate = Candidate.new(id: "A", source: { "zip" => nil })
            address = build_address(country_code: "CA", zip: "j9a2v2")

            comparison = ComparisonHelper.zip_comparison(address: address, candidate: candidate)
            candidate_zip_sequences = candidate.component(:zip).sequences

            assert_nil comparison
            assert_empty candidate_zip_sequences.map(&:raw_value)
          end
        end
      end
    end
  end
end
