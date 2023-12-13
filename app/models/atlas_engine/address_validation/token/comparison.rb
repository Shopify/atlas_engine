# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Token
      class Comparison
        extend T::Sig
        include Comparable

        QUALIFIERS = T.let(
          [:equal, :prefix, :suffix, :comp].freeze,
          T::Array[Symbol],
        )

        sig { returns(Token) }
        attr_reader :left, :right

        sig { returns(Symbol) }
        attr_reader :qualifier

        sig { returns(Integer) }
        attr_reader :edit_distance

        sig do
          params(
            left: Token,
            right: Token,
            qualifier: Symbol,
            edit_distance: Integer,
          ).void
        end
        def initialize(left:, right:, qualifier:, edit_distance:)
          raise "Unknown qualifier" unless qualifier.in?(QUALIFIERS)

          @left = left
          @right = right
          @qualifier = qualifier
          @edit_distance = edit_distance
        end

        sig { params(other: Comparison).returns(Integer) }
        def <=>(other)
          if edit_distance == other.edit_distance
            qualifier_rank <=> other.qualifier_rank
          else
            edit_distance <=> other.edit_distance
          end
        end

        sig { returns(T::Boolean) }
        def equal?
          qualifier == :equal
        end

        sig { params(other: Comparison).returns(T::Boolean) }
        def preceeds?(other)
          left.preceeds?(other.left) && right.preceeds?(other.right)
        end

        sig { returns(String) }
        def inspect
          "<comp left:#{left.inspect} #{qualifier.to_s.upcase} right:#{right.inspect} edit:#{edit_distance}/>"
        end

        protected

        sig { returns(Integer) }
        def qualifier_rank
          # Constructor verifies that qualifier is in the list
          T.must(QUALIFIERS.find_index(qualifier))
        end
      end
    end
  end
end
