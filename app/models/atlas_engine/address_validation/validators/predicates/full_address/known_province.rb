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
                  (city_zip_match? || city_street_match? || zip_street_match?)
                build_concern
              end
            end

            private

            sig { returns(T::Boolean) }
            def city_zip_match?
              (@cache.address_comparison&.city_comparison&.match? || false) &&
                (@cache.address_comparison&.zip_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def city_street_match?
              (@cache.address_comparison&.city_comparison&.match? || false) &&
                (@cache.address_comparison&.street_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def zip_street_match?
              (@cache.address_comparison&.zip_comparison&.match? || false) &&
                (@cache.address_comparison&.street_comparison&.match? || false)
            end

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
              if city_zip_match?
                "Enter a valid province for #{address.city}, #{address.zip}"
              elsif city_street_match?
                "Enter a valid province for #{address.address1}, #{address.city}"
              elsif zip_street_match?
                "Enter a valid province for #{address.address1}, #{address.zip}"
              else
                ""
              end
            end

            sig { returns(Suggestion) }
            def build_suggestion
              province_code_suggestion = @cache.address_comparison&.candidate&.component(:province_code)&.first_value

              if @cache.suggestion.nil?
                @cache.suggestion = Suggestion.new(
                  province_code: @cache.address_comparison&.candidate&.component(:province_code)&.first_value,
                  country_code: address.country_code.to_s,
                )
              else
                T.must(@cache.suggestion).province_code = province_code_suggestion
              end
              T.must(@cache.suggestion)
            end
          end
        end
      end
    end
  end
end
