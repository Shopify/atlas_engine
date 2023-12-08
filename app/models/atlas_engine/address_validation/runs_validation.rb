# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module RunsValidation
      extend T::Sig
      extend T::Helpers

      interface!

      sig { abstract.returns(Result) }
      def run; end
    end
  end
end
