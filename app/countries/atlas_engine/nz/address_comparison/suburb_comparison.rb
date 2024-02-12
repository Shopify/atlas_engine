# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Nz
    module AddressComparison
      class SuburbComparison < AtlasEngine::AddressValidation::Validators::FullAddress::FieldComparisonBase
        extend T::Sig

        sig { override.returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison)) }
        def sequence_comparison
          return @suburb_comparison if defined?(@suburb_comparison)

          suburb_sequences = datastore.parsings.parsings.pluck(:suburb).uniq.compact.map do |suburb|
            AtlasEngine::AddressValidation::Token::Sequence.from_string(suburb)
          end

          candidate_sequences = T.must(candidate.component(:suburb)).sequences

          @suburb_comparison = suburb_sequences.map do |street_sequence|
            best_comparison(
              street_sequence,
              candidate_sequences,
              field_policy(:suburb),
            )
          end.min
        end
      end
    end
  end
end
