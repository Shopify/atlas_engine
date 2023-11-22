# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class SuggestionTest < ActiveSupport::TestCase
      def setup
        @address = {
          address1: "123 First Avenue",
          address2: nil,
          city: "San Francisco",
          province_code: "CA",
          country_code: "US",
          zip: "94102",
          phone: nil,
        }
      end

      test "#province returns nil if the province_code is nil" do
        suggestion = Suggestion.new(
          address1: "123 Main street",
          address2: nil,
          city: "Plainfield",
          province_code: nil,
          country_code: "US",
          zip: "01070",
        )

        assert_nil suggestion.province
      end

      test "#province returns nil if the province_code is invalid for the country" do
        suggestion = Suggestion.new(
          address1: "123 Main street",
          address2: nil,
          city: "Plainfield",
          province_code: "XX",
          country_code: "US",
          zip: "01070",
        )

        assert_nil suggestion.province
      end

      test "#province returns the zone name if the province_code is valid" do
        suggestion = Suggestion.new(
          address1: "123 Main street",
          address2: nil,
          city: "Plainfield",
          province_code: "MA",
          country_code: "US",
          zip: "01070",
        )

        assert_equal "Massachusetts", suggestion.province
      end

      test "#province changes if the province_code is updated" do
        suggestion = Suggestion.new(
          address1: "123 Main street",
          address2: nil,
          city: "Plainfield",
          province_code: "MA",
          country_code: "US",
          zip: "01070",
        )

        suggestion.province_code = "ND"

        assert_equal "North Dakota", suggestion.province
      end

      test "#province_code returns JP-XX format for Japan province codes" do
        suggestion = Suggestion.new(
          address1: "5-10 Yochōmachi",
          address2: nil,
          city: "Shinjuku",
          province_code: "JP-13",
          country_code: "JP",
          zip: "162-0055",
        )

        assert_equal "JP-13", suggestion.province_code
      end

      test "#province_code returns XX format for other country codes" do
        suggestion = Suggestion.new(
          address1: "123 Main street",
          address2: nil,
          city: "Plainfield",
          province_code: "US-MA",
          country_code: "US",
          zip: "01070",
        )

        assert_equal "MA", suggestion.province_code
      end
    end
  end
end
