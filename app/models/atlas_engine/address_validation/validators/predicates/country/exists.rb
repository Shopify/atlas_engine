# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Country
          class Exists < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              build_concern unless @address.country_code.present? &&
                @cache.country.country?
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:country],
                code: :country_blank,
                type: T.must(Concern::TYPES[:error]),
                type_level: 3,
                suggestion_ids: [],
                message: Worldwide.region(code: "US").field(key: :country).error(code: :blank),
              )
            end
          end
        end
      end
    end
  end
end
