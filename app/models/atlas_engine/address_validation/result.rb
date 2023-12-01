# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Result
      extend T::Sig

      SORTED_VALIDATION_SCOPES = T.let(
        [:country_code, :province_code, :zip, :city, :address1, :address2, :phone].freeze,
        T::Array[Symbol],
      )

      sig { returns(T.nilable(String)) }
      attr_accessor :client_request_id

      sig { returns(T.nilable(String)) }
      attr_accessor :origin

      sig { returns(T::Array[Field]) }
      attr_accessor :fields

      sig { returns(T::Array[Concern]) }
      attr_accessor :concerns

      sig { returns(T::Array[Suggestion]) }
      attr_accessor :suggestions

      sig { returns(T::Array[String]) }
      attr_accessor :validation_scope

      sig { returns(String) }
      attr_accessor :locale

      sig { returns(T.nilable(String)) }
      attr_accessor :candidate

      sig { returns(T::Array[Errors]) }
      attr_accessor :errors

      sig { returns(String) }
      attr_reader :id

      sig { returns(T.nilable(String)) }
      attr_reader :matching_strategy

      alias_attribute :components, :fields

      sig do
        params(
          client_request_id: T.nilable(String),
          origin: T.nilable(String),
          fields: T::Array[Field],
          concerns: T::Array[Concern],
          suggestions: T::Array[Suggestion],
          validation_scope: T::Array[String],
          errors: T::Array[Errors],
          locale: String,
          candidate: T.nilable(String),
          matching_strategy: T.nilable(String),
        ).void
      end
      def initialize(
        client_request_id: nil,
        origin: nil,
        fields: [],
        concerns: [],
        suggestions: [],
        validation_scope: [],
        errors: [],
        locale: "en",
        candidate: nil,
        matching_strategy: nil
      )
        @origin = origin
        @client_request_id = client_request_id
        @fields = fields
        @concerns = concerns
        @suggestions = suggestions
        @validation_scope = validation_scope
        @errors = errors
        @locale = locale
        @candidate = candidate
        @matching_strategy = matching_strategy

        # For now, this UUID isn't predicated on anything and is random.
        # There could be need in the future to help make this unique on all requests.
        # For now, what is important is that it one is simply generated and assigned.
        @id = T.let(generate_id, String)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def attributes
        {
          id: id,
          fields: fields.map(&:attributes),
          concerns: concerns.map(&:attributes),
          suggestions: suggestions.map(&:attributes),
          validation_scope: validation_scope,
          locale: locale,
        }
      end

      sig do
        params(
          code: Symbol,
          type: String,
          type_level: Integer,
          suggestion_ids: T::Array[String],
          field_names: T::Array[Symbol],
          message: String,
        ).returns(Concern)
      end
      def add_concern(code:, type:, type_level:, suggestion_ids:, field_names:, message:)
        new_concern = Concern.new(
          field_names: field_names,
          code: code,
          type: type,
          type_level: type_level,
          suggestion_ids: suggestion_ids,
          message: message,
        )
        concerns << new_concern
        new_concern
      end

      sig do
        params(suggestions_to_add: T::Array[Suggestion]).returns(T::Array[T::Array[Suggestion]])
      end
      def add_suggestions(suggestions_to_add)
        suggestions_to_add.map { |suggestion| suggestions << suggestion }
      end

      sig { returns(String) }
      def completion_service
        "AddressValidation"
      end

      sig { returns(T::Hash[Symbol, T.nilable(String)]) }
      def address
        fields.each_with_object({}) do |field, hash|
          hash[field.name.to_sym] = field.value.to_s
        end
      end

      private

      sig { returns(String) }
      def generate_id
        Digest::UUID.uuid_v4
      end
    end
  end
end
