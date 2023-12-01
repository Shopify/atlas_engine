# typed: true
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Types
    module AddressValidation
      class AddressInputTest < ActiveSupport::TestCase
        test "#marshal_dump returns kwargs" do
          test_address = {
            address1: "1157 Third Road",
            address2: "",
            city: "Tifton",
            province_code: "NH",
            country_code: "US",
            zip: "03301",
            phone: "",
          }
          address_input = AddressInput.from_hash(test_address)

          assert_equal test_address, address_input.marshal_dump
        end

        test "#marshal_load returns filled out object" do
          test_address = {
            address1: "1157 Third Road",
          }

          address_input = AddressInput.from_hash({})
          address_input.marshal_load(test_address)
          assert_equal test_address[:address1], address_input.address1
        end
      end
    end
  end
end
