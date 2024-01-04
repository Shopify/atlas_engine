# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class AddressComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper

          setup do
            @street_mismatch = sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "elm"), right: token(value: "elm")),
                token_comparison(left: token(value: "street"), right: token(value: "road"), qualifier: :comp, edit: 4),
              ],
            )

            @city_mismatch = sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "city"), right: token(value: "town"), qualifier: :comp, edit: 4),
              ],
            )

            @zip_mismatch = sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "10001"), right: token(value: "11112"), qualifier: :comp, edit: 4),
              ],
            )
          end

          test "#<=> more matching sequences wins" do
            address_comparison_1 = address_comparison(city_comp: @city_mismatch)
            address_comparison_2 = address_comparison # all 4 field sequences are a match

            assert_equal(1, address_comparison_1 <=> address_comparison_2)
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> building number contributes to total matching sequences" do
            address_comparison_1 = address_comparison(
              building_comp_numbers: ["100", "200"],
              building_comp_candidate_ranges: [AddressNumberRange.new(range_string: "(3000..4000)/1")],
            ) # building mismatch
            address_comparison_2 = address_comparison(
              building_comp_numbers: ["100"],
              building_comp_candidate_ranges: [AddressNumberRange.new(range_string: "(50..150)/1")],
            ) # all fields are a match
            assert_equal(1, address_comparison_1 <=> address_comparison_2)
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> when tied in number of matching sequences, sort by most favorable merged street+city+zip+province /
              comparison" do
            # each address comparison has 3 matching sequences, a tie.
            # @street_mismatch has one pair of equal tokens and one pair of tokens with edit distance = 4.
            # @city_mismatch only has a pair of unequal tokens with edit distance = 4.
            address_comparison_1 = address_comparison(city_comp: @street_mismatch)  # elm == elm, street != road (ed:4)
            address_comparison_2 = address_comparison(street_comp: @city_mismatch)  # city != town (ed: 4)

            assert_equal(-1, address_comparison_1 <=> address_comparison_2)
            assert_equal(1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> considered equal when tied in number of matching sequences and when merged sequence comparisons /
              are equivalent" do
            address_comparison_1 = address_comparison(street_comp: @city_mismatch)  # city != town (ed: 4)
            address_comparison_2 = address_comparison(city_comp: @zip_mismatch)     # 10001 != 11112 (ed: 4)

            assert_equal(0, address_comparison_1 <=> address_comparison_2)
            assert_equal(0, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> handles cases when there are no text comparisons and no data in number comparison" do
            # no text comparisons and number comparison has no values
            address_comparison_1 = address_comparison(use_default: false)
            address_comparison_2 = address_comparison(city_comp: @zip_mismatch) # 10001 != 11112 (ed: 4)

            assert_equal 1, address_comparison_1 <=> address_comparison_2
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> handles cases when one side has empty comparisons" do
            address_comparison_1 = address_comparison(use_default: false) # no comparisons
            address_comparison_2 = address_comparison(city_comp: @zip_mismatch) # 10001 != 11112 (ed: 4)

            assert_equal 1, address_comparison_1 <=> address_comparison_2
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> handles cases when there are no text comparisons but there is data in number comparison" do
            address_comparison_1 = address_comparison(
              use_default: false,
              building_comp_numbers: ["100"],
              building_comp_candidate_ranges: [AddressNumberRange.new(range_string: "(50..150)/1")],
            ) # no text comparisons but number comparison has values

            address_comparison_2 = address_comparison(city_comp: @zip_mismatch) # 10001 != 11112 (ed: 4)

            assert_equal 1, address_comparison_1 <=> address_comparison_2
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> handles cases when there are no text comparisons and no numbers data in number comparison" do
            address_comparison_1 = address_comparison(
              use_default: false,
              building_comp_candidate_ranges: [AddressNumberRange.new(range_string: "(50..150)/1")],
            ) # no text comparisons and number comparison has only candidate range values

            address_comparison_2 = address_comparison(city_comp: @zip_mismatch) # 10001 != 11112 (ed: 4)

            assert_equal 1, address_comparison_1 <=> address_comparison_2
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#<=> handles cases when there are no text comparisons and no number comparison candidate_range" do
            address_comparison_1 = address_comparison(
              use_default: false,
              building_comp_numbers: ["100"],
            ) # no text comparisons and number comparison has only numbers values

            address_comparison_2 = address_comparison(city_comp: @zip_mismatch) # 10001 != 11112 (ed: 4)

            assert_equal 1, address_comparison_1 <=> address_comparison_2
            assert_equal(-1, address_comparison_2 <=> address_comparison_1)
          end

          test "#potential_match? returns true when the street comparison is nil" do
            address_comparison = address_comparison(street_comp: nil)
            assert_predicate address_comparison, :potential_match?
          end

          test "#potential_match? returns true when the street comparison is a potential match" do
            street_comparison = instance_double(AtlasEngine::AddressValidation::Token::Sequence::Comparison)
            street_comparison.stubs(:potential_match?).returns(true)

            address_comparison = address_comparison(street_comp: street_comparison)
            assert_predicate address_comparison, :potential_match?
          end

          test "#potential_match? returns false when the street comparison is not a potential match" do
            street_comparison = instance_double(AtlasEngine::AddressValidation::Token::Sequence::Comparison)
            street_comparison.stubs(:potential_match?).returns(false)

            address_comparison = address_comparison(street_comp: street_comparison)
            assert_not_predicate address_comparison, :potential_match?
          end

          def address_comparison(
            street_comp: nil,
            city_comp: nil,
            zip_comp: nil,
            province_comp: nil,
            building_comp_numbers: [],
            building_comp_candidate_ranges: [],
            use_default: true
          )
            AddressValidation::Validators::FullAddress::AddressComparison.new(
              street_comparison: use_default ? street_comp || default_street_comparison : street_comp,
              city_comparison: use_default ? city_comp || default_city_comparison : city_comp,
              zip_comparison: use_default ? zip_comp || default_zip_comparison : zip_comp,
              province_code_comparison: use_default ? province_comp || default_province_comparison : province_comp,
              building_comparison: building_comparison(
                numbers: building_comp_numbers,
                candidate_ranges: building_comp_candidate_ranges,
              ),
            )
          end

          def default_street_comparison
            sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "street"), right: token(value: "street")),
              ],
            )
          end

          def default_city_comparison
            sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "city"), right: token(value: "city")),
              ],
            )
          end

          def default_zip_comparison
            sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "zip"), right: token(value: "zip")),
              ],
            )
          end

          def default_province_comparison
            sequence_comparison(
              token_comparisons: [
                token_comparison(left: token(value: "province"), right: token(value: "province")),
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
