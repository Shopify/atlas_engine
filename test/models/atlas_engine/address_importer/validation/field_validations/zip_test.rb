# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/address_importer_test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class ZipTest < ActiveSupport::TestCase
          include AddressImporterTestHelper

          test "when is valid" do
            errors = Zip.new(address: build_post_address_struct(
              country_code: "CA",
              province_code: "ON",
              zip: "K2E 6M8",
            )).validation_errors
            assert_empty errors
          end

          test "when zip and province are optional and not present" do
            errors = Zip.new(address: build_post_address_struct(
              country_code: "CG",
              province_code: nil,
              zip: nil,
            )).validation_errors
            assert_empty errors
          end

          test "when zip is optional and not present" do
            errors = Zip.new(address: build_post_address_struct(
              country_code: "VE",
              province_code: "VE-C",
              zip: nil,
            )).validation_errors
            assert_empty errors
          end

          test "when zip is optional and present" do
            errors = Zip.new(address: build_post_address_struct(
              country_code: "VE",
              province_code: "VE-C",
              zip: "1012",
            )).validation_errors
            assert_empty errors
          end

          test "when zip is required and not present" do
            country_code = "CA"

            errors = Zip.new(address: build_post_address_struct(
              country_code: country_code,
              province_code: "BC",
              zip: nil,
            )).validation_errors
            expected_errors = ["Zip is required for country '#{country_code}'"]

            assert_equal expected_errors, errors
          end

          test "when zip is not valid for country" do
            country_code = "CA"
            zip = "XXXYYY"

            errors = Zip.new(address: build_post_address_struct(
              country_code: country_code,
              province_code: "BC",
              zip: zip,
            )).validation_errors
            expected_errors = ["Zip '#{zip}' is invalid for country '#{country_code}'"]

            assert_equal expected_errors, errors
          end

          test "when zip is not valid for province" do
            province_code = "BC"
            zip = "K2E6M8"

            errors = Zip.new(address: build_post_address_struct(
              country_code: "CA",
              province_code: province_code,
              zip: zip,
            )).validation_errors
            expected_errors = ["Zip '#{zip}' is invalid for province '#{province_code}'"]

            assert_equal expected_errors, errors
          end

          test "partial zip is permitted when allow_partial_zip: true" do
            address = build_post_address_struct(
              city: "BERWICK-UPON-TWEED",
              zip: "TD15", # the full postcode for this address is TD15 2AQ
              country_code: "GB",
            )

            errors = Zip.new(address: address, allow_partial_zip: true).validation_errors

            assert_empty errors
          end
        end
      end
    end
  end
end
