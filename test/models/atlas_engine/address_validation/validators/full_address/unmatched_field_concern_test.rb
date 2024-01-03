# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnmatchedFieldConcernTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::UnmatchedFieldConcern
            @address = build_address(
              city: "Ottawa",
              zip: "K1A 0A6",
              province_code: "ON",
              country_code: "CA",
              address1: "123 Northwood St",
              address2: "8006",
            )
            @suggestion_ids = []
          end
          test "city concern for matched zip and province" do
            concern = @klass.new(:city, [:zip, :province_code], @address, @suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "Enter a valid city for K1A 0A6, Ontario",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "zip concern for matched city and province" do
            concern = @klass.new(:zip, [:city, :province_code], @address, @suggestion_ids)

            expected_attributes = {
              field_names: [:zip],
              message: "Enter a valid ZIP for Ottawa, Ontario",
              code: :zip_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "province concern for matched city and zip" do
            concern = @klass.new(:province_code, [:city, :zip], @address, @suggestion_ids)

            expected_attributes = {
              field_names: [:province],
              message: "Enter a valid state for Ottawa, K1A 0A6",
              code: :province_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "city concern for matched zip and unmatched province" do
            concern = @klass.new(:city, [:zip], @address, @suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "Enter a valid city for K1A 0A6",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "city concern for matched province and unmatched zip" do
            concern = @klass.new(:city, [:province_code], @address, @suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "Enter a valid city for Ontario",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "address1 street concern for matched zip and province" do
            concern = @klass.new(:street, [:zip, :province_code], @address, @suggestion_ids, :address1)

            expected_attributes = {
              field_names: [:address1],
              message: "Enter a valid street name for K1A 0A6, Ontario",
              code: :street_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "address2 street concern for matched zip and province" do
            concern = @klass.new(:street, [:zip, :province_code], @address, @suggestion_ids, :address2)

            expected_attributes = {
              field_names: [:address2],
              message: "Enter a valid street name for K1A 0A6, Ontario",
              code: :street_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end
        end
      end
    end
  end
end
