# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipConcernBuilderTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::InvalidZipConcernBuilder
            @suggestion_ids = []
          end

          test "#for returns nil when the country has no zips" do
            address = build_address(country_code: "MO", zip: "66000")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country supports zones and zip is valid for the province" do
            address = build_address(country_code: "CA", province_code: "ON", zip: "K1A 0A6")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country does not support zones and zip is valid for the country" do
            address = build_address(country_code: "DK", zip: "6600", province_code: nil, city: "Vejen")

            assert_nil @klass.for(address, [])
          end

          test "#for returns nil when country supports zones and hide_provinces_from_addresses and zip is valid for the country" do
            address = build_address(country_code: "GB", zip: "SW1Y 5BL", province_code: nil, city: "London")

            assert_nil @klass.for(address, [])
          end

          test "#for returns InvalidZipForProvinceConcern when country supports zones and zip is invalid for province" do
            address = build_address(country_code: "CA", province_code: "ON", zip: "V6K 1M9  ")

            expected = InvalidZipForProvinceConcern.new(address, @suggestion_ids)

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.address, result.address
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns InvalidZipForCountryConcern when country does not support zones and zip is invalid for country" do
            address = build_address(country_code: "DK", zip: "66000", province_code: nil, city: "Vejen")

            expected = InvalidZipForCountryConcern.new(address, @suggestion_ids)

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.address, result.address
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns InvalidZipForCountryConcern when country.hide_provinces_from_addresses and zip is invalid for country" do
            address = build_address(country_code: "GB", zip: "90210", province_code: nil, city: "London")
            expected = InvalidZipForCountryConcern.new(address, @suggestion_ids)

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.address, result.address
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end

          test "#for returns InvalidZipForCountryConcern concern when address zone is unrecognized and zip is invalid for country" do
            address = build_address(country_code: "CA", province_code: "XX", zip: "Z2Z 0A7")

            expected = InvalidZipForCountryConcern.new(address, @suggestion_ids)

            result = @klass.for(address, @suggestion_ids)

            assert_equal expected.class, result.class
            assert_equal expected.address, result.address
            assert_equal expected.suggestion_ids, result.suggestion_ids
          end
        end
      end
    end
  end
end
