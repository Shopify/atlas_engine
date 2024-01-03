# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class NoCandidateResultTest < ActiveSupport::TestCase
          include AddressValidationTestHelper

          setup do
            @klass = AddressValidation::Validators::FullAddress::NoCandidateResult
          end

          test "always adds an address_unknown concern to the result" do
            @address = address
            result = result()
            @klass.new(session: session, result: result).update_result

            assert_equal 1, result.concerns.size
            assert_equal :address_unknown, result.concerns.first.code
          end

          test "adds invalid zip concern without suggestions when ConcernBuilder.should_suggest? is false and /
            zip/province are mutually invalid" do
            @address = address(province_code: "AB") # K2P 1L4 is not valid for Alberta
            result = result()
            @klass.new(session: session, result: result).update_result

            assert_equal 2, result.concerns.size
            assert_equal [:country_code, :province_code], result.validation_scope
            assert_equal :address_unknown, result.concerns.first.code
            assert_equal :zip_invalid_for_province, result.concerns.second.code
          end

          def address(overrides = {})
            default_address = {
              phone: "613-555-1867",
              address1: "150 Elgin Street",
              address2: "Suite Home Alabamuh!",
              city: "Ottawa",
              zip: "K2P 1L4",
              province_code: "ON",
              country_code: "CA",
            }
            build_address(**default_address.merge(overrides))
          end

          def session
            @session ||= AddressValidation::Session.new(address: @address).tap do |session|
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

          def result(overrides = {})
            default_result = {
              validation_scope: AddressValidation::Result::SORTED_VALIDATION_SCOPES.dup,
            }

            AddressValidation::Result.new(**default_result.merge(overrides))
          end
        end
      end
    end
  end
end
