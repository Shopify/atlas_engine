# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class ResultTest < ActiveSupport::TestCase
      def setup
        @result = Result.new
      end

      test "#add_concern" do
        assert_empty @result.concerns

        @result.add_concern(
          field_names: [:city],
          message: "Enter a city",
          code: :city_blank,
          type: "error",
          type_level: 3,
          suggestion_ids: [],
        )

        assert_equal 1, @result.concerns.size
        assert_instance_of Concern, @result.concerns.first
        assert_not_empty @result.id
      end

      test "#add_suggestions" do
        assert_empty @result.suggestions

        suggestion = Suggestion.new(
          address1: "777 Pacific Blvd",
          address2: "",
          city: "Vancouver",
          province_code: "BC",
          zip: "V6B 4Y8",
          country_code: "CA",
        )

        @result.add_suggestions([suggestion])

        assert_equal 1, @result.suggestions.size
        assert_instance_of Suggestion, @result.suggestions.first
        assert_not_empty @result.id
      end
    end
  end
end
