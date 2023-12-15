# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Gb
    module ValidationTranscriber
      class ParsedAddressTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "equality" do
          data = [
            ParsedAddress.new(
              street: "Buckingham Palace",
              post_town: "LONDON",
              zip: "SW1A 1AA",
              country_code: "GB",
            ),
            ParsedAddress.new(
              street: "Balmoral Castle",
              dependent_locality: "Balmoral",
              post_town: "BALLATER",
              zip: "AB35 5TB",
              country_code: "GB",
            ),
            ParsedAddress.new(
              street: "Sandringham Estate",
              post_town: "SANDRINGHAM",
              province_code: "ENG",
              zip: "PE35 6EN",
              country_code: "GB",
            ),
            ParsedAddress.new(
              building_num: "2",
              dependent_street: "Elm Avenue",
              street: "Runcorn Road",
              post_town: "BIRMINGHAM",
              country_code: "GB",
            ),
            ParsedAddress.new(
              building_num: "20",
              double_dependent_locality: "Drumbrughas",
              dependent_locality: "Maguiresbridge",
              post_town: "ENNISKILLEN",
              zip: "BT94 4RX",
              country_code: "GB",
            ),
          ]

          data.each_with_index do |first, first_index|
            first_address = first.dup
            data.each_with_index do |second, second_index|
              second_address = second.dup

              if first_index == second_index
                assert_equal first_address, second_address
              else
                assert_not_equal first_address, second_address
              end
            end
          end
        end

        test "equality infers province_code when it's nil" do
          without_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            zip: "EH8 8DX",
            country_code: "GB",
          )

          with_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            province_code: "SCT",
            zip: "EH8 8DX",
            country_code: "GB",
          )

          assert_equal without_province, with_province
        end

        test "equality infers province_code when it's empty" do
          without_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            province_code: "",
            zip: "EH8 8DX",
            country_code: "GB",
          )

          with_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            province_code: "SCT",
            zip: "EH8 8DX",
            country_code: "GB",
          )

          assert_equal without_province, with_province
        end

        test "equality considers nil and empty province_code to be equal" do
          nil_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            province_code: nil,
            zip: "EH8 8DX",
            country_code: "GB",
          )

          empty_province = ParsedAddress.new(
            street: "Palace of Holyrood",
            post_town: "EDINBURGH",
            province_code: "",
            zip: "EH8 8DX",
            country_code: "GB",
          )

          assert_equal nil_province, empty_province
        end
      end
    end
  end
end
