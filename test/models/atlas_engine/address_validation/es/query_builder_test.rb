# typed: false
# frozen_string_literal: true

require "test_helper"
require "minitest/autorun"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class QueryBuilderTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test ".for with an address having an invalid country code raises an error" do
          assert_raises(CountryProfile::CountryNotFoundError) do
            QueryBuilder.for(invalid_country_address)
          end
        end

        test ".for returns a QueryBuilder for a US address" do
          query_builder = QueryBuilder.for(us_address)
          assert query_builder.is_a?(Es::DefaultQueryBuilder)
        end

        test ".for returns a GbQueryBuilder for a UK address" do
          query_builder = QueryBuilder.for(gb_address)
          assert query_builder.is_a?(Gb::AddressValidation::Es::QueryBuilder)
        end

        private

        def us_address
          build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def invalid_country_address
          build_address(
            address1: "123 Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "ZZ",
            zip: "94102",
          )
        end

        def gb_address
          build_address(
            address1: "17 Regency Street",
            city: "London",
            province_code: nil,
            country_code: "GB",
            zip: "SW1P 4BY",
          )
        end
      end
    end
  end
end
