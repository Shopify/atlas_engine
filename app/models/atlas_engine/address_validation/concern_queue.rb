# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class ConcernQueue
      extend T::Sig
      include Singleton

      sig { returns(Queue) }
      attr_reader :queue

      sig { void }
      def initialize
        super
        @queue = T.let(Queue.new, Queue)
      end
    end
  end
end
