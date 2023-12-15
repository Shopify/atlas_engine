# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class FrenchStreetParserTest < ActiveSupport::TestCase
      test "identifies main components as expected" do
        [
          [:ca, :fr, "rue Principale", { name: "Principale", suffix: "rue" }],
          [:ca, :fr, "rue Principale Ouest", { name: "Principale", suffix: "rue", post_directional: "Ouest" }],
          [:ca, :fr, "rue William nord-ouest", { name: "William", suffix: "rue", post_directional: "nord-ouest" }],
        ].each do |_country_code, locale, input, expected|
          actual = StreetParser.new.parse(locale: locale, street: input)
          assert_equal(expected.to_set, actual.to_set, "called via StreetParser, input was #{input.inspect}")

          # This interface isn't intended to be used by client code.
          # Rather, it'll be called via StreetParser as above.
          # Reaching "under the hood" like this isn't what I would normally do in a unit test, but
          # if we're going to split tests for each language parser out into a separate file, then
          # I guess we might as well explicitly call the subclass directly, too.
          actual = FrenchStreetParser.new.parse(street: input)
          assert_equal(expected.to_set, actual.to_set, "direct call on input #{input.inspect}")
        end
      end
    end
  end
end
