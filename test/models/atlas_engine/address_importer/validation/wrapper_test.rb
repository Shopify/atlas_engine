# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      class WrapperTest < ActiveSupport::TestCase
        class MockValidator < AddressImporter::Validation::BaseValidator; end

        setup do
          @country_import = FactoryBot.create(:country_import, :pending)
          @validator = MockValidator.new(
            country_code: @country_import.country_code,
            field_validations: { field: ["nada"] },
          )
          @klass = Validation::Wrapper.new(country_import: @country_import, validator: @validator)
        end

        test "#valid? returns false when address is nil" do
          assert_not @klass.valid?(nil)
        end

        test "#valid? returns true when no validation errors are returned" do
          address = {
            locale: "EN",
            country_code: "JP",
            province_code: "JP-23",
            region1: "Chubu",
            region2: "Aichi",
            region3: "Aichi",
            region4: "Togo",
            city: ["Haruki"],
            suburb: nil,
            zip: "470-0162",
            street: nil,
            building_name: nil,
            latitude: 35.107024,
            longitude: 137.023180,
            building_and_unit_ranges: {},
          }
          sliced_address = Validation::Wrapper::AddressStruct.new(**address.slice(
            :country_code,
            :province_code,
            :zip,
            :city,
          ))
          @validator.expects(:validation_errors).with(address: sliced_address).returns({ field1_validator: [] })

          assert @klass.valid?(address)
        end

        test "#valid? returns false when validation errors are returned" do
          @klass.stubs(:import_log_info)
          address = {
            locale: "EN",
            country_code: "JP",
            province_code: "BLAH",
            region1: "Chubu",
            region2: "Aichi",
            region3: "Aichi",
            region4: "Togo",
            city: ["Haruki"],
            suburb: nil,
            zip: "470-0162",
            street: nil,
            building_name: nil,
            latitude: 35.107024,
            longitude: 137.023180,
            building_and_unit_ranges: {},
          }
          sliced_address = Validation::Wrapper::AddressStruct.new(**address.slice(
            :country_code,
            :province_code,
            :zip,
            :city,
          ))
          @validator.expects(:validation_errors).with(address: sliced_address)
            .returns({ field1_validator: ["invalid field"] })

          assert_not @klass.valid?(address)
        end

        test "#valid? logs any invalid addresses when log_invalid_records is true" do
          address = {
            locale: "EN",
            country_code: "JP",
            province_code: "BLAH",
            region1: "Chubu",
            region2: "Aichi",
            region3: "Aichi",
            region4: "Togo",
            city: ["Haruki"],
            suburb: nil,
            zip: "470-0162",
            street: nil,
            building_name: nil,
            latitude: 35.107024,
            longitude: 137.023180,
            building_and_unit_ranges: {},
          }
          sliced_address = Validation::Wrapper::AddressStruct.new(**address.slice(
            :country_code,
            :province_code,
            :zip,
            :city,
          ))
          @validator.expects(:validation_errors).with(address: sliced_address)
            .returns({ field1_validator: ["field foo is invalid for bar"] })

          @klass.expects(:import_log_info).once.with(
            country_import: @country_import,
            message: "Invalid address; field foo is invalid for bar",
            category: :invalid_address,
            additional_params: { address: address },
          )
          @klass.valid?(address)
        end

        test "#valid? doesn't log invalid addresses when log_invalid_records is false" do
          address = {
            locale: "EN",
            country_code: "JP",
            province_code: "BLAH",
            region1: "Chubu",
            region2: "Aichi",
            region3: "Aichi",
            region4: "Togo",
            city: ["Haruki"],
            suburb: nil,
            zip: "470-0162",
            street: nil,
            building_name: nil,
            latitude: 35.107024,
            longitude: 137.023180,
            building_and_unit_ranges: {},
          }
          sliced_address = Validation::Wrapper::AddressStruct.new(**address.slice(
            :country_code,
            :province_code,
            :zip,
            :city,
          ))
          @validator.expects(:validation_errors).with(address: sliced_address)
            .returns({ field1_validator: ["field foo is invalid for bar"] })

          klass = Validation::Wrapper.new(
            country_import: @country_import,
            validator: @validator,
            log_invalid_records: false,
          )
          klass.expects(:import_log_info).never

          klass.valid?(address)
        end
      end
    end
  end
end
