# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileValidationSubsetTest < ActiveSupport::TestCase
    test "#restrictions returns an empty array if no restrictions are defined" do
      profile = CountryProfile.for("AD")
      assert_empty profile.validation.restrictions
    end

    test "#restrictions returns the correct restrictions if defined" do
      profile = CountryProfile.for("GG")
      assert_equal ["AtlasEngine::Gg::AddressValidation::Validators::FullAddress::Restrictions::UnsupportedCity"], profile.validation.restrictions
    end

    test "index_locales returns the correct index locales if defined" do
      profile = CountryProfile.for("CH")
      assert_equal ["de", "fr", "it"], profile.validation.index_locales
    end

    test "index_locales returns empty array if not defined" do
      profile = CountryProfile.for("AD")
      assert_empty profile.validation.index_locales
    end
  end
end
