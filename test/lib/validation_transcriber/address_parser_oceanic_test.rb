# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class AddressParserOceanicTest < ActiveSupport::TestCase
      test "#parse returns the correct address components for an AU address" do
        address = AddressValidation::Address.new(
          address1: "984 River Road",
          city: "Ferney",
          zip: "4650",
          province_code: "qld",
          country_code: "AU",
        )

        parser = AddressParserOceanic.new(address: address)
        assert_equal([{ building_num: "984", street: "River Road" }], parser.parse)
      end
    end
  end
end
