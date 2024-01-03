# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Dk
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("DK")
      end

      test "#address_parser returns the custom DK parser" do
        assert_equal AtlasEngine::Dk::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end
    end
  end
end
