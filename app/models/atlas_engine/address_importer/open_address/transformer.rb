# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class Transformer
        extend T::Sig
        extend T::Helpers

        def initialize(country_import:, locale: nil)
          @country_code = country_import.country_code
          @locale = locale
          @mapper = CountryProfile.for(@country_code).ingestion.post_address_mapper("open_address").new(
            country_code: @country_code, locale: @locale,
          )
          @corrector = AddressImporter::Corrections::Corrector.new(country_code: @country_code, source: "open_address")
          @validator = AddressImporter::Validation::Wrapper.new(
            country_import: country_import,
            log_invalid_records: false,
          )
        end

        sig do
          params(feature: Feature)
            .returns(T.nilable(T::Hash[Symbol, T.untyped]))
        end
        def transform(feature)
          address_hash = @mapper.map(feature)

          @corrector.apply(address_hash)
          return if address_hash.blank?

          address_hash if @validator.valid?(address_hash)
        end
      end
    end
  end
end
