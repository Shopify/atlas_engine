# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      module DataMappers
        class DefaultDataMapperTest < ActiveSupport::TestCase
          setup do
            @post_address = {
              id: "123",
              locale: "EN",
              country_code: "CA",
              province_code: "AB",
              region1: "Alberta",
              region2: "Athabasca",
              region3: nil,
              region4: nil,
              city: ["Athabasca"],
              suburb: nil,
              zip: "T9S 1N5",
              street: "28 Street",
              building_name: nil,
              building_and_unit_ranges: {
                "(A1..A9)/2" => { "APT" => ["(1..4)/1"] },
                "(A12..A16)/2" => { "APT" => ["(1..4)/1"] },
                "(1011-10..1011-15)/1" => {},
              },
              latitude: 54.713363,
              longitude: -113.248051,
            }

            @country_profile = CountryProfile.for("CA")

            @mapper = AddressValidation::Es::DataMappers::DefaultDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
              locale: "EN",
            )
          end

          test "#new sets locale using post_address data if locale is not provided" do
            @mapper = AddressValidation::Es::DataMappers::DefaultDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
            )
            assert_equal @post_address[:locale], @mapper.locale
          end

          test "#map_data persists a set of fields from the post_address without modification" do
            persisted_document = @mapper.map_data

            [
              :id,
              :locale,
              :country_code,
              :province_code,
              :region1,
              :region2,
              :region3,
              :region4,
              :suburb,
              :zip,
              :street,
              :building_name,
              :latitude,
              :longitude,
            ].each do |field|
              if @post_address[field].nil?
                assert_nil persisted_document[field]
              else
                assert_equal @post_address[field], persisted_document[field]
              end
            end
          end

          test "#map_data maps city values as an array of nested aliases in the city_aliases field" do
            expected_city_aliases = [
              {
                alias: "Athabasca",
              },
            ]

            persisted_document = @mapper.map_data

            assert_equal expected_city_aliases, persisted_document[:city_aliases]
          end

          test "#map_data normalizes postal codes" do
            @post_address[:zip] = "h0h0h0"

            persisted_document = @mapper.map_data

            assert_equal "H0H 0H0", persisted_document[:zip]
          end

          test "#map_data sets street_stripped as the street value with spaces removed from the simple name" do
            @post_address[:street] = "W Red Land Blvd"

            persisted_document = @mapper.map_data

            assert_equal "W RedLand Blvd", persisted_document[:street_stripped]
          end

          test "#map_data sets street_stripped to nil when street is blank" do
            @post_address[:street] = ""

            persisted_document = @mapper.map_data

            assert_nil persisted_document[:street_stripped]
          end

          test "#map_data sets street_stripped even when actual and stripped names are the same" do
            @post_address[:street] = "W RedLand Blvd"

            persisted_document = @mapper.map_data

            assert_equal @post_address[:street], persisted_document[:street_stripped]
          end

          test "#map_data inserts a nil street_decompounded field" do
            persisted_document = @mapper.map_data

            assert persisted_document.key?(:street_decompounded)
            assert_nil persisted_document[:street_decompounded]
          end

          test "#map_data extracts building number ranges from building_and_unit_ranges" do
            approx_building_ranges = [
              {
                "gte" => 1,
                "lte" => 9,
              },
              {
                "gte" => 12,
                "lte" => 16,
              },
            ]

            persisted_document = @mapper.map_data

            assert_equal @post_address[:building_and_unit_ranges],
              JSON.parse(persisted_document[:building_and_unit_ranges])
            assert_equal approx_building_ranges, persisted_document[:approx_building_ranges]
          end

          test "#map_data extracts building numbers from building_and_unit_ranges" do
            @post_address[:building_and_unit_ranges] = { "9" => {} }
            approx_building_ranges = [
              {
                "gte" => 9,
                "lte" => 9,
              },
            ]

            persisted_document = @mapper.map_data

            assert_equal approx_building_ranges, persisted_document[:approx_building_ranges]
          end

          test "#map_data records nil approx_building_ranges with invalid building and unit range" do
            @post_address[:building_and_unit_ranges] = {
              "(1A..5)/1" => {},
            }
            @mapper = AddressValidation::Es::DataMappers::DefaultDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
            )
            assert_nil @mapper.map_data[:approx_building_ranges]
          end

          test "#map_data does not extract non-numeric building ranges from building_and_unit_ranges" do
            @post_address[:building_and_unit_ranges] = {
              "(A..E)/1" => {},
              "(1..9)/1" => {},
            }
            approx_building_ranges = [
              {
                "gte" => 1,
                "lte" => 9,
              },
            ]

            @mapper = AddressValidation::Es::DataMappers::DefaultDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
            )
            persisted_document = @mapper.map_data

            assert_equal @post_address[:building_and_unit_ranges],
              JSON.parse(persisted_document[:building_and_unit_ranges])
            assert_equal approx_building_ranges, persisted_document[:approx_building_ranges]
          end

          test "#map_data sets approx_building_ranges to nil when building_and_unit_ranges is nil" do
            @post_address[:building_and_unit_ranges] = nil

            @mapper = AddressValidation::Es::DataMappers::DefaultDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
            )

            assert_nil @mapper.map_data[:approx_building_ranges]
          end
        end
      end
    end
  end
end
