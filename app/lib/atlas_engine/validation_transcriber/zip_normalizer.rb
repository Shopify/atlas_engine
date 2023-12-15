# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class ZipNormalizer
      class << self
        extend T::Sig

        sig { params(country_code: T.nilable(String), zip: T.nilable(String)).returns(T.nilable(String)) }
        def normalize(country_code:, zip:)
          if country_code.present? && Worldwide.region(code: country_code).valid_zip?(zip)
            AddressValidation::ZipTruncator.new(country_code: country_code).truncate(
              zip: Worldwide::Zip.normalize(country_code: country_code, zip: zip, strip_extraneous_characters: true),
            )
          else
            Worldwide::Zip.normalize(country_code: country_code, zip: zip)
          end
        end
      end
    end
  end
end
