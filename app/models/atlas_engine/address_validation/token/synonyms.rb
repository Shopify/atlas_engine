# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Synonyms
        extend T::Sig
        # Similar to a Token, and has some of the same methods like position, value, type.

        TokenList = T.type_alias { T::Array[Token] }

        sig { returns(T::Array[T.any(Token, TokenList)]) }
        attr_reader :tokens

        # Sorbet can't handle delegates https://github.com/sorbet/sorbet/issues/4794
        # rubocop:disable Rails/Delegate
        sig { returns(Integer) }
        def position = first_token.position

        sig { returns(T::Range[Integer]) }
        def offset_range = first_token.offset_range
        # rubocop:enable Rails/Delegate

        sig { params(tokens: T::Array[Token]).void }
        def initialize(tokens: [])
          raise ArgumentError, "Synonyms cannot be empty" if tokens.empty?

          @tokens = []
          tokens_by_position = tokens.stable_sort_by(&:position).group_by(&:position)

          while tokens_by_position.values.any?(&:present?)
            current_group = []
            starting_position = tokens_by_position.keys.first

            while tokens_by_position.key?(starting_position)
              token = T.must(tokens_by_position[starting_position]).shift
              current_group << token
              starting_position += T.must(token).position_length
            end

            @tokens << (current_group.one? ? current_group.first : current_group)
            tokens_by_position.compact_blank! # remove positions having no tokens
          end
        end

        sig { returns(String) }
        def inspect
          "<syn #{tokens.inspect}/>"
        end

        sig { returns(NilClass) }
        def value
          nil
        end

        sig { returns(String) }
        def type
          "<SYNONYMS>"
        end

        sig { returns(T::Boolean) }
        def multi_token?
          tokens.any?(Array)
        end

        private

        sig { returns(Token) }
        def first_token
          head = T.must(tokens.first)
          head.is_a?(Array) ? T.must(head.first) : head
        end
      end
    end
  end
end
