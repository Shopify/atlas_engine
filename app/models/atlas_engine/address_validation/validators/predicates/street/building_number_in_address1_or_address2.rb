# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        module Street
          class BuildingNumberInAddress1OrAddress2 < Predicate
            sig { override.returns(T.nilable(Concern)) }
            def evaluate
              return unless @cache.country.country?
              return unless @cache.country.building_number_required
              return unless @cache.country.building_number_may_be_in_address2
              return if contains_number?(T.must(@address.address1)) || contains_number?(T.must(@address.address2))

              build_concern
            end

            private

            sig { returns(Concern) }
            def build_concern
              Concern.new(
                field_names: [:address1, :address2, :country],
                code: :missing_building_number,
                type: T.must(Concern::TYPES[:warning]),
                type_level: 3,
                suggestion_ids: [],
                message: @cache.country.field(key: :address1)&.error(code: :missing_building_number).to_s,
              )
            end

            sig { params(text: String).returns(T::Boolean) }
            def contains_number?(text)
              /[0-9\u0660-\u0669\u06f0-\u06f9\u0966-\u096f\uff10-\uff19]/.match?(text)
            end
          end
        end
      end
    end
  end
end
