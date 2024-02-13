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
      end
    end
  end
end
