# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module ValidationTranscriber
    class AddressParserFactory
      class << self
        extend T::Sig

        sig { params(address: AddressValidation::AbstractAddress).returns(AddressParserBase) }
        def create(address:)
          raise ArgumentError, "country_code cannot be nil" if address.country_code.nil?

          CountryProfile.for(T.must(address.country_code)).validation.address_parser.new(address: address)
        end
      end
    end
  end
end
