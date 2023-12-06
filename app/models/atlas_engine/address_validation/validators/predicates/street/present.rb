# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Street
          class Present < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?

              build_concern if @address.address1.blank?
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:address1],
                code: :address1_blank,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :address1).error(code: :blank).to_s,
              )
            end
          end
        end
      end
    end
  end
end
