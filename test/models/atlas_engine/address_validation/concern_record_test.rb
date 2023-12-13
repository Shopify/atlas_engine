# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class ConcernRecordTest < ActiveSupport::TestCase
      def setup
        @valid_fields = [
          Field.new(name: "address1", value: "777 Pacific Blvd"),
          Field.new(name: "address2", value: nil),
          Field.new(name: "city", value: "Vancouver"),
          Field.new(name: "country_code", value: "CA"),
          Field.new(name: "province_code", value: "BC"),
          Field.new(name: "zip", value: "V6B 4Y8"),
          Field.new(name: "phone", value: "416-555-5555"),
        ]
      end

      test "address_attributes returns hash of address attributes" do
        result = Result.new(fields: @valid_fields)
        concern_record = ConcernRecord.from_result(result)

        expected_address_hash = {
          address1: "777 Pacific Blvd",
          address2: "",
          city: "Vancouver",
          province_code: "BC",
          zip: "V6B 4Y8",
          country_code: "CA",
          phone: "416-555-5555",
        }

        assert_equal expected_address_hash, concern_record.address_attributes
      end
    end
  end
end
