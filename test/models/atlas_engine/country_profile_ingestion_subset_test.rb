# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileIngestionSubsetTest < ActiveSupport::TestCase
    test "#open_address_feature_mapper returns the DefaultMapper if no mapper is defined" do
      profile = CountryProfile.for("AD")
      assert_equal AtlasEngine::AddressImporter::OpenAddress::DefaultMapper,
        profile.ingestion.open_address_feature_mapper
    end

    test "#open_address_feature_mapper returns the correct feature mapper if defined" do
      profile = CountryProfile.for("AU")
      assert_equal AtlasEngine::Au::AddressImporter::OpenAddress::Mapper, profile.ingestion.open_address_feature_mapper
    end
  end
end
