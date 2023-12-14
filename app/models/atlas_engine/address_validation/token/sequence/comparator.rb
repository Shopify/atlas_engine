# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        class Comparator
          extend T::Sig

          sig { returns(Sequence) }
          attr_reader :left, :right

          attr_reader :comparison_cache

          MAX_ALLOWED_EDIT_DISTANCE_PERCENT = 0.5

          sig { params(left_sequence: Sequence, right_sequence: Sequence).void }
          def initialize(left_sequence:, right_sequence:)
            @left = left_sequence
            @right = right_sequence
            @comparison_cache = Hash.new do |h, (l_tok, r_tok)|
              h[[l_tok, r_tok]] = AddressValidation::Token::Comparator.new(l_tok, r_tok).compare
            end
          end

          sig { returns(Comparison) }
          def compare
            result = left.permutations.product(right.permutations).map do |left_permutation, right_permutation|
              flattened_sequence_compare(left_permutation, right_permutation)
            end

            T.must(result.min)
          end

          private

          sig do
            params(
              left_permutations: T::Array[Token],
              right_permutations: T::Array[Token],
            ).returns(T::Array[Token::Comparison])
          end
          def token_comparisons(left_permutations, right_permutations)
            left_permutations.product(right_permutations).map do |l_tok, r_tok|
              comparison_cache[[l_tok, r_tok]]
            end
          end

          sig do
            params(
              token_comparisons: T::Array[Token::Comparison],
            ).returns(T::Array[Token::Comparison])
          end
          def sort_token_comparisons(token_comparisons)
            token_comparisons.sort do |a, b|
              comp = a <=> b

              if comp == 0
                (a.left.position + a.right.position) <=> (b.left.position + b.right.position)
              else
                comp
              end
            end
          end

          sig do
            params(
              left_permutation: T::Array[Token],
              right_permutation: T::Array[Token],
            ).returns(Sequence::Comparison)
          end
          def flattened_sequence_compare(left_permutation, right_permutation)
            token_comparisons = token_comparisons(left_permutation, right_permutation)
            sorted_token_comparisons = sort_token_comparisons(token_comparisons)

            filtered_token_comparisons = []

            until sorted_token_comparisons.empty?
              closest_match = sorted_token_comparisons.shift

              if tokens_match_by_edit_distance?(comparison: T.must(closest_match))
                filtered_token_comparisons << closest_match
              end

              sorted_token_comparisons.delete_if do |comparison|
                same_token_or_position?(comparison.left, T.must(closest_match).left) ||
                  same_token_or_position?(comparison.right, T.must(closest_match).right)
              end
            end

            sorted_token_comparisons = filtered_token_comparisons.sort do |token1, token2|
              token1.left.position <=> token2.left.position
            end

            Comparison.new(
              unmatched_tokens: unmatched_tokens(left_permutation, right_permutation, sorted_token_comparisons),
              token_comparisons: sorted_token_comparisons,
              left_sequence: left,
              right_sequence: right,
            )
          end

          sig { params(comparison: AddressValidation::Token::Comparison).returns(T::Boolean) }
          def tokens_match_by_edit_distance?(comparison:)
            max_edit_distance = [comparison.left.value.length, comparison.right.value.length].max
            edit_distance_percent = comparison.edit_distance.to_f / max_edit_distance

            :prefix == comparison.qualifier || edit_distance_percent <= MAX_ALLOWED_EDIT_DISTANCE_PERCENT
          end

          sig do
            params(
              left_tokens: T::Array[Token],
              right_tokens: T::Array[Token],
              comparisons: T::Array[Token::Comparison],
            ).returns(T::Array[Token])
          end
          def unmatched_tokens(left_tokens, right_tokens, comparisons)
            remaining_left_tokens = left_tokens.reject do |token|
              comparisons.any? do |comparison|
                same_token_or_position?(comparison.left, token)
              end
            end

            remaining_left_tokens = remove_synonyms_at_same_position(remaining_left_tokens)

            remaining_right_tokens = right_tokens.reject do |token|
              comparisons.any? do |comparison|
                same_token_or_position?(comparison.right, token)
              end
            end

            remaining_right_tokens = remove_synonyms_at_same_position(remaining_right_tokens)

            remaining_left_tokens.concat(remaining_right_tokens)
          end

          sig { params(token: Token, other_token: Token).returns(T::Boolean) }
          def same_token_or_position?(token, other_token)
            return true if token == other_token

            token.offset_range == other_token.offset_range && token.position == other_token.position
          end

          sig { params(tokens: T::Array[Token]).returns(T::Array[Token]) }
          def remove_synonyms_at_same_position(tokens)
            tokens.group_by(&:position)
              .each do |_, tokens|
                tokens.reject! { |token| token.type == "SYNONYM" } if tokens.size > 1
              end
              .values.flatten
          end
        end
      end
    end
  end
end
