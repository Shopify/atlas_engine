# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    class ValidationType < BaseObject
      description "An address validation result object"

      field :id, String, null: false
      field :fields, [AddressValidation::FieldType], null: false
      field :validation_scope, [String], null: false
      field :concerns, [AddressValidation::ConcernType], null: false
      field :suggestions, [AddressValidation::SuggestionType], null: false
      field :locale, String, null: false
      field :candidate,
        String,
        null: true,
        deprecation_reason: "Temporary field meant for internal use only."
      field :matching_strategy, Types::MatchingStrategyType, null: false
    end
  end
end
