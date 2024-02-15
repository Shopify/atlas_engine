# typed: true
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Si
    class CountryProfileTest < ActiveSupport::TestCase
      setup do
        @profile = CountryProfile.for("SI")
      end

      test "#correctors value is correct for source open-address" do
        assert_equal [
          Si::AddressImporter::OpenAddress::Corrections::CityDistrictCorrector,
        ],
          @profile.ingestion.correctors(source: "open_address")
      end

      test "#post_address_mapper value is correct for source open-address" do
        assert_equal AtlasEngine::Si::AddressImporter::OpenAddress::Mapper,
          @profile.ingestion.post_address_mapper("open_address")
      end

      test "#validation_exclusions value is correct for city component" do
        assert_equal [
          Si::AddressValidation::Exclusions::UnknownCity,
        ],
          @profile.validation.validation_exclusions(component: :city)
      end

      test "#address_parser returns the custom SI parser" do
        assert_equal Si::ValidationTranscriber::AddressParser,
          @profile.validation.address_parser
      end

      test "#comparison_policy value is correct for street component" do
        street_policy = @profile.validation.comparison_policy(:street)

        assert_equal :ignore_right_unmatched, street_policy.unmatched
      end
    end
  end
end
