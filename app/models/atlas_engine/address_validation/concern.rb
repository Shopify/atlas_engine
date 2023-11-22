# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Concern
      extend T::Sig

      TYPES = T.let(
        {
          warning: "warning",
          error: "error",
        }.freeze,
        T::Hash[Symbol, String],
      )

      sig { returns(Symbol) }
      attr_reader :code

      sig { returns(String) }
      attr_reader :message

      sig { returns(String) }
      attr_reader :type

      sig { returns(Integer) }
      attr_reader :type_level

      sig { returns(T::Array[String]) }
      attr_reader :suggestion_ids

      sig { returns(T::Array[Symbol]) }
      attr_reader :field_names

      sig { returns(T.nilable(Suggestion)) }
      attr_reader :suggestion

      alias_attribute :component_names, :field_names

      sig do
        params(
          code: Symbol,
          message: String,
          type: String,
          type_level: Integer,
          suggestion_ids: T::Array[String],
          field_names: T::Array[Symbol],
          suggestion: T.nilable(Suggestion),
        ).void
      end
      def initialize(code:, message:, type:, type_level:, suggestion_ids:, field_names:, suggestion: nil)
        @code = code
        @type = type
        @type_level = type_level
        @suggestion_ids = suggestion_ids
        @field_names = field_names
        @message = message
        @suggestion = T.let(suggestion, T.nilable(Suggestion))
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def attributes
        {
          field_names: field_names,
          message: message,
          code: code,
          type: type,
          type_level: type_level,
          suggestion_ids: suggestion_ids,
        }
      end
    end
  end
end
