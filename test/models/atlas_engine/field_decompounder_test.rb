# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class FieldDecompounderTest < ActiveSupport::TestCase
    test "#call returns the value if the country does not use decompounding" do
      country_profile = CountryProfile.for("US")
      value = "Mainstr"
      decompounder = FieldDecompounder.new(field: :street, value: value, country_profile: country_profile)

      assert_equal value, decompounder.call
    end

    test "#call returns the value if there are no decompounding patterns for the selected field" do
      country_profile = CountryProfile.for("DE")
      value = "Mainstr"
      decompounder = FieldDecompounder.new(field: :region3, value: value, country_profile: country_profile)

      assert_equal value, decompounder.call
    end

    test "#call returns the value if it does not match any field patterns" do
      country_profile = CountryProfile.for("DE")
      value = "Mainst"
      decompounder = FieldDecompounder.new(field: :street, value: value, country_profile: country_profile)

      assert_equal value, decompounder.call
    end

    test "#call successfully decompounds known patterns for the field" do
      country_profile = CountryProfile.for("DE")
      value = "Mainstr"
      decompounder = FieldDecompounder.new(field: :street, value: value, country_profile: country_profile)

      assert_equal "Main str", decompounder.call
    end

    test "#call transliterates the input before matching" do
      country_profile = CountryProfile.for("DE")

      assert_equal "Main strasse", FieldDecompounder.new(
        field: :street, value: "Mainstrasse", country_profile: country_profile,
      ).call
      assert_equal "Main strasse", FieldDecompounder.new(
        field: :street, value: "Mainstraße", country_profile: country_profile,
      ).call
    end

    test "#call preserves substrings that preceed and follow decompounded words" do
      country_profile = CountryProfile.for("DE")
      value = "Something before Mainstr 42/B"
      decompounder = FieldDecompounder.new(field: :street, value: value, country_profile: country_profile)

      assert_equal "Something before Main str 42/B", decompounder.call
    end
  end
end
