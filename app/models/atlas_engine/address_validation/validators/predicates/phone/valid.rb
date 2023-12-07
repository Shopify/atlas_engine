# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Phone
          class Valid < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return if @address.country_code.blank?
              return unless @cache.country.country?
              return if @address.phone.blank?

              phone = Worldwide::Phone.new(number: @address.phone, country_code: @address.country_code)

              return if phone.valid?

              build_concern
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:phone],
                code: :phone_invalid,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :phone).error(code: :invalid).to_s,
              )
            end
          end
        end
      end
    end
  end
end
