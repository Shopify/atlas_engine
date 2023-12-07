# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module City
          class Present < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?
              return if @cache.country.field(key: :city).autofill(locale: :en).present?

              build_concern if @address.city.blank?
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:city],
                code: :city_blank,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :city).error(code: :blank).to_s,
              )
            end
          end
        end
      end
    end
  end
end
