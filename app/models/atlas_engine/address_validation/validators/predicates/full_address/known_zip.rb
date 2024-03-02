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
                  (province_city_match? || province_street_match? || city_street_match?)
                build_concern
              end
            end

            private

            sig { returns(T::Boolean) }
            def province_city_match?
              (@cache.address_comparison&.province_code_comparison&.match? || false) &&
                (@cache.address_comparison&.city_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def province_street_match?
              (@cache.address_comparison&.province_code_comparison&.match? || false) &&
                (@cache.address_comparison&.street_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def city_street_match?
              (@cache.address_comparison&.street_comparison&.match? || false) &&
                (@cache.address_comparison&.city_comparison&.match? || false)
            end

            sig { returns(String) }
            def message
              if city_street_match?
                "Enter a valid ZIP for #{address.address1}, #{address.city}"
              elsif province_city_match?
                "Enter a valid ZIP for #{address.city}, #{province_name}"
              elsif province_street_match?
                "Enter a valid ZIP for #{address.address1}, #{province_name}"
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
                field_names: [:zip],
                code: :zip_inconsistent,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 3,
                suggestion_ids: [T.must(suggestion.id)],
                message: message,
                suggestion: suggestion,
              )
            end

            sig { returns(Suggestion) }
            def build_suggestion
              zip_suggestion = @cache.address_comparison&.candidate&.component(:zip)&.first_value
              if @cache.suggestion.nil?
                @cache.suggestion = Suggestion.new(
                  zip: zip_suggestion,
                  country_code: address.country_code.to_s,
                )
              else
                T.must(@cache.suggestion).zip = zip_suggestion
              end
              T.must(@cache.suggestion)
            end
          end
        end
      end
    end
  end
end
