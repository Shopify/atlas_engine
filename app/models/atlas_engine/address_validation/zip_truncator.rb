# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class ZipTruncator
      extend T::Sig

      sig { params(country_code: String).void }
      def initialize(country_code:)
        @country_code = T.let(country_code, String)
      end

      # For some countries, we only have partial postal codes in our data.
      # Before comparing a user-provided code, we need to truncate it to the same level of detail.
      sig { params(zip: T.nilable(String), country_code: T.nilable(String)).returns(T.nilable(String)) }
      def truncate(zip:, country_code: nil)
        return if zip.nil?

        code = (country_code || @country_code).to_s.upcase
        case code
        when "IE"
          T.must(zip[..2]) # our data only has the routing key (first part)
        when "US"
          T.must(zip[..4]) # our data only has 5-digit ZIP, not 9-digit ZIP+4
        when String
          zip
        end
      end
    end
  end
end
