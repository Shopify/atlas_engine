# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pl
    module AddressValidation
      module Exclusions
        class RuralAddress < AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
          extend T::Sig

          class << self
            sig do
              override.params(
                candidate: AtlasEngine::AddressValidation::Candidate,
                address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
              ).returns(T::Boolean)
            end
            def apply?(candidate, address_comparison)
              rural_address?(candidate) && poor_city_match?(address_comparison)
            end

            private

            def poor_city_match?(address_comparison)
              address_comparison.city_comparison.sequence_comparison.aggregate_distance > 2 # this is a nilable field?
            end

            sig { params(candidate: AtlasEngine::AddressValidation::Candidate).returns(T::Boolean) }
            def rural_address?(candidate)
              return false if candidate.component(:city)&.values.blank?

              street = candidate.component(:street)&.first_value
              city_values = T.must(candidate.component(:city)&.values)
              city_values.any?(street)
            end
          end
        end
      end
    end
  end
end
