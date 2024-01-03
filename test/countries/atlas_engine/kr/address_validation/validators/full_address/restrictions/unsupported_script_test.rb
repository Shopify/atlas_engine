# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Kr
    module AddressValidation
      module Validators
        module FullAddress
          module Restrictions
            class UnsupportedScriptTest < ActiveSupport::TestCase
              include AtlasEngine::AddressValidation::AddressValidationTestHelper

              test "#apply? returns true if the address contains a non-Hangul script" do
                addresses = [
                  build_address(address1: "74, Toegye-ro 90-gil", city: "Seoul"),
                  build_address(address1: "74, Toegye-ro 90-gil", city: "서울"),
                ]

                addresses.each do |address|
                  assert UnsupportedScript.apply?(address)
                end
              end

              test "#apply? returns false if the address contains only Hangul script" do
                addresses = [
                  build_address(address1: "1층"),
                  build_address(address1: "1층", city: "영도구"),
                ]

                addresses.each do |address|
                  assert_not UnsupportedScript.apply?(address)
                end
              end
            end
          end
        end
      end
    end
  end
end
