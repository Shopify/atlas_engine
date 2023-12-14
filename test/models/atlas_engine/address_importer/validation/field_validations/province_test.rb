# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/address_importer_test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class ProvinceTest < ActiveSupport::TestCase
          include AddressImporterTestHelper

          test "when is valid" do
            errors = Province.new(
              address: build_post_address_struct(
                country_code: "CA",
                province_code: "ON",
              ),
            ).validation_errors
            assert_empty errors
          end

          test "when is country_code is invalid" do
            errors = Province.new(
              address: build_post_address_struct(
                country_code: "XX",
                province_code: "ON",
              ),
            ).validation_errors

            expected_errors = ["Country 'XX' is invalid"]

            assert_equal expected_errors, errors
          end

          test "when country has no provinces" do
            errors = Province.new(
              address: build_post_address_struct(
                country_code: "GB",
                province_code: nil,
              ),
            ).validation_errors
            assert_empty errors
          end

          test "when is optional and not present" do
            errors = Province.new(
              address: build_post_address_struct(
                country_code: "NZ",
                province_code: nil,
              ),
            ).validation_errors
            assert_empty errors
          end

          test "when optional and present" do
            errors = Province.new(
              address: build_post_address_struct(
                country_code: "NZ",
                province_code: "WGN",
              ),
            ).validation_errors
            assert_empty errors
          end

          test "when required and not present" do
            country_code = "CA"

            errors = Province.new(
              address: build_post_address_struct(
                country_code: country_code,
                province_code: nil,
              ),
            ).validation_errors
            expected_errors = ["Province is required for country '#{country_code}'"]

            assert_equal expected_errors, errors
          end

          test "when not recognized" do
            country_code = "CA"
            province_code = "XX"

            errors = Province.new(
              address: build_post_address_struct(
                country_code: country_code,
                province_code: province_code,
              ),
            ).validation_errors
            expected_errors = ["Province '#{province_code}' is invalid for country '#{country_code}'"]

            assert_equal expected_errors, errors
          end
        end
      end
    end
  end
end
