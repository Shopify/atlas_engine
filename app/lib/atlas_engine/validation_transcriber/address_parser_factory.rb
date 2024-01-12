# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserFactory
      class << self
        extend T::Sig

        sig do
          params(address: AddressValidation::AbstractAddress, locale: T.nilable(String)).returns(AddressParserBase)
        end
        def create(address:, locale: nil)
          raise ArgumentError, "country_code cannot be nil" if address.country_code.nil?

          profile = CountryProfile.for(T.must(address.country_code), locale)

          if locale.nil? && profile.validation.multi_locale?
            raise ArgumentError, "#{address.country_code} is a multi-locale country and requires a locale"
          end

          profile.validation.address_parser.new(address: address)
        end
      end
    end
  end
end
