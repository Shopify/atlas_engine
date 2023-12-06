# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Province
          class ValidForCountry < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?
              return if address.province_code.blank?
              return if @cache.country.zones.none?(&:province?)
              return if @cache.country.hide_provinces_from_addresses

              unless @cache.province.province?
                build_concern
              end
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:province, :country],
                code: :province_invalid,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :province).error(code: :blank),
              )
            end

            sig { params(province: T.nilable(String)).returns(T.nilable(String)) }
            def normalize_province(province)
              ValidationTranscriber::ProvinceCodeNormalizer.normalize(
                country_code: @cache.country.iso_code,
                province_code: province,
              )
            end
          end
        end
      end
    end
  end
end
