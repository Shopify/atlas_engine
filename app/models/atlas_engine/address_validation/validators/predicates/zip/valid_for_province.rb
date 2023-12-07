# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Zip
          class ValidForProvince < ZipBase
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              build_concern if concerning?
            end

            sig { override.returns(T.nilable(T::Boolean)) }
            def concerning?
              return false unless super
              return false if @address.zip.blank?
              return false if @cache.country.hide_provinces_from_addresses
              return false if @address.province_code.blank?
              return false unless @cache.province.province?
              return false if @cache.province.valid_zip?(@address.zip)

              true
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:zip, :country, :province],
                code: :zip_invalid_for_province,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: invalid_for_province_message,
              )
            end

            sig { returns(String) }
            def invalid_for_province_message
              province_name = @cache.province.province? ? @cache.province.full_name : address.province_code

              @cache.country.field(key: :zip).error(
                code: :invalid_for_province,
                options: { province: province_name },
              ).to_s
            end
          end
        end
      end
    end
  end
end
