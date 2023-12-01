# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Field
      extend T::Sig

      Name = T.type_alias { T.any(String, Symbol) }
      Value = T.type_alias { T.nilable(String) }

      sig { returns(Name) }
      attr_reader :name

      sig { returns(Value) }
      attr_reader :value

      sig { params(name: Name, value: Value).void }
      def initialize(name:, value:)
        @name = name
        @value = value
      end

      sig { returns(T::Hash[Symbol, T.any(Name, Value)]) }
      def attributes
        { name: name, value: value }
      end
    end
  end
end
