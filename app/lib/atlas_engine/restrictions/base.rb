# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Restrictions
    module Base
      extend T::Sig
      extend T::Helpers
      interface!

      sig { abstract.params(address: AtlasEngine::AddressValidation::AbstractAddress).void }
      def apply?(address:); end
    end
  end
end
