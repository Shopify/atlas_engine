# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Restrictions
    module Base
      extend T::Sig
      extend T::Helpers
      interface!

      sig do
        abstract.params(
          address: AtlasEngine::AddressValidation::AbstractAddress,
          params: T.untyped,
        ).returns(T::Boolean)
      end
      def apply?(address:, params: nil); end
    end
  end
end
