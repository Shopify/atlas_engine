# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Nl
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("NL")
      end

      test "#correctors value is correct for source open-address" do
        assert_equal [Nl::AddressImporter::Corrections::OpenAddress::CityCorrector],
          @profile.ingestion.correctors(source: "open_address")
      end

      test "#data_mapper value is correct" do
        assert_equal AddressValidation::Es::DataMappers::DecompoundingDataMapper,
          @profile.ingestion.data_mapper
      end

      test "#validation.normalized_components value is correct" do
        assert_equal ["street_decompounded"],
          @profile.validation.normalized_components
      end

      test "#address_parser returns the custom NL parser" do
        assert_equal Nl::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end

      test "#decompounding_patterns returns patterns for the :street field" do
        assert_not_empty @profile.decompounding_patterns(:street)
      end
    end
  end
end
