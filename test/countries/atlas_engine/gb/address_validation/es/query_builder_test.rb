# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Gb
    module AddressValidation
      module Es
        class QueryBuilderTest < ActiveSupport::TestCase
          include AtlasEngine::AddressValidation::AddressValidationTestHelper

          test ".full_address_query returns a query including the double-dependent locality" do
            address = build_address(
              address1: "27 Queens Close",
              address2: "Boothstown, Worlsey",
              city: "Manchester",
              zip: "M28 1BQ",
              country_code: "GB",
            )
            query_builder = AtlasEngine::AddressValidation::Es::QueryBuilder.for(address)

            assert_equal expected_query_for_postcode(address.zip), query_builder.full_address_query
          end

          test ".full_address_query returns a query including a dependent thoroughfare" do
            address = build_address(
              address1: "4 Brompton Place",
              address2: "Wisbech Road",
              city: "King's Lynn",
              zip: "PE30 5JR",
              country_code: "GB",
            )
            query_builder = AtlasEngine::AddressValidation::Es::QueryBuilder.for(address)

            assert_equal expected_query_for_postcode(address.zip), query_builder.full_address_query
          end

          private

          def expected_query_for_postcode(postcode)
            expected_address_query(postcode.downcase.tr(" ", "_"))
          end
        end
      end
    end
  end
end
