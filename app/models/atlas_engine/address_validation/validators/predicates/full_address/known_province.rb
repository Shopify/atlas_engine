# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module FullAddress
          class KnownProvince < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              if !@cache.address_comparison&.province_code_comparison&.match? &&
                  @cache.address_comparison&.zip_comparison&.match? &&
                  @cache.address_comparison&.city_comparison&.match?
                build_concern
              end
            end

            private

            sig { returns(Concern) }
            def build_concern
              suggestion = build_suggestion
              Concern.new(
                field_names: [:province],
                code: :province_inconsistent,
                type: T.must(Concern::TYPES[:error]),
                type_level: 1,
                suggestion_ids: [T.must(suggestion.id)],
                message: message,
                suggestion: suggestion,
              )
            end

            sig { returns(String) }
            def message
              @cache.country
                .field(key: :province)
                .error(
                  code: :unknown_for_city_and_zip,
                  options: { city: address.city, zip: address.zip },
                ).to_s
            end

            sig { returns(Suggestion) }
            def build_suggestion
              Suggestion.new(
                province_code: @cache.address_comparison&.candidate&.component(:province_code)&.first_value,
                country_code: address.country_code.to_s,
              )
            end
          end
        end
      end
    end
  end
end
