# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class EnglishStreetParserTest < ActiveSupport::TestCase
      test "identifies main components as expected" do
        [
          [:ca, :en, "Main Street", { name: "Main", suffix: "Street" }],
          [:ca, :en, "West Main Street", { pre_directional: "West", name: "Main", suffix: "Street" }],
          [:ca, :en, "William Street Northwest", { name: "William", suffix: "Street", post_directional: "Northwest" }],
        ].each do |_country_code, locale, input, expected|
          # This is the "public" interface that we should care about working
          actual = StreetParser.new.parse(locale: locale, street: input)
          assert_equal(expected.to_set, actual.to_set, "called via StreetParser, input was #{input.inspect}")

          # This interface isn't intended to be used by client code.
          # Rather, it'll be called via StreetParser as above.
          # Reaching "under the hood" like this isn't what I would normally do in a unit test, but
          # if we're going to split tests for each language parser out into a separate file, then
          # I guess we might as well explicitly call the subclass directly, too.
          actual = EnglishStreetParser.new.parse(street: input)
          assert_equal(expected.to_set, actual.to_set, "direct call on input #{input.inspect}")
        end
      end
    end
  end
end
