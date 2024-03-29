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
                  expected: ["City of Hamilton", "Hamilton"],
                },
                {
                  input: ["Hamilton"],
                  expected: ["Hamilton Parish", "Hamilton"],
                },
                {
                  input: ["Town of St. George"],
                  expected: ["Town of St. George", "St. George"],
                },
                {
                  input: ["St. George's"],
                  expected: ["St. George's Parish", "St. George's"],
                },
                {
                  input: ["Devonshire"],
                  expected: ["Devonshire Parish", "Devonshire"],
                },
                {
                  input: ["Paget"],
                  expected: ["Paget Parish", "Paget"],
                },
                {
                  input: ["Pembroke"],
                  expected: ["Pembroke Parish", "Pembroke"],
                },
                {
                  input: ["Sandys"],
                  expected: ["Sandys Parish", "Sandys"],
                },
                {
                  input: ["Smiths"],
                  expected: ["Smiths Parish", "Smiths"],
                },
                {
                  input: ["Southampton"],
                  expected: ["Southampton Parish", "Southampton"],
                },
                {
                  input: ["Warwick"],
                  expected: ["Warwick Parish", "Warwick"],
                },
                {
                  input: ["A new Parish"],
                  expected: ["A new Parish"], # no aliases
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
