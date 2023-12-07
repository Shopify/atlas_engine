# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Fr
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("FR")
      end

      test ".correctors value is correct for source open_address" do
        assert_equal [AtlasEngine::Fr::AddressImporter::Corrections::OpenAddress::CityCorrector],
          @profile.ingestion.correctors(source: "open_address")
      end
    end
  end
end
