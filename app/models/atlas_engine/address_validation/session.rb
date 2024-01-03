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

      sig { returns(ValidationTranscriber::AddressParsings) }
      attr_reader :parsings

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
        @parsings = T.let(
          ValidationTranscriber::AddressParsings.new(address_input: address),
          ValidationTranscriber::AddressParsings,
        )
      end

      sig { params(locale: T.nilable(T.any(String, Symbol))).returns(AtlasEngine::AddressValidation::DatastoreBase) }
      def datastore(locale: nil)
        @datastore_hash ||= T.let({}, T.nilable(T::Hash[T.untyped, AtlasEngine::AddressValidation::DatastoreBase]))
        @datastore_hash[locale] ||= AtlasEngine::AddressValidation::Es::Datastore.new(address: address)
      end
    end
  end
end
