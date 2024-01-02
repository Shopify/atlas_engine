# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Bm
    module AddressImporter
      module Corrections
        module OpenAddress
          class CityAliasCorrectorTest < ActiveSupport::TestCase
            setup do
              @klass = CityAliasCorrector

              @input_address = {
                source_id: "OA#504867",
                locale: "en",
                country_code: "BM",
                province_code: nil,
                region1: nil,
                city: nil,
                suburb: nil,
                zip: "FL 04",
                street: "North Shore Road",
                longitude: -64.7418,
                latitude: 32.3269,
              }
            end

            test "apply adds city alises to applicable cities" do
              bm_cities = [
                {
                  input: ["City of Hamilton"],
                  expected: ["City of Hamilton"], # no aliases
                },
                {
                  input: ["Hamilton"],
                  expected: ["Hamilton", "Hamilton Parish"],
                },
                {
                  input: ["Town of St. George"],
                  expected: ["Town of St. George", "St. George"],
                },
                {
                  input: ["St. George's"],
                  expected: ["St. George's", "St. George's Parish"],
                },
                {
                  input: ["Devonshire"],
                  expected: ["Devonshire", "Devonshire Parish"],
                },
                {
                  input: ["Paget"],
                  expected: ["Paget", "Paget Parish"],
                },
                {
                  input: ["Pembroke"],
                  expected: ["Pembroke", "Pembroke Parish"],
                },
                {
                  input: ["Sandys"],
                  expected: ["Sandys", "Sandys Parish"],
                },
                {
                  input: ["Smiths"],
                  expected: ["Smiths", "Smiths Parish"],
                },
                {
                  input: ["Southampton"],
                  expected: ["Southampton", "Southampton Parish"],
                },
                {
                  input: ["Warwick"],
                  expected: ["Warwick", "Warwick Parish"],
                },
              ]

              bm_cities.each do |bm_city|
                @input_address[:city] = bm_city[:input]
                @klass.apply(@input_address)
                assert_equal bm_city[:expected], @input_address[:city]
              end
            end
          end
        end
      end
    end
  end
end
