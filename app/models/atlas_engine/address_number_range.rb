# typed: true
# frozen_string_literal: true

module AtlasEngine
  class AddressNumberRange
    extend T::Sig

    RANGE_FORMAT = %r{^\((?<min>[^\)]+)\.\.(?<max>[^\)]+)\)/(?<step>[12])$} # ex. (A1..A9)/2

    class RangeError < ArgumentError; end

    class << self
      extend T::Sig

      sig { params(overlapping_ranges: T::Array[T::Range[Integer]]).returns(T::Array[T::Range[Integer]]) }
      def merge_overlapping_ranges(overlapping_ranges)
        overlapping_ranges.sort_by(&:min).inject([]) do |ranges, range|
          if !ranges.empty? && (ranges.last.overlaps?(range) || consecutive_ranges?(ranges.last, range))
            ranges[0...-1] + [merge_ranges(ranges.last, range)]
          else
            ranges + [range]
          end
        end
      end

      private

      sig { params(a: T::Range[Integer], b: T::Range[Integer]).returns(T::Range[Integer]) }
      def merge_ranges(a, b)
        [a.min, b.min].min..[a.max, b.max].max
      end

      sig { params(a: T::Range[Integer], b: T::Range[Integer]).returns(T::Boolean) }
      def consecutive_ranges?(a, b)
        b.min - a.max == 1
      end
    end

    sig { params(range_string: String).void }
    def initialize(range_string:)
      range = RANGE_FORMAT.match(range_string)
      if range
        @min = AddressNumber.new(value: T.must(range[:min]))
        @max = AddressNumber.new(value: T.must(range[:max]))

        if @min.segments.length != @max.segments.length
          raise RangeError, "min and max of range are not compatible, range_string: #{range_string}"
        end

        @step = range[:step].to_i
      else
        @min = AddressNumber.new(value: range_string)
        @max = AddressNumber.new(value: range_string)
        @step = 1
      end
    end

    sig { params(value: String, exact_match: T::Boolean).returns(T::Boolean) }
    def include?(value, exact_match = true)
      value_number = AddressNumber.new(value: value)
      value_segments = value_number.segments

      if value_segments.length != format.length
        return false if exact_match || format.length > 1

        numeric_only_value = value_number.to_i
        return false unless numeric_only_value

        value_segments = [numeric_only_value.to_s]
      end

      format.each_with_index do |range_segment, i|
        value_segment = value_segments[i]

        return false unless value_segment == range_segment || range_segment.include?(value_segment)
      end

      true
    end

    sig { returns(T.nilable(T::Range[Integer])) }
    def approx_numeric_range
      min_numeric = @min.to_i
      max_numeric = @max.to_i

      return unless min_numeric && max_numeric

      (min_numeric..max_numeric)
    end

    private

    sig { returns(T::Array[T::Array[String]]) }
    def format
      @format ||= if include_fractions?(@min.raw) || include_fractions?(@max.raw)
        fraction_format
      else

        min_segments = @min.segments
        max_segments = @max.segments

        range_value_format = []
        min_segments.each_with_index do |min_segment, i|
          max_segment = max_segments[i]
          range_value_format << values_in_range(min_segment, max_segment)
        end
        range_value_format
      end
    end

    sig { params(range_min: String, range_max: String).returns(T::Array[String]) }
    def values_in_range(range_min, range_max)
      (range_min..range_max).step(@step).to_a
    end

    sig { returns [T::Array[String]] }
    def fraction_format
      min_whole = whole_frac_value(@min.raw)
      max_whole = whole_frac_value(@max.raw)

      range_value_format = []

      fractions = [
        "",
        "1/2",
        "1/3",
        "1/4",
        "1/5",
        "1/6",
        "1/7",
        "1/8",
        "2/3",
        "2/4",
        "2/5",
        "2/6",
        "2/7",
        "2/8",
        "3/4",
        "3/5",
        "3/6",
        "3/7",
        "3/8",
        "4/5",
        "4/6",
        "4/7",
        "4/8",
        "5/6",
        "5/7",
        "5/8",
        "6/7",
        "6/8",
        "7/8",
      ]

      (min_whole..max_whole).step(@step).each do |whole|
        fractions.each do |fraction|
          number = build_mixed_fraction(whole, fraction)
          address_num = AddressNumber.new(value: number)
          range_value_format << number if address_num.to_r.between?(@min.to_r, @max.to_r)
        end
      end
      [range_value_format]
    end

    sig { params(value: String).returns(T::Boolean) }
    def include_fractions?(value)
      %r{^([0-9]+ )?([0-9]+/[0-9]+)?$}.match?(value)
    end

    sig { params(str: String).returns(String) }
    def whole_frac_value(str)
      pieces = str.split(" ")
      first_piece = T.must(pieces.first)
      if pieces.length == 2
        first_piece
      elsif pieces.length == 1
        if first_piece.include?("/")
          "0"
        else
          first_piece
        end
      else
        "0"
      end
    end

    sig { params(whole_number: String, proper_fraction: String).returns(String) }
    def build_mixed_fraction(whole_number, proper_fraction)
      if whole_number == "0"
        if proper_fraction == ""
          whole_number
        else
          proper_fraction
        end
      else
        [whole_number, proper_fraction].join(" ").strip
      end
    end
  end
end
