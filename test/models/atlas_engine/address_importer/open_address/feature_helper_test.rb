# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class FeatureHelperTest < ActiveSupport::TestCase
        class BasicTransformer
          include FeatureHelper
          def initialize(country_code: "DK")
            @country_code = country_code
          end
        end

        setup do
          @klass = BasicTransformer.new
          @feature = {
            "type" => "Feature",
            "properties" =>
           {
             "hash" => "",
             "number" => "13",
             "street" => "Isefjords Alle",
             "unit" => "11 3",
             "city" => "Holbæk",
             "district" => "",
             "region" => "Region Sjælland",
             "postcode" => "4300",
             "id" => "",
           },
            "geometry" => { "type" => "Point", "coordinates" => [11.7165786, 55.7202219] },
          }
        end

        test "#openaddress_source_id returns the modified id when id present" do
          @feature["properties"]["id"] = "123"
          @feature["properties"]["hash"] = "456"
          expected = "OA-123"

          assert_equal expected, @klass.openaddress_source_id(@feature)
        end

        test "#openaddress_source_id returns the modified hash when only hash present" do
          @feature["properties"]["hash"] = "456"
          expected = "OA#456"

          assert_equal expected, @klass.openaddress_source_id(@feature)
        end

        test "#openaddress_source_id returns an MD5 digest when no hash or id present" do
          expected = "AT-7248707286ed7059613b0da9688f393d"
          assert_equal expected, @klass.openaddress_source_id(@feature)
        end

        test "#geometry returns the expected value when geometry present" do
          expected = [11.7165786, 55.7202219]
          assert_equal expected, @klass.geometry(@feature)
        end

        test "#geometry returns nil when empty geometry" do
          @feature["geometry"] = nil

          assert_nil @klass.geometry(@feature)
        end

        test "#housenumber_and_unit returns expected hash when number and unit are present" do
          expected = { "13" => { "11 3" => {} } }
          assert_equal expected,
            @klass.housenumber_and_unit(@feature["properties"]["number"], @feature["properties"]["unit"])
        end

        test "#housenumber_and_unit returns an empty hash when number is blank" do
          @feature["properties"]["number"] = nil
          expected = {}

          assert_equal expected,
            @klass.housenumber_and_unit(@feature["properties"]["number"], @feature["properties"]["unit"])
        end

        test "#housenumber_and_unit returns an hash when number is present and unit is blank" do
          @feature["properties"]["unit"] = nil
          expected = { "13" => {} }

          assert_equal expected,
            @klass.housenumber_and_unit(@feature["properties"]["number"], @feature["properties"]["unit"])
        end

        test "#normalize_zip returns the normalized zip" do
          bermuda_transformer = BasicTransformer.new(country_code: "BM")
          assert_equal "WK 06", bermuda_transformer.normalize_zip("WK06")
        end

        test "#province_code_from_name supports full province name" do
          italy_transformer = BasicTransformer.new(country_code: "IT")
          assert_equal "RM", italy_transformer.province_code_from_name("Rome")
        end

        test "#province_code_from_name supports legacy province name" do
          italy_transformer = BasicTransformer.new(country_code: "IT")
          assert_equal "RM", italy_transformer.province_code_from_name("Roma")
        end

        test "#province_code_from_name supports alternate name" do
          italy_transformer = BasicTransformer.new(country_code: "IT")
          # Calabria is an alteranate name for Reggio Calabria
          assert_equal "RC", italy_transformer.province_code_from_name("Calabria")
        end

        test "#province_code_from_name returns nil when no match" do
          italy_transformer = BasicTransformer.new(country_code: "IT")
          assert_nil italy_transformer.province_code_from_name("Foo")
        end

        test "#province_from_code returns the code when it is in the list" do
          canada_transformer = BasicTransformer.new(country_code: "CA")
          assert_equal "ON", canada_transformer.province_from_code("ON")
        end

        test "#province_from_code returns nil when the code is not in the list" do
          canada_transformer = BasicTransformer.new(country_code: "CA")
          assert_nil canada_transformer.province_from_code("FOO")
        end

        test "#province_code_from_zip maps zip to province_code" do
          transformer = BasicTransformer.new(country_code: "PT")
          assert_equal "PT-13", transformer.province_code_from_zip("4430-037")
        end

        test "#province_code_from_zip returns nil when no match" do
          transformer = BasicTransformer.new(country_code: "PT")
          assert_nil transformer.province_code_from_zip("Foo")
        end
      end
    end
  end
end
