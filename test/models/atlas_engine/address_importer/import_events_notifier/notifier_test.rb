# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module ImportEventsNotifier
      class NotifierTest < ActiveSupport::TestCase
        def setup
          @mock_event = Event.new(
            country_import_id: 1,
            message: "mock_message",
            category: :progress,
            additional_params: {},
          )
        end

        test ".instance fetches the right instance" do
          assert_equal Notifier, Notifier.instance.class
        end
      end
    end
  end
end
