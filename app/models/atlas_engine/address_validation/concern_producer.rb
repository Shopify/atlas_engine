# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class ConcernProducer
      class << self
        extend T::Sig

        sig { params(result: Result, context: Hash).void }
        def add(result, context = {})
          return if result.concerns.empty?

          ConcernQueue.instance.queue.push(ConcernRecord.from_result(result, context))
        end
      end
    end
  end
end
