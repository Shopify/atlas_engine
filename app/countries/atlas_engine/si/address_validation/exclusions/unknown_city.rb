# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module AddressValidation
      module Exclusions
        class UnknownCity < AtlasEngine::AddressValidation::Validators::FullAddress::Exclusions::ExclusionBase
          extend T::Sig

          class << self
            sig do
              override.params(
                candidate: AtlasEngine::AddressValidation::Candidate,
                address_comparison: AtlasEngine::AddressValidation::Validators::FullAddress::AddressComparison,
              ).returns(T::Boolean)
            end
            def apply?(candidate, address_comparison)
              poor_city_match?(address_comparison)
            end

            private

            def poor_city_match?(address_comparison)
              address_comparison.city_comparison.sequence_comparison.aggregate_distance > 2 # this is a nilable field?
            end
          end
        end
      end
    end
  end
end
