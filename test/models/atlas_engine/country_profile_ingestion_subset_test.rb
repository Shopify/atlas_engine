# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileIngestionSubsetTest < ActiveSupport::TestCase
    test "#open_address_feature_mapper returns the DefaultMapper if no mapper is defined" do
      # PENDING: enable once all ingestion profiles moved
      skip

      profile = CountryProfile.for("AD")
      assert_equal "AddressImporter::OpenAddress::DefaultMapper", profile.ingestion.open_address_feature_mapper.class
    end

    # test "#open_address_feature_mapper returns the correct feature mapper if defined" do
    #   # PENDING: enable once all ingestion profiles moved
    #   skip

    #   profile = CountryProfile.for("AU")
    #   assert_equal AddressImporter::OpenAddress::Au::Mapper, profile.ingestion.open_address_feature_mapper
    # end
  end
end
