# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class DefaultProfileTest < ActiveSupport::TestCase
    setup do
      @profile = CountryProfile.for(CountryProfile::DEFAULT_PROFILE)
    end

    test ".allow_partial_zip value is correct" do
      assert_not @profile.ingestion.allow_partial_zip?
    end

    test ".correctors value is correct" do
      assert_equal [], @profile.ingestion.correctors(source: "abc")
    end

    test ".validation.validation_exclusions value is correct" do
      assert_equal [], @profile.validation.validation_exclusions(component: "bogus")
    end

    test ".validation.enabled is correct" do
      assert_not @profile.validation.enabled
    end

    test ".validation.partial_postal_code_range value is correct" do
      assert_nil @profile.validation.partial_postal_code_range(1)
    end

    test ".validation.normalized_components value is correct" do
      assert_equal [], @profile.validation.normalized_components
    end
  end
end
