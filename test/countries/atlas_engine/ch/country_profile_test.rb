# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Ch
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("CH")
      end

      test "validation default_matching_strategy is set to local" do
        assert_equal "local", @profile.validation.default_matching_strategy
      end

      test "validation index_locales is set to de, fr and it" do
        assert_equal ["de", "fr", "it"], @profile.validation.index_locales
      end

      test "ingestion open_address_feature_mapper is correct" do
        assert_equal AtlasEngine::Ch::AddressImporter::OpenAddress::Mapper, @profile.ingestion.open_address_feature_mapper
      end

      test "#correctors value is correct for source open-address" do
        assert_equal [AtlasEngine::Ch::AddressImporter::Corrections::OpenAddress::LocaleCorrector],
          @profile.ingestion.correctors(source: "open_address")
      end
    end
  end
end
