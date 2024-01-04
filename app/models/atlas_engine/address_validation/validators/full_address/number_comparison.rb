# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class NumberComparison
          include Comparable

          attr_reader :numbers, :candidate_ranges

          def initialize(numbers: [], candidate_ranges: [])
            @numbers = numbers
            @candidate_ranges = candidate_ranges
          end

          def match?
            return true if candidate_ranges.blank? && numbers.present?

            numbers.compact.any? do |number|
              candidate_ranges.any? do |candidate_range|
                candidate_range.include?(number)
              end
            end
          end
        end
      end
    end
  end
end
