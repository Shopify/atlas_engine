# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module TokenHelper
      def token(hash)
        AddressValidation::Token.new(start_offset: 0, end_offset: 0, position: 0, **hash)
      end

      def sequence(*token_values)
        offset = 0

        tokens = token_values.map.with_index do |value, index|
          end_offset = offset + value.length

          if value.is_a?(Array)
            t = value.map do |v|
              token(value: v, start_offset: offset, end_offset: end_offset, type: "<SYNONYM>", position: index)
            end
          else
            type = value.is_a?(Numeric) ? "<NUM>" : "<ALPHANUM>"
            t = token(value: value, start_offset: offset, end_offset: end_offset, type: type, position: index)
          end

          offset = end_offset + 1

          t
        end.flatten

        raw_value = sequence_raw_value(token_values)
        AddressValidation::Token::Sequence.new(tokens: tokens, raw_value: raw_value)
      end

      def sequences(*token_values)
        token_values.map.with_index do |value, _|
          offset = 0

          type = value.is_a?(Numeric) ? "<NUM>" : "<ALPHANUM>"

          t = value.map.with_index do |val, index|
            end_offset = offset + val.length
            tok = token(value: val, start_offset: offset, end_offset: end_offset, type: type, position: index)
            offset = end_offset + 1

            tok
          end

          t
        end.map do |tkns|
          raw_value = sequence_raw_value(tkns)
          AddressValidation::Token::Sequence.new(tokens: tkns.flatten, raw_value: raw_value)
        end
      end

      def token_comparison(left:, right:, qualifier: :equal, edit: 0)
        AddressValidation::Token::Comparison.new(
          left: left,
          right: right,
          qualifier: qualifier,
          edit_distance: edit,
        )
      end

      sig do
        params(
          unmatched_tokens: T::Array[AddressValidation::Token],
          token_comparisons: T::Array[AddressValidation::Token::Comparison],
          left_sequence: T.nilable(AddressValidation::Token::Sequence),
          right_sequence: T.nilable(AddressValidation::Token::Sequence),
        ).returns(AddressValidation::Token::Sequence::Comparison)
      end
      def sequence_comparison(
        unmatched_tokens: [],
        token_comparisons: [],
        left_sequence: nil,
        right_sequence: nil
      )
        AddressValidation::Token::Sequence::Comparison.new(
          unmatched_tokens: unmatched_tokens,
          token_comparisons: token_comparisons,
          left_sequence: left_sequence,
          right_sequence: right_sequence,
        )
      end

      def assert_tokens_equal(token1, token2)
        # the _analyze API returns token types, but the _mtermvectors one does not.
        assert_equal(token1.instance_values.except("type"), token2.instance_values.except("type"))
      end

      def assert_sequences_equal(sequence1, sequence2)
        assert_equal(sequence1.size, sequence2.size)
        sequence1.tokens.each_with_index do |token, index|
          assert_tokens_equal(token, sequence2.tokens[index])
        end
      end

      def assert_sequence_array_equality(sequence1, sequence2)
        assert_equal(sequence1.size, sequence2.size)

        s1 = sequence1.map(&:tokens).flatten
        s2 = sequence2.map(&:tokens).flatten

        (0..s1.size - 1).each do |i|
          assert_tokens_equal(s1[i], s2[i])
        end
      end

      def assert_comparison(
        expected_left_token,
        qualifier,
        expected_right_token,
        comparison,
        edit_distance = 0
      )
        assert_equal(expected_left_token, comparison.left)
        assert_equal(qualifier, comparison.qualifier)
        assert_equal(expected_right_token, comparison.right)
        assert_equal(edit_distance, comparison.edit_distance)
      end

      def assert_token(data:, value:, s_offset:, e_offset:, pos:, pos_len: 1)
        assert_equal(value, data[:value])
        assert_equal(s_offset, data[:start_offset])
        assert_equal(e_offset, data[:end_offset])
        assert_equal(pos, data[:position])
        assert_equal(pos_len, data[:position_length])
      end

      def as_hash_array(sequence)
        tokens = sequence.respond_to?(:tokens) ? sequence.tokens : sequence
        tokens.map do |t|
          if t.is_a?(Array)
            t.map { |tok| as_hash(tok) }
          else
            as_hash(t)
          end
        end
      end

      def assert_same_elements(a1, a2, msg = nil)
        [:select, :inject, :size].each do |m|
          [a1, a2].each do |a|
            assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.")
          end
        end

        assert(a1h = a1.index_with do |e|
                 a1.select { |i| i == e }.size
               end)
        assert(a2h = a2.index_with do |e|
                 a2.select { |i| i == e }.size
               end)

        assert_equal(a1h, a2h, msg)
      end

      private

      def sequence_raw_value(tokens)
        tokens.map do |token|
          if token.is_a?(Array)
            token.any?(Array) ? token.first.first : token.first
          else
            token.respond_to?(:value) ? token.value : token
          end
        end.join(" ")
      end

      def as_hash(token)
        token.instance_values.transform_keys(&:to_sym).except(:offset_range)
      end
    end
  end
end
