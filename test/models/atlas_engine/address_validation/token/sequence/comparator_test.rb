# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class ComparatorTest < ActiveSupport::TestCase
          include AddressValidation::TokenHelper

          test "#token_comparisons simple example" do
            left_seq = sequence("123", "main")
            left_tokens_flattened = left_seq.permutations[0]
            right_seq = sequence("123", "main")
            right_tokens_flattened = right_seq.permutations[0]

            s1_123, s1_main = left_seq.tokens
            s2_123, s2_main = right_seq.tokens

            token_comparisons = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            ).send(:token_comparisons, left_tokens_flattened, right_tokens_flattened)

            assert_equal 4, token_comparisons.size

            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_123, :comp, s2_main, token_comparisons[1], 4)
            assert_comparison(s1_main, :comp, s2_123, token_comparisons[2], 4)
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[3])
          end

          test "#token_comparisons with single token synomyms" do
            left_seq = sequence("123", "main", "st")
            left_tokens_flattened = left_seq.permutations[0]
            right_seq = sequence("123", "main", ["st", "street"])
            right_tokens_flattened = right_seq.permutations[0]

            s1_123, s1_main, s1_st = left_seq.tokens
            s2_123, s2_main, s2_st = right_seq.tokens
            s2_st, s2_street = s2_st.tokens

            token_comparisons = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            ).send(:token_comparisons, left_tokens_flattened, right_tokens_flattened)

            assert_equal 12, token_comparisons.size

            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_123, :comp, s2_main, token_comparisons[1], 4)
            assert_comparison(s1_123, :comp, s2_st, token_comparisons[2], 3)
            assert_comparison(s1_123, :comp, s2_street, token_comparisons[3], 6)

            assert_comparison(s1_main, :comp, s2_123, token_comparisons[4], 4)
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[5])
            assert_comparison(s1_main, :comp, s2_st, token_comparisons[6], 4)
            assert_comparison(s1_main, :comp, s2_street, token_comparisons[7], 6)

            assert_comparison(s1_st, :comp, s2_123, token_comparisons[8], 3)
            assert_comparison(s1_st, :comp, s2_main, token_comparisons[9], 4)
            assert_comparison(s1_st, :equal, s2_st, token_comparisons[10])
            assert_comparison(s1_st, :prefix, s2_street, token_comparisons[11], 4)
          end

          test "#flattened_sequence_compare when left and right match" do
            left_seq = sequence("123", "main")
            s1_123, s1_main = left_seq.tokens

            right_seq = sequence("123", "main")
            s2_123, s2_main = right_seq.tokens

            comparator = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            )

            comparisons = [
              AddressValidation::Token::Comparison.new(
                left: s1_123,
                right: s2_123,
                qualifier: :equal,
                edit_distance: 0,
              ),
              AddressValidation::Token::Comparison.new(
                left: s1_main,
                right: s2_main,
                qualifier: :equal,
                edit_distance: 0,
              ),
            ]

            result = comparator.send(:flattened_sequence_compare, left_seq.tokens, right_seq.tokens)

            assert_equal [], result.unmatched_tokens
            assert_equal comparisons, result.token_comparisons
          end

          test "#flattened_sequence_compare when left and right do not match" do
            left_seq = sequence("123", "main", "st")
            s1_123, s1_main, s1_st = left_seq.tokens

            right_seq = sequence("main", "street")
            s2_main, s2_street = right_seq.tokens

            comparator = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            )

            comparisons = [
              AddressValidation::Token::Comparison.new(
                left: s1_main,
                right: s2_main,
                qualifier: :equal,
                edit_distance: 0,
              ),
              AddressValidation::Token::Comparison.new(
                left: s1_st,
                right: s2_street,
                qualifier: :prefix,
                edit_distance: 4,
              ),
            ]

            result = comparator.send(:flattened_sequence_compare, left_seq.tokens, right_seq.tokens)

            assert_equal [s1_123], result.unmatched_tokens
            assert_equal comparisons, result.token_comparisons
          end

          test "#unmatched_tokens same tokens" do
            left_seq = sequence("123", "main", "street")
            s1_123, s1_main, s1_street = left_seq.tokens

            right_seq = sequence("123", "main", "street")
            s2_123, s2_main, s2_street = right_seq.tokens

            comparator = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            )

            comparisons = [
              AddressValidation::Token::Comparison.new(
                left: s1_123,
                right: s2_123,
                qualifier: :equal,
                edit_distance: 0,
              ),
              AddressValidation::Token::Comparison.new(
                left: s1_main,
                right: s2_main,
                qualifier: :equal,
                edit_distance: 0,
              ),
              AddressValidation::Token::Comparison.new(
                left: s1_street,
                right: s2_street,
                qualifier: :equal,
                edit_distance: 0,
              ),
            ]

            expected = []

            assert_equal expected, comparator.send(:unmatched_tokens, left_seq.tokens, right_seq.tokens, comparisons)
          end

          test "#unmatched_tokens mismatched tokens" do
            left_seq = sequence("123", "main", "st")
            s1_123, s1_main, s1_st = left_seq.tokens

            right_seq = sequence("main", "street")
            s2_main, s2_street = right_seq.tokens

            comparisons = [
              AddressValidation::Token::Comparison.new(
                left: s1_main,
                right: s2_main,
                qualifier: :equal,
                edit_distance: 0,
              ),
              AddressValidation::Token::Comparison.new(
                left: s1_st,
                right: s2_street,
                qualifier: :prefix,
                edit_distance: 4,
              ),
            ]

            expected = [s1_123]

            comparator = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: left_seq,
              right_sequence: right_seq,
            )

            assert_equal expected, comparator.send(:unmatched_tokens, left_seq.tokens, right_seq.tokens, comparisons)
          end

          test "#compare when sequences are equal" do
            seq1 = sequence("123", "main", "street")
            s1_123, s1_main, s1_street = seq1.tokens

            seq2 = sequence("123", "main", "street")
            s2_123, s2_main, s2_street = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[1])
            assert_comparison(s1_street, :equal, s2_street, token_comparisons[2])
          end

          test "#compare when sequences are close (typos and prefix)" do
            seq1 = sequence("123", "main", "street")
            s1_123, s1_main, s1_street = seq1.tokens
            seq2 = sequence("123", "mine", "st")
            s2_123, s2_mine, s2_st = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_empty comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_main, :comp, s2_mine, token_comparisons[1], 2)
            assert_comparison(s1_street, :prefix, s2_st, token_comparisons[2], 4)
          end

          test "#compare when sequence has spacing typo" do
            seq1 = sequence("ecollinham")
            seq2 = sequence("east", "collinham", "st")
            seq3 = sequence("eddlynch", "rd")

            s1_ecollinham = seq1.tokens.first
            s2_east, s2_collinham, s2_st = seq2.tokens
            s3_eddlynch, s3_rd = seq3.tokens

            comparison_1 = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            assert_equal [s2_east, s2_st], comparison_1.unmatched_tokens
            assert_comparison(s1_ecollinham, :suffix, s2_collinham, comparison_1.token_comparisons.first, 1)

            comparison_2 = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq3,
            ).compare

            assert_equal [s1_ecollinham, s3_eddlynch, s3_rd], comparison_2.unmatched_tokens
            assert_equal 0, comparison_2.token_comparisons.size
          end

          test "#compare when tokens are in differing order" do
            seq1 = sequence("123", "main", "street")
            s1_123, s1_main, s1_street = seq1.tokens
            seq2 = sequence("rue", "123", "main")
            s2_rue, s2_123, s2_main = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_street, s2_rue], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[1])
          end

          test "#compare when sequences have different length" do
            seq1 = sequence("123", "main", "strt", "apt", "a")
            s1_123, s1_main, s1_strt, s1_apt, s1_a = seq1.tokens
            seq2 = sequence("main", "street", "w")
            s2_main, s2_street, s2_w = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_123, s1_apt, s1_a, s2_w], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence

            assert_comparison(s1_main, :equal, s2_main, token_comparisons[0])
            assert_comparison(s1_strt, :comp, s2_street, token_comparisons[1], 2)
          end

          test "sequences contain synonyms" do
            seq1 = sequence("123", "main", ["st", "street"])
            s1_123, s1_main, s1_street_syn = seq1.tokens
            s1_syn_street = s1_street_syn.tokens.second
            seq2 = sequence("123", "main", "street")
            s2_123, s2_main, s2_street = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_equal 3, token_comparisons.size
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[1])
            assert_comparison(s1_syn_street, :equal, s2_street, token_comparisons[2])
          end

          test "sequences contain multiple synonyms" do
            seq1 = sequence("123", ["st", "saint"], "main", ["st", "street"])
            s1_123, s1_saint_syn, s1_main, s1_street_syn = seq1.tokens
            s1_syn_saint = s1_saint_syn.tokens.second
            s1_syn_street = s1_street_syn.tokens.second
            seq2 = sequence("123", "saint", "main", "street")
            s2_123, s2_saint, s2_main, s2_street = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_equal 4, token_comparisons.size
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_syn_saint, :equal, s2_saint, token_comparisons[1])
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[2])
            assert_comparison(s1_syn_street, :equal, s2_street, token_comparisons[3])
          end

          test "sequences with synonyms have different length" do
            seq1 = sequence("123", "main", ["strt", "street"], "apt", "a")
            s1_123, s1_main, s1_street_syn, s1_apt, s1_a = seq1.tokens
            s1_syn_street = s1_street_syn.tokens.second
            seq2 = sequence("main", "street", "w")
            s2_main, s2_street, s2_w = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_123, s1_apt, s1_a, s2_w], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_equal 2, token_comparisons.size
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[0])
            assert_comparison(s1_syn_street, :equal, s2_street, token_comparisons[1])
          end

          test "sequence with an unmatched group of synonyms" do
            tokens = [
              { value: "street", start_offset: 0, end_offset: 2, type: "SYNONYM", position: 0 },
              { value: "saint", start_offset: 0, end_offset: 2, type: "SYNONYM", position: 0 },
              { value: "st", start_offset: 0, end_offset: 2, type: "<ALPHANUM>", position: 0 },
              { value: "paul", start_offset: 3, end_offset: 7, type: "<ALPHANUM>", position: 1 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: tokens)
            s1_st_syn, s1_paul = seq1.tokens
            s1_syn_st = s1_st_syn.tokens.last

            seq2 = sequence("paul")
            s2_paul = seq2.tokens.first

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_syn_st], comparison.unmatched_tokens # saint and street are eliminated from the comparison
            assert_equal 1, token_comparisons.size
            assert_comparison(s1_paul, :equal, s2_paul, token_comparisons[0])
          end

          test "sequence where several synonyms match terms from other sequence" do
            # either saint or street should wind up in the final sequence comparison result, not both.
            seq1 = sequence("123", ["saint", "street"], "paul", "road")
            s1_123, s1_saint_street_syn, s1_paul, s1_road = seq1.tokens
            s1_saint = s1_saint_street_syn.tokens.first
            seq2 = sequence("saint", "paul", "street")
            s2_saint, s2_paul, s2_street = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_123, s1_road, s2_street], comparison.unmatched_tokens
            # s1_saint is selected from the possible synonyms. That removes the "street" synonym from
            # future comparisons, even if s1.street == s2.street. A synonyms object only contributes one of its
            # entries to a sequence comparison.
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_equal 2, token_comparisons.size
            assert_comparison(s1_saint, :equal, s2_saint, token_comparisons[0])
            assert_comparison(s1_paul, :equal, s2_paul, token_comparisons[1])
          end

          test "sequences contain a multi-token synonym" do
            tokens = [
              { value: "123", start_offset: 0, end_offset: 4, type: "<NUM>", position: 0 },
              { value: "eglin", start_offset: 5, end_offset: 10, type: "<ALPHANUM>", position: 1 },
              { value: "afb", start_offset: 11, end_offset: 14, type: "<ALPHANUM>", position: 2, position_length: 3 },
              { value: "air", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 2 },
              { value: "force", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 3 },
              { value: "base", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 4 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: tokens)
            s1_123, s1_eglin, s1_afb_syn = seq1.tokens
            s1_syn_afb_full = s1_afb_syn.tokens.second
            s1_syn_afb_air = s1_syn_afb_full.first
            s1_syn_afb_force = s1_syn_afb_full.second
            s1_syn_afb_base = s1_syn_afb_full.third

            seq2 = sequence("123", "eglin", "air", "force", "base")

            s2_123, s2_eglin, s2_afb_air, s2_afb_force, s2_afb_base = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_eglin, :equal, s2_eglin, token_comparisons[1])
            assert_comparison(s1_syn_afb_air, :equal, s2_afb_air, token_comparisons[2])
            assert_comparison(s1_syn_afb_force, :equal, s2_afb_force, token_comparisons[3])
            assert_comparison(s1_syn_afb_base, :equal, s2_afb_base, token_comparisons[4])
          end

          test "sequences contain a single-token synonyms and multi-token synonym" do
            tokens = [
              { value: "main", start_offset: 0, end_offset: 4, type: "<ALPHANUM>", position: 0 },
              { value: "strt", start_offset: 5, end_offset: 9, type: "SYNONYM", position: 1 },
              { value: "street", start_offset: 5, end_offset: 9, type: "<ALPHANUM>", position: 1 },
              { value: "ny", start_offset: 10, end_offset: 12, type: "SYNONYM", position: 2, position_length: 2 },
              { value: "new", start_offset: 10, end_offset: 12, type: "<ALPHANUM>", position: 2 },
              { value: "york", start_offset: 10, end_offset: 12, type: "<ALPHANUM>", position: 3 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: tokens)

            s1_main, s1_street_syn, s1_ny_syn = seq1.tokens
            s1_syn_strt = s1_street_syn.tokens.first
            s1_syn_ny_full = s1_ny_syn.tokens.second
            s1_syn_ny_new = s1_syn_ny_full.first
            s1_syn_ny_york = s1_syn_ny_full.second

            seq2 = sequence("main", "strt", "new", "york")
            s2_main, s2_strt, s2_new, s2_york = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[0])
            assert_comparison(s1_syn_strt, :equal, s2_strt, token_comparisons[1])
            assert_comparison(s1_syn_ny_new, :equal, s2_new, token_comparisons[2])
            assert_comparison(s1_syn_ny_york, :equal, s2_york, token_comparisons[3])
          end

          test "sequences contain multiple multi-token synonyms" do
            tokens = [
              { value: "123", start_offset: 0, end_offset: 4, type: "<NUM>", position: 0 },
              { value: "eglin", start_offset: 5, end_offset: 10, type: "<ALPHANUM>", position: 1 },
              { value: "afb", start_offset: 11, end_offset: 14, type: "<ALPHANUM>", position: 2, position_length: 3 },
              { value: "air", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 2 },
              { value: "force", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 3 },
              { value: "base", start_offset: 11, end_offset: 14, type: "SYNONYM", position: 4 },
              { value: "ny", start_offset: 15, end_offset: 17, type: "SYNONYM", position: 5, position_length: 2 },
              { value: "new", start_offset: 15, end_offset: 17, type: "<ALPHANUM>", position: 5 },
              { value: "york", start_offset: 15, end_offset: 17, type: "<ALPHANUM>", position: 6 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: tokens)
            s1_123, s1_eglin, s1_afb_syn, s1_ny_syn = seq1.tokens

            s1_syn_afb = s1_afb_syn.tokens.first
            s1_syn_ny = s1_ny_syn.tokens.first

            seq2 = sequence("123", "eglin", "afb", "ny")
            s2_123, s2_eglin, s2_afb, s2_ny = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_eglin, :equal, s2_eglin, token_comparisons[1])
            assert_comparison(s1_syn_afb, :equal, s2_afb, token_comparisons[2])
            assert_comparison(s1_syn_ny, :equal, s2_ny, token_comparisons[3])
          end

          test "sequences with multi-token synonyms where comparator has partial match" do
            tokens = [
              { value: "123", start_offset: 0, end_offset: 4, type: "<NUM>", position: 0 },
              { value: "main", start_offset: 5, end_offset: 9, type: "<ALPHANUM>", position: 1 },
              { value: "strt", start_offset: 10, end_offset: 14, type: "SYNONYM", position: 2 },
              { value: "street", start_offset: 10, end_offset: 14, type: "<ALPHANUM>", position: 2 },
              { value: "ny", start_offset: 15, end_offset: 17, type: "SYNONYM", position: 3, position_length: 2 },
              { value: "new", start_offset: 15, end_offset: 17, type: "<ALPHANUM>", position: 3 },
              { value: "york", start_offset: 15, end_offset: 17, type: "<ALPHANUM>", position: 4 },
              { value: "apt", start_offset: 18, end_offset: 21, type: "<ALPHANUM>", position: 5 },
              { value: "b", start_offset: 22, end_offset: 23, type: "<ALPHANUM>", position: 6 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: tokens)
            s1_123, s1_main, s1_street_syn, s1_ny_syn, s1_apt, s1_b = seq1.tokens
            s1_syn_street = s1_street_syn.tokens.second
            s1_syn_ny_full = s1_ny_syn.tokens.second
            s1_syn_ny_new = s1_syn_ny_full.first
            s1_syn_ny_york = s1_syn_ny_full.second

            seq2 = sequence("main", "street", "york", "w")
            s2_main, s2_street, s2_york, s2_w = seq2.tokens

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s1_123, s1_syn_ny_new, s1_apt, s1_b, s2_w], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_equal 3, token_comparisons.size
            assert_comparison(s1_main, :equal, s2_main, token_comparisons[0])
            assert_comparison(s1_syn_street, :equal, s2_street, token_comparisons[1])
            assert_comparison(s1_syn_ny_york, :equal, s2_york, token_comparisons[2])
          end

          test "both sequences contain synonyms" do
            seq1_tokens = [
              { value: "123", start_offset: 0, end_offset: 4, type: "<NUM>", position: 0 },
              { value: "road", start_offset: 5, end_offset: 9, type: "<ALPHANUM>", position: 1 },
              { value: "eglin", start_offset: 10, end_offset: 15, type: "<ALPHANUM>", position: 2 },
              { value: "afb", start_offset: 16, end_offset: 19, type: "<ALPHANUM>", position: 3, position_length: 3 },
              { value: "air", start_offset: 16, end_offset: 19, type: "SYNONYM", position: 3 },
              { value: "force", start_offset: 16, end_offset: 19, type: "SYNONYM", position: 4 },
              { value: "base", start_offset: 16, end_offset: 19, type: "SYNONYM", position: 5 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq1 = AddressValidation::Token::Sequence.new(tokens: seq1_tokens)
            s1_123, s1_road, s1_eglin, s1_afb_syn = seq1.tokens

            s1_syn_afb = s1_afb_syn.tokens.first

            seq2_tokens = [
              { value: "123", start_offset: 0, end_offset: 4, type: "<NUM>", position: 0 },
              {
                value: "caminito",
                start_offset: 5,
                end_offset: 13,
                type: "<ALPHANUM>",
                position: 1,
                position_length: 2,
              },
              { value: "little", start_offset: 5, end_offset: 13, type: "SYNONYM", position: 1 },
              { value: "road", start_offset: 5, end_offset: 13, type: "SYNONYM", position: 2 },
              { value: "eglin", start_offset: 14, end_offset: 19, type: "<ALPHANUM>", position: 3 },
              { value: "afb", start_offset: 20, end_offset: 23, type: "<ALPHANUM>", position: 4 },
            ].map { |hash| AddressValidation::Token.new(**hash) }

            seq2 = AddressValidation::Token::Sequence.new(tokens: seq2_tokens)
            s2_123, s2_caminito_syn, s2_eglin, s2_afb = seq2.tokens
            s2_syn_road = s2_caminito_syn.tokens.second.second
            s2_syn_little = s2_caminito_syn.tokens.second.first

            comparison = AddressValidation::Token::Sequence::Comparator.new(
              left_sequence: seq1,
              right_sequence: seq2,
            ).compare

            token_comparisons = comparison.token_comparisons

            assert_equal [s2_syn_little], comparison.unmatched_tokens
            assert_equal seq1, comparison.left_sequence
            assert_equal seq2, comparison.right_sequence
            assert_comparison(s1_123, :equal, s2_123, token_comparisons[0])
            assert_comparison(s1_road, :equal, s2_syn_road, token_comparisons[1])
            assert_comparison(s1_eglin, :equal, s2_eglin, token_comparisons[2])
            assert_comparison(s1_syn_afb, :equal, s2_afb, token_comparisons[3])
          end
        end
      end
    end
  end
end
