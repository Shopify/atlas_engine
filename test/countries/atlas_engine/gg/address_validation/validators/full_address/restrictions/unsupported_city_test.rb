# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Gg
    module AddressValidation
      module Validators
        module FullAddress
          module Restrictions
            class UnsupportedCityTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              test "#apply? returns true if the address city is unsupported" do
                UnsupportedCity::UNSUPPORTED_CITIES.each do |city|
                  unsupported_address = create_address(city: city)
                  assert UnsupportedCity.apply?(unsupported_address)
                end
              end

              test "#apply returns false if address city is supported" do
                supported_address = create_address(city: "St. Peter Port")
                assert_not UnsupportedCity.apply?(supported_address)
              end

              private

              def create_address(address1: "1 Mont Arrive", zip: "GY1 2AA", country_code: "GG", city: "St. Peter Port",
                province_code: nil)
                build_address(
                  address1: address1,
                  city: city,
                  province_code: province_code,
                  country_code: country_code,
                  zip: zip,
                )
              end
            end
          end
        end
      end
    end
  end
end
