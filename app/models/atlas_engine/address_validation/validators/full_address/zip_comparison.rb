# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ZipComparison < FieldComparisonBase
          extend T::Sig

          sig { override.returns(T.nilable(Token::Sequence::Comparison)) }
          def compare
            return @zip_comparison if defined?(@zip_comparison)

            candidate.component(:zip)&.value = PostalCodeMatcher.new(
              T.must(address.country_code),
              T.must(address.zip),
              candidate.component(:zip)&.value,
            ).truncate

            normalized_zip = ValidationTranscriber::ZipNormalizer.normalize(
              country_code: address.country_code, zip: address.zip,
            )

            zip_sequence = Token::Sequence.from_string(normalized_zip)

            @zip_comparison = best_comparison(
              zip_sequence,
              T.must(candidate.component(:zip)).sequences,
              field_policy(:zip),
            )
          end
        end
      end
    end
  end
end
