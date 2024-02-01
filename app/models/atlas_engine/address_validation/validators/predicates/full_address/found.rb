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
              build_concern if @cache.address_comparison.nil? || too_many_unmatched_components?
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

            # TODO: ideally this could be filtered out in the address_comparison
            sig { returns(T::Boolean) }
            def too_many_unmatched_components?
              unmatched_component_count = @cache.address_comparison&.comparisons&.map(&:match?)&.count(false) || 0
              unmatched_component_count > unmatched_components_suggestion_threshold
            end

            sig { returns(Integer) }
            def unmatched_components_suggestion_threshold
              country_profile = CountryProfile.for(address.country_code.to_s)
              country_profile.validation.unmatched_components_suggestion_threshold
            end
          end
        end
      end
    end
  end
end
