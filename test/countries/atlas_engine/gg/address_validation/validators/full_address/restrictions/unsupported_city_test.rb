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

              test "#apply? returns true if the address city and zip are unsupported" do
                [{ city: "Sark", zip: "GY9 3AA" }, { city: "Alderney", zip: "GY10 3AA" }].each do |city_zip|
                  unsupported_address = create_address(city: city_zip[:city], zip: city_zip[:zip])
                  assert UnsupportedCity.apply?(address: unsupported_address)
                end
              end

              test "#apply returns false if the address city-zip combination is supported" do
                [
                  { city: "Sark", zip: "GY1 2AA" },
                  { city: "Alderney", zip: "GY1 2AA" },
                  { city: "St. Peter Port", zip: "GY9 3AA" },
                  { city: "St. Peter Port", zip: "GY1 2AA" },
                ].each do |city_zip|
                  supported_address = create_address(city: city_zip[:city], zip: city_zip[:zip])
                  assert_not UnsupportedCity.apply?(address: supported_address)
                end
              end

              test "#apply returns false if city or zip is nil" do
                [{ city: "Sark", zip: nil }, { city: nil, zip: "GY9 3AA" }, { city: nil, zip: nil }].each do |city_zip|
                  supported_address = create_address(city: city_zip[:city], zip: city_zip[:zip])
                  assert_not UnsupportedCity.apply?(address: supported_address)
                end
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
