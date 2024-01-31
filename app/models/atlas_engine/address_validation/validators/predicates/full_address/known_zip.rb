# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module FullAddress
          class KnownZip < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              if !@cache.address_comparison&.zip_comparison&.match? &&
                  @cache.address_comparison&.province_code_comparison&.match? &&
                  @cache.address_comparison&.city_comparison&.match?
                build_concern
              end
            end

            private

            sig { returns(Concern) }
            def build_concern
              suggestion = build_suggestion
              Concern.new(
                field_names: [:zip],
                code: :zip_inconsistent,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 3,
                suggestion_ids: [T.must(suggestion.id)],
                message: "Enter a valid ZIP for #{address.address1}, #{address.city}",
                suggestion: suggestion,
              )
            end

            sig { returns(Suggestion) }
            def build_suggestion
              Suggestion.new(
                zip: @cache.address_comparison&.candidate&.component(:zip)&.first_value,
              )
            end
          end
        end
      end
    end
  end
end
