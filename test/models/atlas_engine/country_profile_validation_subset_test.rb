# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileValidationSubsetTest < ActiveSupport::TestCase
    test "index_locales returns the correct index locales if defined" do
      profile_attributes = {
        "id" => "CH",
        "validation" => {
          "index_locales" => ["de", "fr", "it"],
        },
      }
      assert_equal ["de", "fr", "it"], CountryProfile.new(profile_attributes).validation.index_locales
    end

    test "index_locales returns empty array if not defined" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {},
      }
      assert_empty CountryProfile.new(profile_attributes).validation.index_locales
    end

    test "multi_locale? returns true if country is multi-locale" do
      profile_attributes = {
        "id" => "CH",
        "validation" => {
          "index_locales" => ["de", "fr", "it"],
        },
      }
      assert CountryProfile.new(profile_attributes).validation.multi_locale?
    end

    test "multi_locale? returns false if country has no configured index_locales" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {},
      }
      assert_not CountryProfile.new(profile_attributes).validation.multi_locale?
    end

    test "multi_locale? returns false if country has only one locale" do
      profile_attributes = {
        "id" => "DE",
        "validation" => {
          "index_locales" => ["de"],
        },
      }
      assert_not CountryProfile.new(profile_attributes).validation.multi_locale?
    end
  end
end
