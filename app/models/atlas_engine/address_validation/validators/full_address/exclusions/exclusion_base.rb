# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        module Exclusions
          class ExclusionBase
            class << self
              extend T::Sig
              extend T::Helpers
              abstract!

              sig do
                abstract.params(
                  candidate: Candidate, # the candidate is part of the comparison, so we can remove that too
                  address_comparison: AddressComparison,
                ).returns(T::Boolean)
              end
              def apply?(candidate, address_comparison); end
            end
          end
        end
      end
    end
  end
end
