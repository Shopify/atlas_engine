# typed: false
# frozen_string_literal: true

require "test_helper"
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

        test ".for returns a query builder if locale is provided for a multi-locale country" do
          profile_attributes = {
            "id" => "CH_DE",
            "validation" => {
              "index_locales" => ["de", "fr"],
              "query_builder" => "AtlasEngine::AddressValidation::Es::DefaultQueryBuilder",
            },
          }
          CountryProfile.expects(:for).with("CH", "de").returns(CountryProfile.new(profile_attributes)).at_least_once

          query_builder = QueryBuilder.for(ch_address, "de")
          assert_instance_of(Es::DefaultQueryBuilder, query_builder)
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

        def ch_address
          build_address(
            address1: "2 Florastrasse",
            city: "Uster",
            country_code: "CH",
            zip: "8610",
          )
        end
      end
    end
  end
end
