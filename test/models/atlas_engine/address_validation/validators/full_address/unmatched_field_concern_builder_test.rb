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
            @klass = AddressValidation::Validators::FullAddress::UnmatchedFieldConcernBuilder
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
            concern = @klass.new(:city, [:zip, :province_code], @address).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "City may be incorrect.",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "zip concern for matched city and province" do
            concern = @klass.new(:zip, [:city, :province_code], @address).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:zip],
              message: "Postal code may be incorrect.",
              code: :zip_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "province concern for matched city and zip" do
            concern = @klass.new(:province_code, [:city, :zip], @address).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:province],
              message: "Province may be incorrect.",
              code: :province_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "city concern for matched zip and unmatched province" do
            concern = @klass.new(:city, [:zip], @address).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "City may be incorrect.",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "city concern for matched province and unmatched zip" do
            concern = @klass.new(:city, [:province_code], @address).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:city],
              message: "City may be incorrect.",
              code: :city_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "address1 street concern for matched zip and province" do
            concern = @klass.new(:street, [:zip, :province_code], @address, :address1).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:address1],
              message: "Address line 1 may be incorrect.",
              code: :street_inconsistent,
              type: "warning",
              type_level: 3,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "address2 street concern for matched zip and province" do
            concern = @klass.new(:street, [:zip, :province_code], @address, :address2).build(@suggestion_ids)

            expected_attributes = {
              field_names: [:address2],
              message: "Address line 2 may be incorrect.",
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
