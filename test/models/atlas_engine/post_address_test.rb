# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class PostAddressTest < ActiveSupport::TestCase
    test "when address has valid country, province, city, and zip" do
      assert PostAddress.new(country_code: "CA", province_code: "BC", city: ["Vancouver"], zip: "V6B 4Y8").valid?
    end

    test "when country is missing" do
      expected_errors = ["is required"]
      address = PostAddress.new(province_code: "BC", city: ["Vancouver"], zip: "V6B 4Y8")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:country]
    end

    test "when country is not recognized" do
      expected_errors = ["with code 'XX' is not recognized"]
      address = PostAddress.new(country_code: "XX", province_code: "BC", city: ["Vancouver"], zip: "V6B 4Y8")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:country]
    end

    test "when country has no provinces" do
      assert PostAddress.new(country_code: "GB", city: ["London"], zip: "SE22 8DL").valid?
    end

    test "when is province is optional and not present" do
      assert PostAddress.new(country_code: "NZ", city: ["Ōtaki"], zip: "5512").valid?
    end

    test "when province is optional and present" do
      assert PostAddress.new(country_code: "NZ", city: ["Ōtaki"], province_code: "WGN", zip: "5512").valid?
    end

    test "when province is not optional and not present" do
      expected_errors = ["is required for country 'CA'"]
      address = PostAddress.new(country_code: "CA", province_code: nil, city: ["Vancouver"], zip: "V6B4Y8")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:province_code]
    end

    test "when province is not recognized" do
      expected_errors = ["'XX' is invalid for country 'CA'"]
      address = PostAddress.new(country_code: "CA", province_code: "XX", city: ["Vancouver"], zip: "V6B4Y8")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:province_code]
    end

    test "when city is missing" do
      address = PostAddress.new(country_code: "CA", province_code: "BC", zip: "V6B 4Y8")

      assert_not address.valid?
    end

    test "when zip and province are optional and not present" do
      assert PostAddress.new(country_code: "CG", city: ["Brazzaville"]).valid?
    end

    test "when zip is optional and not present" do
      assert PostAddress.new(country_code: "VE", province_code: "VE-C", city: ["TODO"]).valid?
    end

    test "when zip is optional and present" do
      assert PostAddress.new(country_code: "VE", province_code: "VE-C", city: ["TODO"], zip: "1012").valid?
    end

    test "when zip is not optional and not present" do
      expected_errors = ["is required for country 'CA'"]
      address = PostAddress.new(country_code: "CA", province_code: "BC", city: ["Vancouver"], zip: nil)

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:zip]
    end

    test "when zip is not valid for country" do
      expected_errors = ["'XXXYYY' is invalid for country 'CA'"]
      address = PostAddress.new(country_code: "CA", province_code: "BC", city: ["Vancouver"], zip: "XXXYYY")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:zip]
    end

    test "when zip not valid for province" do
      expected_errors = ["'K2E6M8' is invalid for province 'BC'"]
      address = PostAddress.new(country_code: "CA", province_code: "BC", city: ["Vancouver"], zip: "K2E6M8")

      assert_not address.valid?
      assert_equal expected_errors, address.errors[:zip]
    end

    test "#to_h returns a hash of the address" do
      expected_hash = {
        source_id: "123",
        country_code: "CA",
        province_code: "BC",
        city: ["Vancouver"],
        zip: "V6B 4Y8",
      }

      address = PostAddress.new(
        source_id: "123",
        country_code: "CA",
        province_code: "BC",
        city: ["Vancouver"],
        zip: "V6B 4Y8",
      )

      assert_equal expected_hash, address.to_h
    end
  end
end
