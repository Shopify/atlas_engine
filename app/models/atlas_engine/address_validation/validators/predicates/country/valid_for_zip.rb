# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Country
          class ValidForZip < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?
              return if @address.zip.blank?

              suggested_country = Worldwide::Zip.find_country(
                country_code: @address.country_code,
                zip: @address.zip,
              )

              return if suggested_country.nil? ||
                suggested_country.iso_code == @address.country_code

              build_concern(build_suggestion(suggested_country.iso_code))
            end

            private

            sig { params(suggestion: Suggestion).returns(Concern) }
            def build_concern(suggestion)
              Concern.new(
                field_names: [:country, :zip],
                code: :country_invalid_for_zip,
                type: T.must(Concern::TYPES[:error]),
                type_level: 1,
                suggestion_ids: [T.must(suggestion.id)],
                message: @cache.country.field(key: :zip).error(
                  code: :invalid_for_country,
                  options: { country: @cache.country.full_name },
                ),
                suggestion: suggestion,
              )
            end

            sig { params(suggested_country_code: String).returns(Suggestion) }
            def build_suggestion(suggested_country_code)
              Suggestion.new(
                address1: address1,
                address2: address2,
                city: city,
                zip: zip,
                province_code: province_code,
                country_code: suggested_country_code,
              )
            end
          end
        end
      end
    end
  end
end
