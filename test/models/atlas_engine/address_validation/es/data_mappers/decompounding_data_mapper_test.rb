# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      module DataMappers
        class DecompoundingDataMapperTest < ActiveSupport::TestCase
          setup do
            @post_address = {
              id: "123",
              locale: "DE",
              country_code: "DE",
              province_code: nil,
              region1: "Baden-Württemberg",
              region2: "Freiburg",
              region3: "Breisgau-Hochschwarzwald",
              region4: "Bad Krozingen",
              city: ["Bad Krozingen"],
              suburb: nil,
              zip: "79189",
              street: "Albanstraße",
              building_name: nil,
              building_and_unit_ranges: {
                "(A1..A9)/2" => { "APT" => ["(1..4)/1"] },
                "(A12..A16)/2" => { "APT" => ["(1..4)/1"] },
                "(1011-10..1011-15)/1" => {},
              },
              latitude: 47.9078,
              longitude: 7.70541,
            }

            @country_profile = CountryProfile.for("DE")

            @mapper = DecompoundingDataMapper.new(
              post_address: @post_address,
              country_profile: @country_profile,
              locale: "DE",
            )
          end

          test "#map_data preserves keys from the PostAddress record" do
            persisted_document = @mapper.map_data

            expected_fields = [
              :id,
              :locale,
              :country_code,
              :province_code,
              :region1,
              :region2,
              :region3,
              :region4,
              :city_aliases,
              :suburb,
              :zip,
              :street,
              :street_stripped,
              :street_decompounded,
              :building_and_unit_ranges,
              :approx_building_ranges,
              :building_name,
              :latitude,
              :longitude,
              :location,
            ]

            assert_equal expected_fields, persisted_document.keys
          end

          test "#map_data handles nil decompoundable fields" do
            @post_address[:street] = nil
            persisted_document = @mapper.map_data

            assert_nil persisted_document[:street_decompounded]
          end

          test "#map_data decompounds fields according to the configured patterns" do
            persisted_document = @mapper.map_data

            assert_equal "Alban strasse", persisted_document[:street_decompounded]
          end
        end
      end
    end
  end
end
