# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Be
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("BE")
      end

      test "validation default_matching_strategy is set to local" do
        assert_equal "local", @profile.validation.default_matching_strategy
      end

      test "validation index_locales is set to de, fr and it" do
        assert_equal ["fr", "nl", "de"], @profile.validation.index_locales
      end
    end
  end
end
