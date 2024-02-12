# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/address_validation_test_helper"

module AtlasEngine
  module Nz
    module ValidationTranscriber
      class AddressParserTest < ActiveSupport::TestCase
        include AtlasEngine::AddressValidation::AddressValidationTestHelper

        test "One line addresses" do
          [
            # building number incorrectly added before street name, with punctuation
            [:nz, "1028 RIVER ROAD", "QUEENWOOD", [{ street: "RIVER ROAD", building_num: "1028", suburb: "QUEENWOOD" }]],
          ].each do |country_code, address1, address2, expected|
            check_parsing(AddressParser, country_code, address1, address2, expected)
          end
        end
      end
    end
  end
end
