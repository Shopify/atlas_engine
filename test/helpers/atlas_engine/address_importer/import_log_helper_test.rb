# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "../log_assertion_helper"

module AtlasEngine
  module AddressImporter
    class ImportLogHelperTest < ActiveSupport::TestCase
      include AtlasEngine::LogAssertionHelper

      class DummyClass
        include ::AtlasEngine::AddressImporter::ImportLogHelper
      end
      setup do
        @country_import = FactoryBot.create(:country_import, :in_progress)
      end

      test "#import_log_info logs with expected params" do
        assert_log_append(:info, "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass", "import interrupted")

        DummyClass.new.import_log_info(country_import: @country_import, message: "import interrupted")
        event = Event.find_by(country_import_id: @country_import.id)

        assert_equal "import interrupted", event.message
        assert_equal "progress", event.category
      end

      test "#import_log_error logs with expected params" do
        assert_log_append(:error, "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass", "import failed")

        with_stub_notify_events do
          DummyClass.new.import_log_error(country_import: @country_import, message: "import failed")
        end

        event = Event.find_by(country_import_id: @country_import.id)

        assert_equal "import failed", event.message
        assert_equal "error", event.category
      end

      test "#import_log_info logs with additional params" do
        additional = { "param1" => "hello" }

        assert_log_append(
          :info,
          "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass",
          "import complete",
          additional,
        )

        DummyClass.new.import_log_info(
          country_import: @country_import,
          message: "import complete",
          additional_params: additional,
        )
        event = Event.find_by(country_import_id: @country_import.id)

        assert_equal "import complete", event.message
        assert_equal additional, event.additional_params
      end

      test "#import_log_error logs with additional params" do
        additional = { "param1" => "hi" }

        assert_log_append(
          :error,
          "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass",
          "import in progress",
          additional,
        )

        with_stub_notify_events do
          DummyClass.new.import_log_error(
            country_import: @country_import,
            message: "import in progress",
            additional_params: additional,
          )
        end

        event = Event.find_by(country_import_id: @country_import.id)
        AddressImporter::ImportEventsNotifier::Notifier.unstub(:instance)

        assert_equal "import in progress", event.message
        assert_equal additional, event.additional_params
      end

      test "#import_log_info stores `null` when additional_params is {}" do
        additional = {}
        message = "unique message"

        assert_log_append(:info, "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass", message, additional)

        DummyClass.new.import_log_info(country_import: @country_import, message: message, additional_params: additional)
        event = Event.find_by(country_import_id: @country_import.id)
        AddressImporter::ImportEventsNotifier::Notifier.unstub(:instance)

        assert_equal message, event.message
        assert_nil event.additional_params
      end

      test "#import_log_error stores `null` when additional_params is {}" do
        mock_instance = mock(notify: nil)
        AddressImporter::ImportEventsNotifier::Notifier.expects(:instance).returns(mock_instance)
        additional = {}
        message = "another unique message"

        assert_log_append(:error, "AtlasEngine::AddressImporter::ImportLogHelperTest::DummyClass", message, additional)

        DummyClass.new.import_log_error(
          country_import: @country_import,
          message: message,
          additional_params: additional,
        )
        event = Event.find_by(country_import_id: @country_import.id)

        assert_equal message, event.message
        assert_nil event.additional_params
      end

      def with_stub_notify_events(notification_count = 1, &block)
        mock_instance = mock
        mock_instance.expects(:notify).times(notification_count)
        AddressImporter::ImportEventsNotifier::Notifier.expects(:instance)
          .returns(mock_instance).times(notification_count)
        yield
        AddressImporter::ImportEventsNotifier::Notifier.unstub(:instance)
      end
    end
  end
end
