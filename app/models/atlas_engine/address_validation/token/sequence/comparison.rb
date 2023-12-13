# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class Comparison
          extend T::Sig
          include Comparable

          DEFAULT_PARTIAL_MATCH_THRESHOLD_PERCENT = 0.5

          attr_reader :unmatched_tokens, :left_sequence, :right_sequence, :token_comparisons

          sig do
            params(
              unmatched_tokens: T::Array[Token],
              token_comparisons: T::Array[Token::Comparison],
              left_sequence: T.nilable(Sequence),
              right_sequence: T.nilable(Sequence),
            ).void
          end
          def initialize(unmatched_tokens:, token_comparisons:, left_sequence:, right_sequence:)
            @unmatched_tokens = unmatched_tokens
            @token_comparisons = token_comparisons
            @left_sequence = left_sequence
            @right_sequence = right_sequence
          end

          sig { params(other: Comparison).returns(Integer) }
          def <=>(other)
            # > num matches
            # longest subsequence
            # < num unmatched (kinda related to < aggregate edit distance)
            # < aggregate edit distance
            # > num prefixes
            # > num suffixes
            matches = count_by_qualifier(:equal) <=> other.count_by_qualifier(:equal)
            return matches * -1 if matches.nonzero?

            unmatched = unmatched_tokens.size <=> other.unmatched_tokens.size
            return unmatched if unmatched.nonzero?

            longest_subsequence = longest_subsequence_comparison <=> other.longest_subsequence_comparison
            return -1 * longest_subsequence if longest_subsequence.nonzero?

            edit_distance = aggregate_edit_distance <=> other.aggregate_edit_distance
            return edit_distance if edit_distance.nonzero?

            prefixes = count_by_qualifier(:prefix) <=> other.count_by_qualifier(:prefix)
            return prefixes * -1 if prefixes.nonzero?

            (count_by_qualifier(:suffix) <=> other.count_by_qualifier(:suffix)) * -1
          end

          sig { returns(String) }
          def inspect
            parts = ["["]
            token_comparisons.each do |comparison|
              parts << "\n#{comparison.inspect}"
            end
            parts << "\n" unless token_comparisons.empty?
            parts << "]"
            "<seqcomp unmatched:#{unmatched_tokens.inspect} comp:#{parts.join}/>"
          end

          sig { params(other_comparison: Comparison).returns(T::Boolean) }
          def better_than?(other_comparison)
            self < other_comparison
          end

          sig { params(other_comparison: Comparison).returns(T::Boolean) }
          def worse_than?(other_comparison)
            self > other_comparison
          end

          sig { params(other_comparison: Comparison).returns(T::Boolean) }
          def equivalent_to?(other_comparison)
            self == other_comparison
          end

          sig { params(other_comparison: Comparison).returns(Comparison) }
          def merge(other_comparison)
            AddressValidation::Token::Sequence::Comparison.new(
              unmatched_tokens: unmatched_tokens + other_comparison.unmatched_tokens,
              token_comparisons: (token_comparisons + other_comparison.token_comparisons).uniq,
              left_sequence: left_sequence.equal?(other_comparison.left_sequence) ? left_sequence : nil,
              right_sequence: right_sequence.equal?(other_comparison.right_sequence) ? right_sequence : nil,
            )
          end

          sig { returns(T::Boolean) }
          def match?
            aggregate_edit_distance == 0 && unmatched_tokens.empty?
          end

          sig { params(threshold_percent: Float).returns(T::Boolean) }
          def potential_match?(threshold_percent: DEFAULT_PARTIAL_MATCH_THRESHOLD_PERCENT)
            matched_tokens_percent >= threshold_percent && matched_length_percent >= threshold_percent
          end

          sig { returns(Integer) }
          def aggregate_edit_distance
            token_comparisons.sum(&:edit_distance)
          end

          sig { returns(Integer) }
          def token_match_count
            token_comparisons.size
          end

          protected

          sig { params(qualifier: Symbol).returns(Integer) }
          def count_by_qualifier(qualifier)
            token_comparisons.count { |comparison| comparison.qualifier == qualifier }
          end

          sig { returns([Integer, Integer]) }
          def longest_subsequence_comparison
            max_subsequence_length = subsequence_lengths.max || 0
            # max length, number of times we saw a subsequence of max length (acts as a tiebreaker)
            [max_subsequence_length, subsequence_lengths.count(max_subsequence_length)]
          end

          private

          sig { returns(T::Array[Integer]) }
          def subsequence_lengths
            # measure length of consecutive pairs of equal tokens. The position of both compared tokens
            # must increase by 1 relative to the preceeding AddressValidation::Token::Comparison's pair.
            @subsequence_lengths = equal_token_comparisons
              .chunk_while { |token_comp, next_token_comp| token_comp.preceeds?(next_token_comp) }
              .map(&:length)
              .select { |length| length > 1 } # trivial sequences of length 1 are ignored
          end

          sig { returns(T::Array[Token::Comparison]) }
          def equal_token_comparisons
            token_comparisons.select(&:equal?)
          end

          sig { returns(Float) }
          def matched_tokens_percent
            matched_tokens_count = token_comparisons.size * 2
            unmatched_tokens_count = unmatched_tokens.size
            (matched_tokens_count.to_f / (matched_tokens_count + unmatched_tokens_count)).round(2)
          end

          sig { returns(Float) }
          def matched_length_percent
            matched_length = token_comparisons.sum do |token_pair|
              token_pair.left.value.length + token_pair.right.value.length - token_pair.edit_distance
            end
            total_edit_distance = token_comparisons.sum(&:edit_distance)
            unmatched_length = unmatched_tokens.sum do |token|
              token.value.length
            end
            (matched_length.to_f / (matched_length + unmatched_length + total_edit_distance)).round(2)
          end
        end
      end
    end
  end
end
