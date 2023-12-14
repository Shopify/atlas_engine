# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class ComparisonTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper

          setup do
            @sequence_comparison_klass = AddressValidation::Token::Sequence::Comparison
            @dummy1 = token(value: "dummy1")
            @dummy2 = token(value: "dummy2")
            @dummy3 = token(value: "dummy3")
            @dummy4 = token(value: "dummy4")
            @dummy5 = token(value: "dummy5")
            @dummy6 = token(value: "dummy6")

            @equal_0 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :equal, edit: 0)
            @prefix_2 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :prefix, edit: 2)
            @prefix_4 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :prefix, edit: 4)
            @suffix_2 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :suffix, edit: 2)
            @suffix_4 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :suffix, edit: 4)
            @comp_2 = token_comparison(left: @dummy1, right: @dummy2, qualifier: :comp, edit: 2)
          end

          test "exact match on street type wins over fuzzy match on street name" do
            seq1 = sequence("ecollinham", "rd")
            seq2 = sequence("collinham", "st")
            seq3 = sequence("eddlynch", "rd")

            fuzzy_collinham_match = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            exact_road_match = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq3,
            ).compare

            assert exact_road_match.better_than?(fuzzy_collinham_match)
            assert fuzzy_collinham_match.worse_than?(exact_road_match)
          end

          test "more equal tokens wins" do
            comparisons_a = [@equal_0]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@equal_0, @equal_0]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.worse_than?(seq_comp_b)
            assert seq_comp_b.better_than?(seq_comp_a)
          end

          test "fewer unmatched tokens wins" do
            seq_comp_a = sequence_comparison(unmatched_tokens: [@dummy1])
            seq_comp_b = sequence_comparison(unmatched_tokens: [@dummy1, @dummy2])

            assert seq_comp_a.better_than?(seq_comp_b)
            assert seq_comp_b.worse_than?(seq_comp_a)
          end

          test "longest common subsequence length wins" do
            w_184_n = [["west", 0], ["184", 1], ["north", 2]]
            n_w_184 = [["west", 1], ["184", 2], ["north", 0]]
            n_184_w = [["west", 2], ["184", 1], ["north", 0]]

            subsequence_length_1 = comparison_with_positions(left_positions: n_184_w, right_positions: w_184_n)
            subsequence_length_2 = comparison_with_positions(left_positions: n_w_184, right_positions: w_184_n)
            subsequence_length_3 = comparison_with_positions(left_positions: w_184_n, right_positions: w_184_n)

            assert subsequence_length_1.worse_than?(subsequence_length_2)
            assert subsequence_length_3.better_than?(subsequence_length_1)
            assert subsequence_length_2.worse_than?(subsequence_length_3)
            assert subsequence_length_3.equivalent_to?(subsequence_length_3)
          end

          test "non-equal token comparisons cause a break in a subsequence" do
            w_184_n = [["west", 0], ["184", 1], ["north", 2]]
            w_foo_n = [["west", 0], ["foo", 1], ["north", 2]]

            subsequence_length_3 = comparison_with_positions(left_positions: w_184_n, right_positions: w_184_n)
            subsequence_length_1 = comparison_with_positions(left_positions: w_foo_n, right_positions: w_184_n)

            assert subsequence_length_3.better_than?(subsequence_length_1)
            assert subsequence_length_1.worse_than?(subsequence_length_3)
          end

          test "one long subsequence is better than multiple shorter ones" do
            w_184_ave_n =   [["west", 0], ["184", 1], ["ave", 2], ["north", 3]]
            w_184_x_ave_n = [["west", 0], ["184", 1], ["ave", 3], ["north", 4]] # assume that token x is unmatched
            w_184_ave_x_n = [["west", 0], ["184", 1], ["ave", 2], ["north", 4]] # assume that token x is unmatched

            subsequence_length_2_2 = comparison_with_positions(
              left_positions: w_184_x_ave_n,
              right_positions: w_184_ave_n,
            )
            subsequence_length_3 = comparison_with_positions(
              left_positions: w_184_ave_x_n,
              right_positions: w_184_ave_n,
            )

            assert subsequence_length_2_2.worse_than?(subsequence_length_3)
            assert subsequence_length_3.better_than?(subsequence_length_2_2)
          end

          test "two subsequences of max length is better than one subsequence of the same max length" do
            w_184_ave_n =     [["west", 0], ["184", 1], ["ave", 2], ["north", 3]]
            w_184_x_ave_n =   [["west", 0], ["184", 1], ["ave", 3], ["north", 4]] # assume that token x is unmatched
            w_184_x_ave_y_n = [["west", 0], ["184", 1], ["ave", 3], ["north", 5]] # assume that x and y are unmatched

            subsequence_length_2_2 = comparison_with_positions(
              left_positions: w_184_x_ave_n,
              right_positions: w_184_ave_n,
            )
            subsequence_length_2 = comparison_with_positions(
              left_positions: w_184_x_ave_y_n,
              right_positions: w_184_ave_n,
            )

            assert subsequence_length_2_2.better_than?(subsequence_length_2)
            assert subsequence_length_2.worse_than?(subsequence_length_2_2)
          end

          test "#longest_subsequence_comparison understands tokens having position_length > 1" do
            fm_comp = token_comparison(
              left: token(value: "fm", position: 2, position_length: 3),
              right: token(value: "fm", position: 0),
            )

            rd_comp = token_comparison(
              left: token(value: "rd", position: 5),
              right: token(value: "rd", position: 1),
            )

            seq_comp = sequence_comparison(token_comparisons: [fm_comp, rd_comp])

            assert_equal [2, 1], seq_comp.send(:longest_subsequence_comparison)
          end

          test "smaller sum of edit distances wins" do
            comparisons_a = [@prefix_2, @prefix_2, @prefix_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@prefix_4]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.worse_than?(seq_comp_b)
            assert seq_comp_b.better_than?(seq_comp_a)
          end

          test "most prefixes wins" do
            comparisons_a = [@prefix_2, @prefix_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@prefix_4]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.better_than?(seq_comp_b)
            assert seq_comp_b.worse_than?(seq_comp_a)
          end

          test "most suffixes wins" do
            comparisons_a = [@suffix_2, @suffix_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@suffix_4]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.better_than?(seq_comp_b)
            assert seq_comp_b.worse_than?(seq_comp_a)
          end

          test "prefix wins over regular comparison" do
            comparisons_a = [@prefix_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@comp_2]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.better_than?(seq_comp_b)
            assert seq_comp_b.worse_than?(seq_comp_a)
          end

          test "two comparisons with equal edit distances are equal" do
            comparisons_a = [@comp_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons_a)

            comparisons_b = [@comp_2]

            seq_comp_b = sequence_comparison(token_comparisons: comparisons_b)

            assert seq_comp_a.equivalent_to?(seq_comp_b)
            assert seq_comp_b.equivalent_to?(seq_comp_a)
          end

          test "inspect" do
            comp = token_comparison(left: @dummy2, right: @dummy3, qualifier: :equal, edit: 0)

            comparisons = [comp]

            seq_comp = sequence_comparison(unmatched_tokens: [@dummy1], token_comparisons: comparisons)

            assert_match(
              # rubocop:disable Layout/LineLength
              %r{<seqcomp unmatched:\[<tok .+ val:"dummy1" .+/>\] comp:\[\n<comp left:.+/> EQUAL right:.+/> edit:0/>\n\]/>},
              # rubocop:enable Layout/LineLength
              seq_comp.inspect,
            )
          end

          test "merge" do
            comp_2_3 = token_comparison(left: @dummy2, right: @dummy3, qualifier: :equal, edit: 0)
            comparisons_a = [comp_2_3]
            seq_comp_a = sequence_comparison(unmatched_tokens: [@dummy1], token_comparisons: comparisons_a)

            comp_5_6 = token_comparison(left: @dummy5, right: @dummy6, qualifier: :equal, edit: 0)
            comparisons_b = [comp_5_6]
            seq_comp_b = sequence_comparison(unmatched_tokens: [@dummy4], token_comparisons: comparisons_b)

            merged_comp = seq_comp_a.merge(seq_comp_b)

            expected = sequence_comparison(
              unmatched_tokens: [@dummy1, @dummy4],
              token_comparisons: [comp_2_3, comp_5_6],
            )

            assert merged_comp.equivalent_to?(expected)
          end

          test "match? true when sequences are equal" do
            comparisons = [@equal_0]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons)

            assert_predicate seq_comp_a, :match?
          end

          test "match? false when there are unmatched tokens" do
            comparisons = [@equal_0]

            seq_comp_a = sequence_comparison(unmatched_tokens: [@dummy2], token_comparisons: comparisons)

            assert_not_predicate seq_comp_a, :match?
          end

          test "match? false when some token comparisons have a non-zero edit distance" do
            comparisons = [@equal_0, @prefix_2]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons)

            assert_not_predicate seq_comp_a, :match?
          end

          test "#potential_match? is true when the sequences are a perfect match" do
            comparisons = [@equal_0]

            seq_comp_a = sequence_comparison(token_comparisons: comparisons)

            assert_predicate seq_comp_a, :potential_match?
          end

          test "#potential_match? is true when the sequences are a close match" do
            county = token(value: "county")
            country = token(value: "country")
            rd = token(value: "rd")
            road = token(value: "road")

            comparison = sequence_comparison(
              token_comparisons: [
                token_comparison(left: county, right: country, qualifier: :comp, edit: 1),
                token_comparison(left: rd, right: road, qualifier: :equal, edit: 0),
              ],
            )

            assert_predicate comparison, :potential_match?
          end

          test "#potential_match? is false when unmatched tokens outnumber matches" do
            w = token(value: "w")
            e = token(value: "e")
            snickerdoodle = token(value: "snickerdoodle")
            rd = token(value: "rd")
            pl = token(value: "pl")

            comparison = sequence_comparison(
              unmatched_tokens: [w, e, rd, pl],
              token_comparisons: [
                token_comparison(left: snickerdoodle, right: snickerdoodle),
              ],
            )

            assert_not_predicate comparison, :potential_match?
          end

          test "#potential_match? is false when the combined string contents are a poor match" do
            w = token(value: "w")
            snickerdoodle = token(value: "snickerdoodle")
            cockadoodle = token(value: "cockadoodle")
            pl = token(value: "pl")

            comparison = sequence_comparison(
              unmatched_tokens: [cockadoodle, snickerdoodle],
              token_comparisons: [
                token_comparison(left: w, right: w),
                token_comparison(left: pl, right: pl),
              ],
            )

            assert_not_predicate comparison, :potential_match?
          end

          test "aggregate_edit_distance returns the sum of the edit distances in a comparison" do
            comparisons = [@equal_0, @prefix_2]

            seq_comp = sequence_comparison(token_comparisons: comparisons)

            assert_equal 2, seq_comp.aggregate_edit_distance
          end

          test "token_match_count returns the total number of tokens matched" do
            comparisons = [@equal_0, @prefix_2, @suffix_2]

            seq_comp = sequence_comparison(token_comparisons: comparisons)

            assert_equal 3, seq_comp.token_match_count
          end

          private

          sig do
            params(
              left_positions: T::Array[[String, Integer]],
              right_positions: T::Array[[String, Integer]],
            ).returns(AddressValidation::Token::Sequence::Comparison)
          end
          def comparison_with_positions(left_positions:, right_positions:)
            token_comparisons = []
            left_positions.zip(right_positions).each do |(left_val, left_pos), (right_val, right_pos)|
              token_comparisons << AddressValidation::Token::Comparison.new(
                left:  token(value: left_val, position: left_pos),
                right: token(value: right_val, position: right_pos),
                qualifier: left_val == right_val ? :equal : :comp,
                edit_distance: left_val == right_val ? 0 : 1,
              )
            end

            sequence_comparison(
              unmatched_tokens: [], # improve this if your tests are sensitive to unmatched tokens
              token_comparisons: token_comparisons,
              left_sequence: nil,
              right_sequence: nil,
            )
          end
        end
      end
    end
  end
end
