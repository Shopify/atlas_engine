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

      sig { params(type: T.any(Module, Class)).returns(::Mocha::Mock) }
      def instance_double(type)
        mock = typed_mock(type)

        if type < ActiveRecord::Base
          # Call new so that column backed methods are defined
          mock.responds_like(T.unsafe(type).new)
        elsif type.is_a?(Class)
          mock.responds_like(type.allocate)
        elsif type.is_a?(Module)
          mock.responds_like(Class.new.include(type).allocate)
        end

        mock
      end
    end
  end
end
