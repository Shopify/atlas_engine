# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class ValidForCountry < ZipBase
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              build_concern if concerning?
            end

            sig { override.returns(T.nilable(T::Boolean)) }
            def concerning?
              return false unless super
              return false if @address.zip.blank?
              return false if @cache.country.valid_zip?(@address.zip)

              true
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:zip, :country],
                code: :zip_invalid_for_country,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :zip).error(
                  code: :invalid_for_country,
                  options: { country: @cache.country.short_name },
                ).to_s,
              )
            end
          end
        end
      end
    end
  end
end
