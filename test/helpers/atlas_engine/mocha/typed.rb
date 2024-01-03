# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Mocha
    # Extension for Mocha Mocks make them play well with sorbet.
    module Typed
      include(::Mocha::API)
      include(Kernel)
      extend(T::Sig)

      # A mock that will satisfy a sorbet verification check.
      sig { params(type: T.any(Module, Class)).returns(::Mocha::Mock) }
      def typed_mock(type)
        m = mock(type.to_s)
        m.stubs(is_a?: ->(x) { x == type })
        m
      end
    end
  end
end
