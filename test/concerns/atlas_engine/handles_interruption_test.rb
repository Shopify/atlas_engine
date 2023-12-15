# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class HandlesInterruptionTest < ActiveSupport::TestCase
    class DummyClass
      include HandlesInterruption
    end

    setup do
      @country_import = FactoryBot.create(:country_import, :in_progress)
    end

    test "#exit_if_interrupted returns early when the country import is not failed" do
      assert_nil DummyClass.new.exit_if_interrupted!(@country_import)
    end

    test "#exit_if_interrupted raises InterruptionError when country import has failed" do
      @country_import.interrupt!
      assert_raises(CountryImport::InterruptionError) do
        DummyClass.new.exit_if_interrupted!(@country_import)
      end
    end

    test "#exit_if_interrupted fetches the state from the cache" do
      Rails.cache.with_local_cache do
        # cache warm up
        DummyClass.new.exit_if_interrupted!(@country_import)

        # if not cached, this would raise
        @country_import.interrupt!
        assert_nil(DummyClass.new.exit_if_interrupted!(@country_import))
      end
    end
  end
end
