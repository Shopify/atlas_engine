# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module AddressValidation
      module FieldComparisons
        class CityComparison < AtlasEngine::AddressValidation::Validators::FullAddress::CityComparison
          extend T::Sig

          def match?
            @matched ||= super || exclude_city?
          end

          private

          sig { returns(T::Boolean) }
          def exclude_city?
            return true if sequence_comparison.nil?

            # we want to ignore city if more than 3 chars are off. returning true allows the code to behave this way.
            T.must(sequence_comparison).aggregate_distance > 2
          end
        end
      end
    end
  end
end
