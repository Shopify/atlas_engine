# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Pl
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        test "#parse returns the correct address components for an AU address" do
          address = AddressValidation::Address.new(
            address1: "ul. Rokicińska 117",
            city: "Łódź",
            zip: "92-620",
            country_code: "PL",
          )

          parser = AddressParser.new(address: address)
          assert_equal([{ street: "ul. Rokicińska", building_num: "117" }], parser.parse)
        end
      end
    end
  end
end
