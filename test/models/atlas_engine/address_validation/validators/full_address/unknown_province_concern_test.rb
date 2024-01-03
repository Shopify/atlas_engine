# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownProvinceConcernTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::UnknownProvinceConcern
            @suggestion_ids = []
          end

          test "#attributes concern - US" do
            concern = @klass.new(build_address(country_code: "us", city: "Some Town", zip: "11111"), @suggestion_ids)

            expected_attributes = {
              field_names: [:province],
              message: "Enter a valid state for Some Town, 11111",
              code: :province_inconsistent,
              type: "error",
              type_level: 1,
              suggestion_ids: @suggestion_ids,
            }
            assert_equal expected_attributes, concern.attributes
          end

          test "#attributes concern - Canada (fr)" do
            concern = @klass.new(
              build_address(country_code: "ca", city: "Saint-Néant", zip: "J9A 1A1"),
              @suggestion_ids,
            )

            expected_attributes = {
              field_names: [:province],
              message: "Saisir une province valide pour Saint-Néant, J9A 1A1",
              code: :province_inconsistent,
              type: "error",
              type_level: 1,
              suggestion_ids: @suggestion_ids,
            }

            I18n.with_locale("fr") do
              assert_equal expected_attributes, concern.attributes
            end
          end
        end
      end
    end
  end
end
