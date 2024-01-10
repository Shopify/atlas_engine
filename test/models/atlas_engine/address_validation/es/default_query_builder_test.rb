# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      class DefaultQueryBuilderTest < ActiveSupport::TestCase
        include AddressValidation::AddressValidationTestHelper

        test ".initialize with an address having an invalid country code raises an error" do
          assert_raises(CountryProfile::CountryNotFoundError) do
            DefaultQueryBuilder.new(invalid_country_address)
          end
        end

        test "#full_address_query returns a query with the correct fields for US" do
          query_builder = DefaultQueryBuilder.new(us_address)
          assert_equal expected_address_query("us"), query_builder.full_address_query
        end

        test "#full_address_query returns a query with the correct fields for a country using the defaults" do
          query_builder = DefaultQueryBuilder.new(mx_address)
          assert_equal expected_address_query("mx"), query_builder.full_address_query
        end

        test "#full_address_query returns a valid query for an input missing a building number" do
          query_builder = DefaultQueryBuilder.new(missing_number_address)
          assert_equal expected_address_query("us_missing"), query_builder.full_address_query
        end

        test "#full_address_query returns a query with minimum_should_match of at least 2" do
          query_builder = DefaultQueryBuilder.new(us_address)
          query_builder.stubs(:city_clause).returns(nil)
          query_builder.stubs(:zip_clause).returns(nil)
          query_builder.stubs(:province_clause).returns(nil)

          assert_equal expected_address_query("with_under_4_clauses"), query_builder.full_address_query
        end

        test "#full_address_query returns a valid query for an input with address1 and address2" do
          query_builder = DefaultQueryBuilder.new(us_a2_address)
          assert_equal expected_address_query("us_a2"), query_builder.full_address_query
        end

        test "#full_address_query returns valid query when there is fractional building number in 1 address line" do
          query_builder = DefaultQueryBuilder.new(us_a1_a2_fractional_building_num_address)
          assert_equal(
            expected_address_query("with_fractional_building_number"),
            query_builder.full_address_query,
          )
        end

        test "#full_address_query returns partial building_num_clause if there is a fractional building number\"
            with street name in 1 address line" do
          query_builder = DefaultQueryBuilder.new(us_a1_fractional_building_num_address)
          assert_equal expected_address_query("without_building_number"), query_builder.full_address_query
        end

        test "#full_address_query adds two street clauses when the street name contains several words" do
          query_builder = DefaultQueryBuilder.new(us_compound_street_name_address)
          assert_equal expected_address_query("us_compound_street_name"), query_builder.full_address_query
        end

        test "#full_address_query does not return a province clause if validation.has_provinces is false " do
          profile_attributes = {
            "id" => "XX",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => false,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          }

          CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)
          query_builder = DefaultQueryBuilder.new(us_address)
          assert_equal expected_address_query("without_province_code"), query_builder.full_address_query
        end

        test "#full_address_query does not return a province clause if validation.has_provinces is nil " do
          profile_attributes = {
            "id" => "XX",
            "validation" => {
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          }

          CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)
          query_builder = DefaultQueryBuilder.new(us_address)
          assert_equal expected_address_query("without_province_code"), query_builder.full_address_query
        end

        test "#full_address_query returns nested city_aliases clause" do
          profile_attributes = {
            "id" => "XX",
            "validation" => {
              "key" => "some_value",
              "has_provinces" => true,
              "address_parser" => "AtlasEngine::ValidationTranscriber::AddressParserNorthAmerica",
            },
          }

          CountryProfile.any_instance.stubs(:attributes).returns(profile_attributes)
          query_builder = DefaultQueryBuilder.new(us_address)
          assert_equal expected_address_query("nested_city_aliases_one_city_field"), query_builder.full_address_query
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

        def us_a2_address
          build_address(
            address1: "123",
            address2: "Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_a1_fractional_building_num_address
          build_address(
            address1: "123 1/2 Main Street",
            address2: nil,
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_a1_a2_fractional_building_num_address
          build_address(
            address1: "123 1/2",
            address2: "Main Street",
            city: "San Francisco",
            province_code: "CA",
            country_code: "US",
            zip: "94102",
          )
        end

        def us_compound_street_name_address
          build_address(
            address1: "18108 S Park View Dr",
            city: "Houston",
            province_code: "TX",
            country_code: "US",
            zip: "77084",
          )
        end

        def missing_number_address
          build_address(
            address1: "Main Street",
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

        def mx_address
          build_address(
            address1: "Avenida Justo Sierra Méndez 491",
            city: "Campeche",
            province_code: "CAMP",
            country_code: "MX",
            zip: "24040",
          )
        end
      end
    end
  end
end
