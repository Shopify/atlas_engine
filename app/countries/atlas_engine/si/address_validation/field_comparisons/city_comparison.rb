# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Si
    module AddressValidation
      module FieldComparisons
        class CityComparison < AtlasEngine::AddressValidation::Validators::FullAddress::FieldComparisonBase
          extend T::Sig

          def match?
            @matched ||= super || acceptable_city_match?
          end

          sig { override.returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)) }
          def sequence_comparison
            best_comparison(
              datastore.fetch_city_sequence,
              T.must(candidate.component(:city)).sequences,
              field_policy(:city),
            )
          end

          private

          sig { returns(T::Boolean) }
          def acceptable_city_match?
            return false if sequence_comparison.nil?

            T.must(sequence_comparison).aggregate_distance <= 2
          end
        end
      end
    end
  end
end
