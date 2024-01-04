# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Li
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("LI")
      end

      test "#correctors value is correct for source open-address" do
        assert_equal [Li::AddressImporter::Corrections::OpenAddress::CityCorrector],
          @profile.ingestion.correctors(source: "open_address")
      end

      test "#data_mapper value is correct" do
        assert_equal AtlasEngine::AddressValidation::Es::DataMappers::DecompoundingDataMapper,
          @profile.ingestion.data_mapper
      end

      test "#validation.normalized_components value is correct" do
        assert_equal ["region2", "region3", "region4", "city_aliases.alias", "suburb", "street_decompounded"],
          @profile.validation.normalized_components
      end

      test "#address_parser returns the custom AT parser" do
        assert_equal AtlasEngine::At::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end

      test "#decompounding_patterns returns patterns for the :street field" do
        assert_not_empty @profile.decompounding_patterns(:street)
      end
    end
  end
end
