# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module FullAddress
          class KnownCity < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              if !@cache.address_comparison&.city_comparison&.match? &&
                  (province_zip_match? || province_street_match? || zip_street_match?)
                build_concern
              end
            end

            private

            sig { returns(T::Boolean) }
            def province_zip_match?
              (@cache.address_comparison&.province_code_comparison&.match? || false) &&
                (@cache.address_comparison&.zip_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def province_street_match?
              (@cache.address_comparison&.province_code_comparison&.match? || false) &&
                (@cache.address_comparison&.street_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def zip_street_match?
              (@cache.address_comparison&.zip_comparison&.match? || false) &&
                (@cache.address_comparison&.street_comparison&.match? || false)
            end

            sig { returns(String) }
            def message
              if province_street_match?
                "Enter a valid city for #{address.address1}, #{province_name}"
              elsif province_zip_match?
                "Enter a valid city for #{address.zip}, #{province_name}"
              elsif zip_street_match?
                "Enter a valid city for #{address.address1}, #{address.zip}"
              else
                ""
              end
            end

            sig { returns(String) }
            def province_name
              return "" if address.country_code.blank? || address.province_code.blank?

              @cache.province.province? && @cache.province.full_name ? @cache.province.full_name : address.province_code
            end

            sig { returns(Concern) }
            def build_concern
              suggestion = build_suggestion
              Concern.new(
                field_names: [:city],
                code: :city_inconsistent,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 3,
                suggestion_ids: [T.must(suggestion.id)],
                message: message,
                suggestion: suggestion,
              )
            end

            sig { returns(Suggestion) }
            def build_suggestion
              Suggestion.new(
                city: @cache.address_comparison&.candidate&.component(:city)&.first_value,
              )
            end
          end
        end
      end
    end
  end
end
