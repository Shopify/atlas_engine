# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class EventTest < ActiveSupport::TestCase
    def setup
      @import = CountryImport.create(country_code: "CA")
    end

    test "event can be created with valid attributes" do
      event = Event.create!(country_import: @import, message: "foo", category: :error)
      assert event.valid?
    end

    test "requires a country import" do
      assert_raises ActiveRecord::RecordInvalid do
        Event.create!(message: "foo")
      end
    end

    test "requires a message" do
      assert_raises ActiveRecord::RecordInvalid do
        Event.create!(country_import: @import)
      end
    end

    test "rejects unrecognized categories" do
      assert_raises ArgumentError do
        Event.create!(country_import: @import, message: "foo", category: :bar)
      end
    end
  end
end
