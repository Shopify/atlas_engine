# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Sequence
        extend T::Sig

        class << self
          extend T::Sig
          include Normalizer
          ACCEPTABLE_CHARACTERS = /\p{Alnum}/

          sig { params(string: T.nilable(String)).returns(Sequence) }
          def from_string(string)
            start_offset = 0
            end_offset = 0
            position = 0

            tokens = Annex29.segment_words(string).filter_map do |substring|
              start_offset = end_offset
              end_offset = start_offset + substring.length

              normalized_substring = normalize(substring)
              # annex 29 returns whitespace and punctuation as separate substrings
              next unless normalized_substring.match?(ACCEPTABLE_CHARACTERS)

              token = Token.new(
                value: normalized_substring,
                start_offset: start_offset,
                end_offset: end_offset,
                position: position,
                type: number?(substring) ? "<NUM>" : "<ALPHANUM>",
              )

              position += 1

              token
            end

            new(tokens: tokens, raw_value: string)
          end

          def number?(string)
            !Float(string).nil?
          rescue
            false
          end
        end

        TokenOrSynonyms = T.type_alias { T.any(Token, Synonyms) }

        sig { returns(T::Array[TokenOrSynonyms]) }
        attr_reader :tokens

        sig { returns(T.nilable(String)) }
        attr_reader :raw_value

        # Sorbet can't handle delegates https://github.com/sorbet/sorbet/issues/4794
        # rubocop:disable Rails/Delegate
        sig { returns(T::Boolean) }
        def empty? = tokens.empty?

        sig { returns(Integer) }
        def size = tokens.size

        sig { returns(Integer) }
        def length = tokens.length
        # rubocop:enable Rails/Delegate

        sig { params(tokens: T::Array[Token], raw_value: T.nilable(String)).void }
        def initialize(tokens: [], raw_value: nil)
          @raw_value = raw_value
          @tokens = group_by_overlapping_offsets(tokens)
            .map { |tkns| tkns.one? ? T.must(tkns.first) : Synonyms.new(tokens: tkns) }
        end

        sig { returns(String) }
        def inspect
          "<seq #{tokens.inspect}/>"
        end

        sig { returns(T::Array[T::Array[Token]]) }
        def permutations = recursive_permutations(tokens)

        def ==(other)
          return false unless other.is_a?(Sequence)

          tokens == other.tokens
        end

        private

        sig { params(token_array: T::Array[TokenOrSynonyms]).returns(T::Array[T::Array[Token]]) }
        def recursive_permutations(token_array)
          # we bottom out when token_array contains only simple tokens
          next_synonyms_index = token_array.find_index { |entry| entry.is_a?(Synonyms) }
          # There are no synonyms in that array, cast is safe
          return [T.cast(token_array, T::Array[Token])] unless next_synonyms_index

          new_tokens = token_array.dup
          synonyms = T.cast(new_tokens[next_synonyms_index], Synonyms)
          new_tokens.delete_at(next_synonyms_index)

          if synonyms.multi_token?
            # token_array (before synonyms object was deleted):  [a, b, <syn [afb, [air, force, base]]/>, ...rest]
            # output: [[a, b, afb, ...rest], [a, b, air, force, base, ...rest]]
            synonyms.tokens.flat_map do |multi_token_entry|
              current_permutation = T.unsafe(new_tokens).dup.insert(next_synonyms_index, *Array(multi_token_entry))
              # ...rest will be handled recursively
              recursive_permutations(current_permutation)
            end
          else
            # token_array (before synonyms object was deleted):  [a, b, <syn [st, street, saint/>, ...rest]
            # output: [[a, b, st, street, saint, ...rest]]
            T.unsafe(new_tokens).insert(next_synonyms_index, *synonyms.tokens)
            # ...rest will be handled recursively
            recursive_permutations(new_tokens)
          end
        end

        sig { params(tokens: T::Array[Token]).returns(T::Array[T::Array[Token]]) }
        def group_by_overlapping_offsets(tokens)
          return [] if tokens.empty?

          sorted_tokens = tokens.stable_sort_by(&:position)
          current_range = sorted_tokens.first&.offset_range

          groups = []
          current_group = []
          sorted_tokens.each do |token|
            if current_range.cover?(token.offset_range)
              current_group << token
            else
              groups << current_group
              current_group = [token]
              current_range = token.offset_range
            end
          end

          groups << current_group
        end
      end
    end
  end
end
