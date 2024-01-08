# typed: strict
# frozen_string_literal: true

require "forwardable"

module AtlasEngine
  module AddressValidation
    class Session
      extend Forwardable
      extend T::Sig

      sig { returns(AbstractAddress) }
      attr_reader :address

      sig { returns(MatchingStrategies) }
      attr_accessor :matching_strategy

      sig { returns(T::Hash[String, AtlasEngine::AddressValidation::DatastoreBase]) }
      attr_reader :datastore_hash

      def_delegators :@address, :address1, :address2, :city, :province_code, :country_code, :zip, :phone

      sig do
        params(
          address: AbstractAddress,
          matching_strategy: MatchingStrategies,
        ).void
      end
      def initialize(address:, matching_strategy: MatchingStrategies::Es)
        @address = address
        @matching_strategy = matching_strategy
        @datastore_hash = T.let({}, T::Hash[String, AtlasEngine::AddressValidation::DatastoreBase])
      end

      sig { params(locale: T.nilable(String)).returns(ValidationTranscriber::AddressParsings) }
      def parsings(locale: nil)
        datastore(locale: locale).parsings
      end

      sig { params(locale: T.nilable(String)).returns(AtlasEngine::AddressValidation::DatastoreBase) }
      def datastore(locale: nil)
        key = locale || "default"
        @datastore_hash[key] ||= AtlasEngine::AddressValidation::Es::Datastore.new(address: address, locale: locale)
      end
    end
  end
end
