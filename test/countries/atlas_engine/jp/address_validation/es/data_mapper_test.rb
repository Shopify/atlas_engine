# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Jp
    module AddressValidation
      module Es
        class DataMapperTest < ActiveSupport::TestCase
          def setup
            @en_address = FactoryBot.build(:jp_address, :en_full, {
              province_code: "JP-23",
              region1: "Chubu",
              region2: "Aichi",
              region3: "Chita",
              region4: "Mihama",
              city: ["Kowa"],
              suburb: "Kamimaeda",
              zip: "470-2409",
              street: nil,
              latitude: 34.7663,
              longitude: 136.912,
            })

            @ja_address = FactoryBot.build(:jp_address, :ja_full, {
              province_code: "JP-23",
              region1: "中部地方",
              region2: "愛知県",
              region3: "知多郡",
              region4: "美浜町",
              city: ["河和"],
              suburb: "上前田",
              zip: "470-2409",
              street: nil,
              latitude: 34.7663,
              longitude: 136.912,
            })

            @country_profile = CountryProfile.for("JP")
          end

          test "#map_data maps en addresses correctly" do
            mapped = AddressValidation::Es::DataMapper.new(
              post_address: @en_address,
              country_profile: @country_profile,
              locale: "en-CA",
            ).map_data

            assert_equal "Kowa", mapped[:region3]
            assert_equal [{ alias: "Chita" }], mapped[:city_aliases]
            assert_equal "Kowa, Mihama", mapped[:street]
          end

          test "#map_data formats street correctly when region4 is nil or empty" do
            [nil, ""].each do |region4|
              @en_address.region4 = region4

              mapped = AddressValidation::Es::DataMapper.new(
                post_address: @en_address,
                country_profile: @country_profile,
                locale: "en-CA",
              ).map_data

              assert_equal "Kowa", mapped[:street]
            end
          end

          test "#map_data maps ja addresses correctly" do
            mapped = AddressValidation::Es::DataMapper.new(
              post_address: @ja_address,
              country_profile: @country_profile,
              locale: "ja-JP",
            ).map_data

            assert_equal "河和", mapped[:region3]
            assert_equal [{ alias: "知多郡" }], mapped[:city_aliases]
            assert_equal "美浜町河和", mapped[:street]
          end

          test "#map_data does not create a street with city component as `Others` for EN locale" do
            @en_address.city = ["Others"]

            mapped = AddressValidation::Es::DataMapper.new(
              post_address: @en_address,
              country_profile: @country_profile,
              locale: "en-CA",
            ).map_data

            assert_equal "Mihama", mapped[:street]
          end

          test "#map_data does not create a street with city component as `その他` for JA locale" do
            @ja_address.city = ["その他"]

            mapped = AddressValidation::Es::DataMapper.new(
              post_address: @ja_address,
              country_profile: @country_profile,
              locale: "ja-JP",
            ).map_data

            assert_equal "美浜町", mapped[:street]
          end
        end
      end
    end
  end
end
