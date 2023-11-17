# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryImportTest < ActiveSupport::TestCase
    def setup
      @import = CountryImport.create(country_code: "CA")
    end

    test "state is initially set to pending" do
      assert_equal "pending", @import.state
    end

    test "start event changes state from pending to in_progress" do
      @import.start!
      assert_equal "in_progress", @import.state
    end

    test "complete event changes state from in_progress to complete" do
      @import.start!
      @import.complete!
      assert_equal "complete", @import.state
    end

    test "interrupt event changes state from pending to failed" do
      @import.interrupt!
      assert_equal "failed", @import.state
    end

    test "interrupt event changes state from in_progress to failed" do
      @import.start!
      @import.interrupt!
      assert_equal "failed", @import.state
    end

    test "cannot move from pending to in_progress when another import for same country is in progress" do
      @import.start!

      next_import = CountryImport.create(country_code: "CA")

      assert_raises do
        next_import.start!
      end
    end

    test "can interrupt a job that has already failed" do
      @import.start!
      @import.interrupt!

      assert_equal true, @import.failed?

      @import.interrupt!
    end

    test "#detected_invalid_addresses? returns true when an event with category :invalid_address exists" do
      @import.events.create(message: "foo", category: :invalid_address)
      assert_equal true, @import.detected_invalid_addresses?
    end

    test "#detected_invalid_addresses? returns false when no events with category :invalid_address exist" do
      @import.events.create(message: "bar", category: :progress)
      assert_equal false, @import.detected_invalid_addresses?
    end
  end
end
