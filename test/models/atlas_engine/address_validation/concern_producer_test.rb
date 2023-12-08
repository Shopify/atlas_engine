# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class ConcernProducerTest < ActiveSupport::TestCase
      def setup
        @mock_concern = Concern.new(
          code: :test,
          message: "test",
          type: "warning",
          type_level: 1,
          field_names: [:test],
          suggestion_ids: [],
        )
        @result_with_concern = Result.new(concerns: [@mock_concern])
      end

      def teardown
        queue.clear
      end

      test "something" do
        assert(true)
      end

      test "#add does not add concerns to queue when there are none" do
        result = Result.new(concerns: [])

        AddressValidation::ConcernProducer.add(result)
        assert_equal(0, queue.size)
      end

      test "#add adds a concern record to queue when there are concerns" do
        AddressValidation::ConcernProducer.add(@result_with_concern)
        assert_equal(1, queue.size)
      end

      private

      def queue
        AddressValidation::ConcernQueue.instance.queue
      end
    end
  end
end
