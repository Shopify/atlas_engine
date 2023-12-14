# typed: true
# frozen_string_literal: true

require "rubygems/text"

module AtlasEngine
  module AddressValidation
    class Token
      class Comparator
        extend T::Sig
        include Gem::Text

        sig { returns(Token) }
        attr_reader :left, :right

        sig { params(left_token: Token, right_token: Token).void }
        def initialize(left_token, right_token)
          @left = T.let(left_token, Token)
          @right = T.let(right_token, Token)
        end

        sig { returns(Comparison) }
        def compare
          left_value = left.value
          right_value = right.value

          if left_value == right_value
            Comparison.new(left: left, right: right, qualifier: :equal, edit_distance: 0)
          else
            edit = levenshtein_distance(left_value, right_value)

            if right_value.start_with?(left_value) || left_value.start_with?(right_value)
              Comparison.new(left: left, right: right, qualifier: :prefix, edit_distance: edit)
            elsif right_value.end_with?(left_value) || left_value.end_with?(right_value)
              Comparison.new(left: left, right: right, qualifier: :suffix, edit_distance: edit)
            else
              Comparison.new(left: left, right: right, qualifier: :comp, edit_distance: edit)
            end
          end
        end
      end
    end
  end
end
