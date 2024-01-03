# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("PL")
      end

      test "#address_parser returns the custom PL parser" do
        assert_equal Pl::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end
    end
  end
end
