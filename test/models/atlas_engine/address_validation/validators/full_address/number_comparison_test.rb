# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class NumberComparisonTest < ActiveSupport::TestCase
          test "#match? returns true when any building number provided is within a candidate range" do
            building_match = NumberComparison.new(
              numbers: ["100-A", "100"],
              candidate_ranges: [address_range(1, 10), address_range(50, 150)],
            )
            assert building_match.match?
          end

          test "#match? returns false when no building number provided is within a candidate range" do
            building_mismatch = NumberComparison.new(
              numbers: ["100", "200"],
              candidate_ranges: [address_range(3000, 4000), address_range(51, 151, 2)],
            )
            assert_not building_mismatch.match?
          end

          test "#match? returns true when building numbers are provided but there are no candidate ranges" do
            empty_candidate_building = NumberComparison.new(
              numbers: ["100", "200"],
              candidate_ranges: nil,
            )
            assert empty_candidate_building.match?
          end

          test "#match? returns false when there are no building numbers provided" do
            both_buildings_empty = NumberComparison.new(
              numbers: [],
              candidate_ranges: nil,
            )

            empty_input_building = NumberComparison.new(
              numbers: [],
              candidate_ranges: [address_range(100, 200)],
            )
            assert_not both_buildings_empty.match?
            assert_not empty_input_building.match?
          end

          def address_range(min, max, step = 1)
            AddressNumberRange.new(range_string: "(#{min}..#{max})/#{step}")
          end
        end
      end
    end
  end
end
