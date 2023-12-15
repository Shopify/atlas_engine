# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParsingsTest < ActiveSupport::TestCase
      include AddressValidation::AddressValidationTestHelper
      include LogAssertionHelper

      test "describes_po_box? is true when address1 contains a po box" do
        partial_address = build_address(
          address1: "PO BOX 123",
          country_code: "CA",
        )

        assert AddressParsings.new(address_input: partial_address).describes_po_box?
      end

      test "describes_po_box? is true when address2 contains a po box" do
        partial_address = build_address(
          address2: "PO BOX 123",
          country_code: "CA",
        )

        assert AddressParsings.new(address_input: partial_address).describes_po_box?
      end

      test "describes_po_box? is false when neither address line contains a po box" do
        partial_address = build_address(
          address1: "123 Main St",
          address2: "Apt 1",
          country_code: "CA",
        )

        assert_not AddressParsings.new(address_input: partial_address).describes_po_box?
      end

      test "#potential_streets extracts all potential streets from the address lines" do
        partial_address = build_address(
          address1: "123 Main St",
          address2: "Apt 1",
          country_code: "CA",
        )

        assert_equal ["Main St"], AddressParsings.new(address_input: partial_address).potential_streets
      end

      test "#potential_building_numbers extracts all potential building numbers from the address lines" do
        partial_address = build_address(
          address1: "123 Main St",
          address2: "Apt 1",
          country_code: "CA",
        )

        assert_equal ["123"], AddressParsings.new(address_input: partial_address).potential_building_numbers
      end

      test "unparsable addresses are logged" do
        address_hash = {
          address1: "Elgin St",
          address2: "",
          city: "Ottawa",
          province_code: "ON",
          zip: "K2P 1L4",
          country_code: "US",
        }
        address = build_address(**address_hash)

        assert_log_append(
          :info,
          "AtlasEngine::ValidationTranscriber::AddressParsings",
          "[AddressValidation] Unable to parse address lines",
          address_hash,
        )

        AddressParsings.new(address_input: address).potential_streets
      end
    end
  end
end
