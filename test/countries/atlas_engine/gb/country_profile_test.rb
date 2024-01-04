# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Gb
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("GB")
      end

      test "#address_parser returns the custom GB parser" do
        assert_equal("AtlasEngine::Gb::AddressValidation::Es::QueryBuilder", @profile.validation.query_builder)
      end
    end
  end
end
