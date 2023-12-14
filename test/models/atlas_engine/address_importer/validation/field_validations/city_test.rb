# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/address_importer_test_helper"

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class CityTest < ActiveSupport::TestCase
          include AddressImporterTestHelper

          test "when is valid" do
            errors = City.new(address: build_post_address_struct(city: ["Ottawa"])).validation_errors
            assert_empty errors
          end

          test "when not present" do
            errors = City.new(address: build_post_address_struct(city: nil)).validation_errors
            expected_errors = ["City is required"]

            assert_equal expected_errors, errors
          end
        end
      end
    end
  end
end
