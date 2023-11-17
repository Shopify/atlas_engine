# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "log_assertion_helper"

module AtlasEngine
  class LogHelperTest < ActiveSupport::TestCase
    include LogAssertionHelper

    class DummyClass
      include LogHelper
    end

    test "log_info logs with expected params" do
      assert_log_append(:info, "AtlasEngine::LogHelperTest::DummyClass", "test")

      DummyClass.new.log_info("test")
    end

    test "log_error logs with expected params" do
      assert_log_append(:error, "AtlasEngine::LogHelperTest::DummyClass", "test")

      DummyClass.new.log_error("test")
    end

    test "log_warn logs with expected params" do
      assert_log_append(:warn, "AtlasEngine::LogHelperTest::DummyClass", "test")

      DummyClass.new.log_warn("test")
    end

    test "log_info logs with additional params" do
      assert_log_append(:info, "AtlasEngine::LogHelperTest::DummyClass", "test", { param1: "hello" })

      DummyClass.new.log_info("test", { param1: "hello" })
    end

    test "log_error logs with additional params" do
      assert_log_append(:error, "AtlasEngine::LogHelperTest::DummyClass", "test", { param1: "hi" })

      DummyClass.new.log_error("test", { param1: "hi" })
    end

    test "log_warn logs with additional params" do
      assert_log_append(:warn, "AtlasEngine::LogHelperTest::DummyClass", "test", { param1: "hello" })

      DummyClass.new.log_warn("test", { param1: "hello" })
    end
  end
end
