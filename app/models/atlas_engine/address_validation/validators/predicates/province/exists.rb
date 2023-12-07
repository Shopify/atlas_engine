# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Province
          class Exists < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?
              return if address.province_code.present? ||
                country_has_no_provinces ||
                @cache.country.province_optional?

              build_concern
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:province],
                code: :province_blank,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :province)&.error(code: :blank).to_s,
              )
            end

            sig { returns(T::Boolean) }
            def country_has_no_provinces
              @cache.country.zones.blank? || @cache.country.hide_provinces_from_addresses
            end
          end
        end
      end
    end
  end
end
