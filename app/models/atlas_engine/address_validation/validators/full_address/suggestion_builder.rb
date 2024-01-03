# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class SuggestionBuilder
          class << self
            extend T::Sig
            sig do
              params(
                address: {
                  address1: T.nilable(String),
                  address2: T.nilable(String),
                  city: T.nilable(String),
                  province_code: T.nilable(String),
                  country_code: T.nilable(String),
                  zip: T.nilable(String),
                  phone: T.nilable(String),
                },
                comparisons: T::Hash[Symbol, AtlasEngine::AddressValidation::Token::Sequence::Comparison],
                candidate: AddressValidation::Candidate,
                unmatched_fields: T::Hash[Symbol, Symbol],
              ).returns(Suggestion)
            end
            def from_comparisons(address, comparisons, candidate, unmatched_fields = {})
              unmatched_address_keys = comparisons.keys.each_with_object([]) do |key, array|
                array << if key == :street
                  unmatched_fields[:street]
                else
                  key
                end
              end.append(:country_code).compact

              suggestion = Suggestion.new(**T.unsafe(address).slice(*unmatched_address_keys))

              comparisons.each do |key, comparison|
                # suggestion.send("suggest_#{key}", comparison, candidate, unmatched_fields)
                case key
                when :street
                  suggest_street(suggestion, comparison, candidate, unmatched_fields)
                when :city
                  suggest_city(suggestion, comparison, candidate, unmatched_fields)
                when :zip
                  suggest_zip(suggestion, comparison, candidate, unmatched_fields)
                when :province_code
                  suggest_province_code(suggestion, comparison, candidate, unmatched_fields)
                end
              end

              # Since the suggestion does not suggest the new country, we can safely remove it.
              suggestion.country_code = nil

              suggestion
            end

            private

            sig do
              params(
                suggestion: Suggestion,
                comparison: AtlasEngine::AddressValidation::Token::Sequence::Comparison,
                candidate: AddressValidation::Candidate,
                unmatched_fields: T::Hash[Symbol, Symbol],
              ).returns(Suggestion)
            end
            def suggest_street(suggestion, comparison, candidate, unmatched_fields)
              suggested_street = comparison.right_sequence.raw_value
              original_street = comparison.left_sequence.raw_value
              field = unmatched_fields[:street]

              if field == :address1
                suggestion.address1 = suggestion.address1.to_s.sub(original_street, suggested_street)
              elsif field == :address2
                suggestion.address2 = suggestion.address2.to_s.sub(original_street, suggested_street)
              end

              suggestion
            end

            sig do
              params(
                suggestion: Suggestion,
                comparison: AtlasEngine::AddressValidation::Token::Sequence::Comparison,
                candidate: AddressValidation::Candidate,
                _unmatched_fields: T::Hash[Symbol, Symbol],
              ).returns(Suggestion)
            end
            def suggest_city(suggestion, comparison, candidate, _unmatched_fields)
              suggestion.city = generic_field_suggestion(comparison, candidate, :city)
              suggestion
            end

            sig do
              params(
                suggestion: Suggestion,
                comparison: AtlasEngine::AddressValidation::Token::Sequence::Comparison,
                candidate: AddressValidation::Candidate,
                _unmatched_fields: T::Hash[Symbol, Symbol],
              ).returns(Suggestion)
            end
            def suggest_zip(suggestion, comparison, candidate, _unmatched_fields)
              suggestion.zip = generic_field_suggestion(comparison, candidate, :zip)
              suggestion
            end

            sig do
              params(
                suggestion: Suggestion,
                comparison: AtlasEngine::AddressValidation::Token::Sequence::Comparison,
                candidate: AddressValidation::Candidate,
                _unmatched_fields: T::Hash[Symbol, Symbol],
              ).returns(Suggestion)
            end
            def suggest_province_code(suggestion, comparison, candidate, _unmatched_fields)
              suggestion.province_code = generic_field_suggestion(comparison, candidate, :province_code)
              suggestion
            end

            sig do
              params(
                comparison: AtlasEngine::AddressValidation::Token::Sequence::Comparison,
                candidate: AddressValidation::Candidate,
                field: Symbol,
              ).returns(String)
            end
            def generic_field_suggestion(comparison, candidate, field)
              if comparison.token_match_count == 0 || comparison.aggregate_edit_distance > 2
                candidate.component(field)&.first_value
              else
                comparison.right_sequence.raw_value
              end
            end
          end
        end
      end
    end
  end
end
