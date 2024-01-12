# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class RestrictionEvaluatorTest < ActiveSupport::TestCase
          include AddressValidationTestHelper
          include StatsD::Instrument::Assertions

          setup do
            @klass = AddressValidation::Es::Validators::RestrictionEvaluator
          end

          test "it correctly applies restrictions when additional params are required" do
            address = build_address(
              address1: "234 Latin Character Street",
              city: "Seoul",
              country_code: "KR",
            )

            profile_attributes = {
              "id" => "KR",
              "validation" => {
                "restrictions" => [{
                  "class" => "AtlasEngine::Restrictions::UnsupportedScript",
                  "params" => {
                    "supported_script" => :Hangul,
                  },
                }],
              },
            }

            CountryProfile.any_instance.expects(:attributes).returns(profile_attributes)

            assert_not @klass.new(address).supported_address?
          end

          test "it correctly applies restrictions when additional params are not required" do
            address = build_address(
              city: "Sark",
              zip: "GY9 3AA",
              country_code: "GG",
            )

            profile_attributes = {
              "id" => "GG",
              "validation" => {
                "restrictions" => [{
                  "class" =>
                    "AtlasEngine::Gg::AddressValidation::Validators::FullAddress::Restrictions::UnsupportedCity",
                }],
              },
            }

            CountryProfile.any_instance.expects(:attributes).returns(profile_attributes)

            assert_not @klass.new(address).supported_address?
          end

          test "it returns true if no restrictions are defined" do
            address = build_address(
              address1: "234 Latin Character Street",
              city: "Toronto",
              country_code: "CA",
            )

            profile_attributes = {
              "id" => "CA",
              "validation" => {
                "restrictions" => [],
              },
            }

            CountryProfile.any_instance.expects(:attributes).returns(profile_attributes)

            assert @klass.new(address).supported_address?
          end
        end
      end
    end
  end
end
