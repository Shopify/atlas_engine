# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module FullAddress
          class KnownStreet < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return if @cache.address_comparison&.street_comparison.nil?

              if !@cache.address_comparison&.street_comparison&.match? &&
                  (province_zip_match? || province_city_match? || zip_city_match?)
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
            def province_city_match?
              (@cache.address_comparison&.province_code_comparison&.match? || false) &&
                (@cache.address_comparison&.city_comparison&.match? || false)
            end

            sig { returns(T::Boolean) }
            def zip_city_match?
              (@cache.address_comparison&.zip_comparison&.match? || false) &&
                (@cache.address_comparison&.city_comparison&.match? || false)
            end

            sig { returns(String) }
            def message
              if province_city_match?
                "Enter a valid street name for #{address.city}, #{province_name}"
              elsif province_zip_match?
                "Enter a valid street name for #{address.zip}, #{province_name}"
              elsif zip_city_match?
                "Enter a valid street name for #{address.city}, #{address.zip}"
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
                field_names: [:address1],
                code: :street_inconsistent,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 3,
                suggestion_ids: [T.must(suggestion.id)],
                message: message,
                suggestion: suggestion,
              )
            end

            sig { returns(Suggestion) }
            def build_suggestion
              sequence_comparison = @cache.address_comparison&.street_comparison&.sequence_comparison

              suggested_street = sequence_comparison&.right_sequence&.raw_value
              original_street = sequence_comparison&.left_sequence&.raw_value

              if @cache.suggestion.nil?
                @cache.suggestion = if address.address1.to_s.include?(original_street)
                  Suggestion.new(
                    address1: address1.to_s.sub(original_street, suggested_street),
                    country_code: address.country_code.to_s,
                  )
                else
                  Suggestion.new(
                    address2: address2.to_s.sub(original_street, suggested_street),
                    country_code: address.country_code.to_s,
                  )
                end
              elsif address.address1.to_s.include?(original_street)
                T.must(@cache.suggestion).address1 = address1.to_s.sub(original_street, suggested_street)
              else
                T.must(@cache.suggestion).address2 = address2.to_s.sub(original_street, suggested_street)
              end
              T.must(@cache.suggestion)
            end
          end
        end
      end
    end
  end
end
