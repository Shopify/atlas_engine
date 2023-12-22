# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileValidationSubsetTest < ActiveSupport::TestCase
    # PENDING: Enable when all profiles moved
    # test "#script_restrictions returns an empty array if no script restrictions are defined" do
    #   profile = CountryProfile.for("AD")
    #   assert_equal [], profile.validation.script_restrictions
    # end

    # PENDING: Enable when all profiles moved
    # test "#script_restrictions returns the correct feature mapper if defined" do
    #   profile = CountryProfile.for("KR")
    #   assert_equal [:Hangul], profile.validation.script_restrictions
    # end

    # PENDING: Enable when all profiles moved
    # test "#restrictions returns an empty array if no restrictions are defined" do
    #   profile = CountryProfile.for("AD")
    #   assert_equal [], profile.validation.script_restrictions
    # end

    test "#restrictions returns the correct restrictions if defined" do
      profile = CountryProfile.for("GG")
      assert_equal ["Gg::AddressValidation::Validators::FullAddress::Restrictions::UnsupportedCity"], profile.validation.restrictions
    end
  end
end
