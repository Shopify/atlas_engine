# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module De
    class ProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("DE")
      end

      test "#address_parser returns the custom DE parser" do
        assert_equal De::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end

      test ".validation.normalized_components value is correct" do
        assert_equal ["region2", "region3", "region4", "city_aliases.alias", "suburb", "street_decompounded"],
          @profile.validation.normalized_components
      end
    end
  end
end
