# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class FullAddressValidatorBase
      extend T::Sig
      extend T::Helpers
      abstract!

      sig { returns(Result) }
      attr_reader :result

      sig { returns(AbstractAddress) }
      attr_reader :address

      sig { params(address: AbstractAddress, result: Result).void }
      def initialize(address:, result:)
        @address = address
        @result = result
      end

      sig { abstract.returns(Result) }
      def validate; end
    end
  end
end
