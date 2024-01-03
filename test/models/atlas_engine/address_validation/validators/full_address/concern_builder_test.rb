# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ConcernBuilderTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::ConcernBuilder
            @unmatched_field_klass = AddressValidation::Validators::FullAddress::UnmatchedFieldConcern
            @invalid_zip_for_province_klass = AddressValidation::Validators::FullAddress::InvalidZipForProvinceConcern
            @invalid_zip_for_country_klass = AddressValidation::Validators::FullAddress::InvalidZipForCountryConcern
            @unknown_zip_for_address_klass =
              AddressValidation::Validators::FullAddress::UnknownZipForAddressConcern
            @unknown_province_klass =
              AddressValidation::Validators::FullAddress::UnknownProvinceConcern
            @address = build_address
            @suggestion_ids = []
          end

          test ".too_many_unmatched_components? is false when the # of unmatched components is below the threshold" do
            assert_not @klass.too_many_unmatched_components?([:city])
          end

          test ".too_many_unmatched_components? is false when the # of unmatched components is at the threshold" do
            assert_not @klass.too_many_unmatched_components?([:city, :province_code])
          end

          test ".too_many_unmatched_components? is true when the # of unmatched components is above the threshold" do
            assert @klass.too_many_unmatched_components?([:city, :province_code, :zip])
          end

          test ".valid_zip_for_province? true when zip prefix is valid for province" do
            address = build_address(zip: "K1A 0A6", province_code: "ON", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? false when zip prefix is invalid for province" do
            address = build_address(zip: "V1A 0A6", province_code: "ON", country_code: "CA")
            assert_not @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true when country has no postal codes" do
            address = build_address(country_code: "MO")
            assert @klass.valid_zip_for_province?(address) # Macau
          end

          test ".valid_zip_for_province? true if province is empty" do
            address = build_address(zip: "K1A 0A6", province_code: "", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true if province is non existent" do
            address = build_address(zip: "K1A 0A6", province_code: "xx", country_code: "CA")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".valid_zip_for_province? true if province is invalid and country hides provinces" do
            address = build_address(zip: "PH8 0DB", province_code: "ENG", country_code: "GB")
            assert @klass.valid_zip_for_province?(address)
          end

          test ".build returns an UnmatchedFieldConcern by default" do
            builder = @klass.new(
              unmatched_component: :field1,
              matched_components: [:field2, :field3],
              address: @address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unmatched_field_klass, builder.build
          end

          test ".build returns an UnmatchedFieldConcern when unmatched field is not zip" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90412", city: "blah")
            builder = @klass.new(
              unmatched_component: :city,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unmatched_field_klass, builder.build
          end

          test ".build returns an UnmatchedFieldConcern when both zip and province_code are unmatched" do
            address = build_address(country_code: "US", province_code: "ON", zip: "90411", city: "blah")

            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:city],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unmatched_field_klass, builder.build
          end

          test ".build returns an UnmatchedFieldConcern when unmatched zip prefix is valid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90412")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unmatched_field_klass, builder.build
          end

          test ".build returns an InvalidZipForProvinceConcern when unmatched zip prefix is invalid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "80210")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @invalid_zip_for_province_klass, builder.build
          end

          test ".build returns an InvalidZipForCountryConcern when unmatched zip prefix is invalid for country" do
            address = build_address(country_code: "DK", zip: "66000", province_code: nil, city: "Vejen")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @invalid_zip_for_country_klass, builder.build
          end

          test ".build returns an UnknownProvinceConcern when province_code is unmatched and /
              city/zip are matched" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            builder = @klass.new(
              unmatched_component: :province_code,
              matched_components: [:city, :zip],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unknown_province_klass, builder.build
          end

          test ".build returns an UnknownForAddressZipConcernBuilder when only zip is unmatched" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            builder = @klass.new(
              unmatched_component: :zip,
              matched_components: [:city, :province_code],
              address: address,
              suggestion_ids: @suggestion_ids,
            )

            assert_instance_of @unknown_zip_for_address_klass, builder.build
          end

          test ".should_suggest? returns false when unmatched components size is greater than threshold" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :zip, :city]

            assert unmatched_component_keys.size > @klass::UNMATCHED_COMPONENTS_SUGGESTION_THRESHOLD
            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when only one component is unmatched" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns false when province and city are unmatched and zip is invalid for province" do
            address = build_address(country_code: "US", province_code: "TX", zip: "90210")
            unmatched_component_keys = [:province_code, :zip]

            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns false when province and zip are unmatched and zip is invalid for province" do
            address = build_address(country_code: "US", province_code: "TX", zip: "90210")
            unmatched_component_keys = [:province_code, :city]

            assert_not @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when province and city are unmatched and zip is valid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :city]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end

          test ".should_suggest? returns true when province and zip are unmatched and zip is valid for province" do
            address = build_address(country_code: "US", province_code: "CA", zip: "90210")
            unmatched_component_keys = [:province_code, :zip]

            assert @klass.should_suggest?(address, unmatched_component_keys)
          end
        end
      end
    end
  end
end
