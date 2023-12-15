# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class AddressNumberRangeTest < ActiveSupport::TestCase
    test "raises a RangeError if the min and max are not compatible" do
      assert_raises AddressNumberRange::RangeError do
        AddressNumberRange.new(range_string: "(1A..5)/1")
      end
    end

    test ".merge_overlapping_ranges merges overlapping and consecutive ranges" do
      ranges = [(1..5), (44..50), (4..8), (9..13), (13..15), (17..19)]
      merged_ranges = [(1..15), (17..19), (44..50)]

      assert_equal merged_ranges, AddressNumberRange.merge_overlapping_ranges(ranges)
    end

    test "#approx_numeric_range has values when range is numeric only" do
      address_range = AddressNumberRange.new(range_string: "(1..5)/1")
      assert_equal (1..5), address_range.approx_numeric_range
    end

    test "#approx_numeric_range has values when range contains one number" do
      address_ranges = [
        [AddressNumberRange.new(range_string: "(A1..A5)/1"), (1..5)],
        [AddressNumberRange.new(range_string: "(1A..5A)/1"), (1..5)],
        [AddressNumberRange.new(range_string: "(A1..E1)/1"), (1..1)],
        [AddressNumberRange.new(range_string: "(1A..1E)/1"), (1..1)],
        [AddressNumberRange.new(range_string: "(C11A..C15A)/1"), (11..15)],
      ]

      address_ranges.each do |range, expected|
        assert_equal expected, range.approx_numeric_range
      end
    end

    test "#approx_numeric_range is nil when range has multiple numbers" do
      address_ranges = [
        AddressNumberRange.new(range_string: "(A1B13..A1B19)/1"),
        AddressNumberRange.new(range_string: "(88-1A..88-1C)/1"),
        AddressNumberRange.new(range_string: "(5140 1/2A..5152 1/2A)/1"),
      ]

      address_ranges.each do |range|
        assert_nil range.approx_numeric_range
      end
    end

    test "#approx_numeric_range is nil when range contains no numbers" do
      address_range = AddressNumberRange.new(range_string: "(A..E)/1")
      assert_nil address_range.approx_numeric_range
    end

    test "#include? returns false when the value's format doesn't match that of the range" do
      range = AddressNumberRange.new(range_string: "(1A..9A)/1")
      bad_values = ["1", "A", "3B", "A9"]

      bad_values.each { |value| assert_not range.include?(value) }
    end

    test "#include? handles ranges with a single value" do
      assert AddressNumberRange.new(range_string: "1").include?("1")
      assert_not AddressNumberRange.new(range_string: "1").include?("3")
      assert_not AddressNumberRange.new(range_string: "1").include?("10")

      assert_not AddressNumberRange.new(range_string: "10").include?("1")
      assert AddressNumberRange.new(range_string: "10").include?("10")

      assert AddressNumberRange.new(range_string: "1/2").include?("1/2")
      # this one is weird, but it's a limitation stemming from our usage of rational numbers
      assert AddressNumberRange.new(range_string: "1/2").include?("2/4")
      assert_not AddressNumberRange.new(range_string: "1/2").include?("0")
      assert_not AddressNumberRange.new(range_string: "1/2").include?("1")

      assert AddressNumberRange.new(range_string: "A1").include?("A1")
      assert_not AddressNumberRange.new(range_string: "A1").include?("A3")
    end

    test "#include? returns correct inclusion for a range with a step of 1" do
      range_string = "(1..9)/1"
      assert AddressNumberRange.new(range_string: range_string).include?("1")
      assert AddressNumberRange.new(range_string: range_string).include?("3")
      assert AddressNumberRange.new(range_string: range_string).include?("4")
      assert AddressNumberRange.new(range_string: range_string).include?("9")
      assert_not AddressNumberRange.new(range_string: range_string).include?("10")
    end

    test "#include? returns correct inclusion for a range with a step of 2" do
      range_string = "(1..9)/2"
      assert AddressNumberRange.new(range_string: range_string).include?("1")
      assert AddressNumberRange.new(range_string: range_string).include?("3")
      assert AddressNumberRange.new(range_string: range_string).include?("5")
      assert AddressNumberRange.new(range_string: range_string).include?("9")
      assert_not AddressNumberRange.new(range_string: range_string).include?("4")
    end

    test "#include? returns correct inclusion for ranges with prefixes" do
      range_examples = [
        ["(A1..A9)/2", ["A1", "A9", "A3"], ["A4"]],
        ["(1A..1E)/2", ["1A", "1E", "1C"], ["1B"]],
        ["(1001-11..1001-19)/2", ["1001-11", "1001-19", "1001-13"], ["1001-12"]],
      ]

      range_examples.each do |example|
        range = AddressNumberRange.new(range_string: example[0])
        example[1].each { |num| assert range.include?(num) }
        example[2].each { |num| assert_not range.include?(num) }
      end
    end

    test "#include? returns correct inclusion for ranges with suffixes" do
      range_examples = [
        ["(1A..9A)/2", ["1A", "9A", "3A"], ["4A"]],
        ["(A1..E1)/2", ["A1", "E1", "C1"], ["B1"]],
        ["(11-1001..19-1001)/2", ["11-1001", "19-1001", "13-1001"], ["12-1001"]],
      ]

      range_examples.each do |example|
        range = AddressNumberRange.new(range_string: example[0])
        example[1].each { |num| assert range.include?(num) }
        example[2].each { |num| assert_not range.include?(num) }
      end
    end

    test "#include? returns correct inclusion for ranges with prefixes and suffixes" do
      range_examples = [
        ["(A1A..A9A)/2", ["A1A", "A9A", "A3A"], ["A4A"]],
        ["(1A3..1E3)/2", ["1A3", "1E3", "1C3"], ["1B3"]],
        ["(1001-11B..1001-19B)/2", ["1001-11B", "1001-19B", "1001-13B"], ["1001-12B"]],
      ]

      range_examples.each do |example|
        range = AddressNumberRange.new(range_string: example[0])
        example[1].each { |num| assert range.include?(num) }
        example[2].each { |num| assert_not range.include?(num) }
      end
    end

    test "#include? permits extra characters if exact_match is false" do
      assert AddressNumberRange.new(range_string: "(1..9)/1").include?("5A", false)
      assert AddressNumberRange.new(range_string: "(1..9)/1").include?("A-B2", false)
    end

    test "#include? still rejects invalid values when exact_match is false" do
      assert_not AddressNumberRange.new(range_string: "(1..9)/1").include?("A", false)
      assert_not AddressNumberRange.new(range_string: "(1..9)/1").include?("10A", false)
    end

    test "#include? returns correct inclusions for ranges with step of 1 " do
      number_range = AddressNumberRange.new(range_string: "(118 1/2..119 1/2)/1")

      [
        "118 1/2",
        "118 2/3",
        "118 2/4",
        "118 3/4",
        "118 3/5",
        "118 3/6",
        "118 4/5",
        "118 4/6",
        "118 4/7",
        "118 4/8",
        "118 5/6",
        "118 5/7",
        "118 5/8",
        "118 6/7",
        "118 6/8",
        "118 7/8",
        "119",
        "119 1/2",
        "119 1/3",
        "119 1/4",
        "119 1/5",
        "119 1/6",
        "119 1/7",
        "119 1/8",
        "119 2/4",
        "119 2/5",
        "119 2/6",
        "119 2/7",
        "119 2/8",
        "119 3/6",
        "119 3/7",
        "119 3/8",
        "119 4/8",
      ].each do |num|
        assert number_range.include?(num)
      end

      [
        "118",
        "118 1/3",
        "118 1/8",
        "118 1/4",
        "118 2/5",
        "118 2/6",
        "118 2/7",
        "118 2/8",
        "118 3/7",
        "118 3/8",
        "119 2/3",
        "119 3/4",
        "119 3/5",
        "119 4/5",
        "119 4/6",
        "119 5/6",
        "119 4/7",
        "119 5/7",
        "119 6/7",
        "119 5/8",
        "119 6/8",
        "119 7/8",
        "123",
        "123 1/2",
      ].each do |num|
        assert_not number_range.include?(num)
      end
    end

    test "#include? returns correct inclusions for ranges with step of 2 " do
      number_range = AddressNumberRange.new(range_string: "(118 1/2..122 1/2)/2")

      [
        "118 1/2",
        "118 3/4",
        "120",
        "120 1/4",
        "120 1/2",
        "120 3/4",
        "122",
        "122 1/4",
        "122 1/2",
      ].each do |num|
        assert number_range.include?(num)
      end

      [
        "118",
        "118 1/4",
        "119",
        "119 1/4",
        "119 1/2",
        "119 3/4",
        "121",
        "121 1/4",
        "121 1/2",
        "121 3/4",
        "122 3/4",
      ].each do |num|
        assert_not number_range.include?(num)
      end
    end

    test "#include? returns correct inclusions for a range composed of a proper fraction and a mixed fraction" do
      number_range = AddressNumberRange.new(range_string: "(1/2..2 1/2)/2")

      [
        "1/2",
        "3/4",
        "2",
        "2 1/4",
        "2 1/3",
        "2 1/8",
        "2 1/2",
      ].each do |num|
        assert number_range.include?(num)
      end

      [
        "1/4",
        "1",
        "1 1/2",
        "2 3/4",
        "3",
      ].each do |num|
        assert_not number_range.include?(num)
      end
    end

    test "#include? returns correct inclusions for a range composed of a mixed fraction and min as a whole number" do
      number_range = AddressNumberRange.new(range_string: "(118..122 3/4)/2")

      [
        "118",
        "118 1/8",
        "118 1/7",
        "118 1/6",
        "118 1/5",
        "118 1/4",
        "118 1/3",
        "118 1/2",
        "118 3/4",
        "118 2/5",
        "120",
        "120 1/4",
        "120 1/2",
        "120 3/4",
        "122",
        "122 1/4",
        "122 1/2",
        "122 3/4",
      ].each do |num|
        assert number_range.include?(num)
      end

      [
        "119",
        "119 1/4",
        "119 1/2",
        "119 3/4",
        "121",
        "121 1/4",
        "121 1/2",
        "121 3/4",
        "123",
      ].each do |num|
        assert_not number_range.include?(num)
      end
    end

    test "#include? returns correct inclusions for a range composed of mixed fractions and max as a whole number" do
      number_range = AddressNumberRange.new(range_string: "(118 1/6..122)/2")

      [
        "118 1/6",
        "118 1/5",
        "118 1/4",
        "118 1/3",
        "118 1/2",
        "118 3/4",
        "118 2/5",
        "118 4/6",
        "120",
        "120 1/4",
        "120 1/2",
        "120 3/4",
        "122",
      ].each do |num|
        assert number_range.include?(num)
      end

      [
        "119",
        "119 1/4",
        "119 1/2",
        "119 3/4",
        "121",
        "121 1/4",
        "121 1/2",
        "121 3/4",
        "122 1/4",
        "122 1/2",
        "122 3/4",
        "122 1/8",
        "122 5/6",
        "122 1/3",
        "123",
      ].each do |num|
        assert_not number_range.include?(num)
      end
    end
  end
end
