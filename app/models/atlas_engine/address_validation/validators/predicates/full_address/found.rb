# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module FullAddress
          class Found < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              build_concern if @cache.address_comparison.nil?
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:address1],
                code: :address_unknown,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 1,
                suggestion_ids: [],
                message: @cache.country.field(key: :address).error(code: :may_not_exist).to_s,
              )
            end
          end
        end
      end
    end
  end
end
