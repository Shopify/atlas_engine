# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnsupportedScriptResultTest < ActiveSupport::TestCase
          include TokenHelper
          include AddressValidationTestHelper

          setup do
            @default_address = {
              phone: "613-555-1867",
              address1: "150 Elgin Street",
              address2: "Suite Home Alabamuh!",
              city: "Ottawa",
              zip: "K2P 1L4",
              province_code: "ON",
              country_code: "CA",
            }
            @address = build_address(**@default_address)
            @klass = AddressValidation::Validators::FullAddress::UnsupportedScriptResult
          end

          test "#update_result adds invalid zip concern when zip is invalid for province" do
            # K2P 1L4 is not valid for Alberta
            @address = build_address(**@default_address.merge({ province_code: "AB" }))
            result = build_result

            @klass.new(session: session, result: result).update_result

            assert_equal 1, result.concerns.size
            assert_equal [:country_code, :province_code], result.validation_scope
            assert_equal :zip_invalid_for_province, result.concerns.first.code
          end

          test "#update_result adds no concerns when zip is valid for province" do
            result = build_result

            @klass.new(session: session, result: result).update_result

            assert_equal 0, result.concerns.size
            assert_equal [:country_code, :province_code, :zip, :city, :address1, :address2, :phone],
              result.validation_scope
          end

          def session
            @session ||= Session.new(address: @address).tap do |session|
              # setting the street and city sequences leads the Datastore to skip the actual ES _analyze requests.
              sequences_for(session)
            end
          end

          def sequences_for(session)
            session.datastore.street_sequences = [
              AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.address1),
            ]
            session.datastore.city_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(@address.city)
          end

          def build_result(overrides = {})
            default_result = {
              validation_scope: Result::SORTED_VALIDATION_SCOPES.dup,
            }

            Result.new(**default_result.merge(overrides))
          end
        end
      end
    end
  end
end
