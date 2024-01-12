# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class AddressComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper
          include AddressValidationTestHelper

          setup do
            @candidate = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Bronx"],
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )
            @address = build_address(address1: "10 County Road 34", city: "Bronx", zip: "10001", country_code: "US")
            @datastore = Es::Datastore.new(address: @address)
            @datastore.street_sequences = [Token::Sequence.from_string("County Road 34")]
            @datastore.city_sequence = Token::Sequence.from_string("Bronx")
          end

          test "#<=> more matching sequences wins" do
            city_mismatch_candidate = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["blah"],
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )

            city_mismatch = AddressComparison.new(
              address: @address,
              candidate: city_mismatch_candidate,
              datastore: @datastore,
            )

            matched = AddressComparison.new(
              address: @address,
              candidate: @candidate,
              datastore: @datastore,
            )

            assert_equal(-1, matched <=> city_mismatch)
            assert_equal(1, city_mismatch <=> matched)
          end

          test "#<=> building number contributes to total matching sequences" do
            out_of_range_building_number_candidate = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Bronx"],
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(100..199)/1\": {}}",
              },
            )

            unmatched_building_number = AddressComparison.new(
              address: @address,
              candidate: out_of_range_building_number_candidate,
              datastore: @datastore,
            )
            matched_building_number = AddressComparison.new(
              address: @address,
              candidate: @candidate,
              datastore: @datastore,
            )

            assert_equal(-1, matched_building_number <=> unmatched_building_number)
            assert_equal(1, unmatched_building_number <=> matched_building_number)
          end

          test "#<=> when tied in number of matching sequences, sort by most favorable merged street+city+zip+province /
              comparison" do
            street_mismatch = Candidate.new(
              id: "123",
              source: {
                "street" => "County rod 34", # Edit distance of 1
                "city" => ["Bronx"],
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )

            city_mismatch = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Brigx"], # Edit distance of 2
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )

            street_mismatch_comparison = AddressComparison.new(
              address: @address,
              candidate: street_mismatch,
              datastore: @datastore,
            )
            city_mismatch_comparison = AddressComparison.new(
              address: @address,
              candidate: city_mismatch,
              datastore: @datastore,
            )

            assert_equal(-1, city_mismatch_comparison <=> street_mismatch_comparison)
            assert_equal(1, street_mismatch_comparison <=> city_mismatch_comparison)
          end

          test "#<=> considered equal when tied in number of matching sequences and when merged sequence comparisons /
              are equivalent" do
            city_mismatch = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Broni"], # Edit distance of 1
                "zip" => "10001",
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )

            zip_mismatch = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Bronx"],
                "zip" => "10002", # Edit distance of 1
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )

            city_mismatch_comparison = AddressComparison.new(
              address: @address,
              candidate: city_mismatch,
              datastore: @datastore,
            )
            zip_mismatch_comparison = AddressComparison.new(
              address: @address,
              candidate: zip_mismatch,
              datastore: @datastore,
            )

            assert_equal(0, zip_mismatch_comparison <=> city_mismatch_comparison)
            assert_equal(0, city_mismatch_comparison <=> zip_mismatch_comparison)
          end

          test "#<=> handles cases when one side has empty comparisons" do
            empty_candidate = Candidate.new(
              id: "123",
              source: {},
            )
            empty_comparison = AddressComparison.new(
              address: @address,
              candidate: empty_candidate,
              datastore: @datastore,
            )

            zip_mismatch = Candidate.new(
              id: "123",
              source: {
                "street" => "County Road 34",
                "city" => ["Bronx"],
                "zip" => "10002", # Edit distance of 1
                "building_and_unit_ranges" => "{\"(0..99)/1\": {}}",
              },
            )
            zip_mismatch_comparison = AddressComparison.new(
              address: @address,
              candidate: zip_mismatch,
              datastore: @datastore,
            )

            assert_equal(-1, zip_mismatch_comparison <=> empty_comparison)
            assert_equal 1, empty_comparison <=> zip_mismatch_comparison
          end

          test "#<=> handles cases when there are no text comparisons but there is data in number comparison" do
            numbers_only_candidate = Candidate.new(
              id: "123",
              source: { "building_and_unit_ranges" => "{\"(0..99)/1\": {}}" },
            )
            numbers_comparison = AddressComparison.new(
              address: @address,
              candidate: numbers_only_candidate,
              datastore: @datastore,
            )

            non_matching_range_candidate = Candidate.new(
              id: "123",
              source: {
                "building_and_unit_ranges" => "{\"(100..199)/1\": {}}",
              },
            )
            non_matching_range_comparison = AddressComparison.new(
              address: @address,
              candidate: non_matching_range_candidate,
              datastore: @datastore,
            )

            assert_equal(-1, numbers_comparison <=> non_matching_range_comparison)
            assert_equal 1, non_matching_range_comparison <=> numbers_comparison
          end

          test "#<=> handles cases when there are no text comparisons and no numbers data in number comparison" do
            non_matching_range_candidate_1 = Candidate.new(
              id: "123",
              source: { "building_and_unit_ranges" => "{\"(100..199)/1\": {}}" },
            )
            non_matching_numbers_comparison_1 = AddressComparison.new(
              address: @address,
              candidate: non_matching_range_candidate_1,
              datastore: @datastore,
            )

            non_matching_range_candidate_2 = Candidate.new(
              id: "123",
              source: {
                "building_and_unit_ranges" => "{\"(200..299)/1\": {}}",
              },
            )
            non_matching_numbers_comparison_2 = AddressComparison.new(
              address: @address,
              candidate: non_matching_range_candidate_2,
              datastore: @datastore,
            )

            assert_equal(0, non_matching_numbers_comparison_1 <=> non_matching_numbers_comparison_2)
            assert_equal 0, non_matching_numbers_comparison_2 <=> non_matching_numbers_comparison_1
          end

          test "#potential_match? returns true when the street comparison is nil" do
            empty_candidate = Candidate.new(
              id: "123",
              source: {},
            )
            address_comparison = AddressComparison.new(
              address: @address,
              candidate: empty_candidate,
              datastore: @datastore,
            )
            assert_predicate address_comparison, :potential_match?
          end

          test "#potential_match? returns true when the street comparison is a potential match" do
            potential_match_candidate = Candidate.new(
              id: "123",
              source: {
                "street" => "County St 34",
              },
            )
            address_comparison = AddressComparison.new(
              address: @address,
              candidate: potential_match_candidate,
              datastore: @datastore,
            )
            assert address_comparison.potential_match?
          end

          test "#potential_match? returns false when the street comparison is not a potential match" do
            non_matching_candidate = Candidate.new(
              id: "123",
              source: {
                "street" => "blah blah road",
              },
            )
            address_comparison = AddressComparison.new(
              address: @address,
              candidate: non_matching_candidate,
              datastore: @datastore,
            )
            assert_not address_comparison.potential_match?
          end
        end
      end
    end
  end
end
