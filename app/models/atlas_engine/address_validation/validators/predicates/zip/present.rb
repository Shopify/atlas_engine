# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class Present < ZipBase
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              build_concern if concerning?
            end

            sig { override.returns(T.nilable(T::Boolean)) }
            def concerning?
              return false unless super
              return false if @address.zip.present?
              return false if @cache.country.autofill_zip.present?

              true
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:zip],
                code: :zip_blank,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: address_zip_blank_message,
              )
            end

            sig { returns(String) }
            def address_zip_blank_message
              province_name = @cache.province.province? ? @cache.province.full_name : address.province_code
              if province_name.present?
                @cache.country.field(key: :zip).error(
                  code: :invalid_for_province,
                  options: { province: province_name },
                ).to_s
              else
                @cache.country.field(key: :zip).error(
                  code: :invalid_for_country,
                  options: { country: @cache.country.short_name },
                ).to_s
              end
            end
          end
        end
      end
    end
  end
end
