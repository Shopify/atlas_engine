# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class AddressNumberTest < ActiveSupport::TestCase
    test "#to_i converts a numeric string to an int" do
      num = AddressNumber.new(value: "123")
      assert_equal 123, num.to_i
    end

    test "#to_i converts a string containing a number to an int" do
      nums = [AddressNumber.new(value: "A123"), AddressNumber.new(value: "123A")]
      nums.each do |num|
        assert_equal 123, num.to_i
      end
    end

    test "#to_i does not convert a string containing multiple numbers" do
      nums = [AddressNumber.new(value: "1-123"), AddressNumber.new(value: "1/2"), AddressNumber.new(value: "A1B2")]
      nums.each do |num|
        assert_nil num.to_i
      end
    end

    test "#to_i does not convert a non-numeric string" do
      num = AddressNumber.new(value: "ABC")
      assert_nil num.to_i
    end

    test "#to_r converts a string containing a whole number to a rational" do
      num = AddressNumber.new(value: "123")
      assert_equal 123/1r, num.to_r
    end

    test "#to_r converts a string containing a proper fraction to a rational" do
      num = AddressNumber.new(value: "1/2")
      assert_equal 1/2r, num.to_r
    end

    test "#to_r converts a string containing an improper fraction to a rational" do
      num = AddressNumber.new(value: "4/3")
      assert_equal 4/3r, num.to_r
    end

    test "#to_r converts a string containing a mixed fraction to a rational" do
      num = AddressNumber.new(value: "134 1/4")
      assert_equal 537/4r, num.to_r
    end

    test "#to_r does not throw an error for a non-fractional string" do
      num = AddressNumber.new(value: "ABC1")
      assert_equal 0/1r, num.to_r
    end

    test "#segments splits up numbers and non-numbers" do
      num = AddressNumber.new(value: "1/2 A100-A5")
      assert_equal ["1/2", "A", "100", "-", "A", "5"], num.segments
    end

    test "#segments splits up numbers and non numbers, including proper fractions appropriately" do
      num = AddressNumber.new(value: "A 1/2 A")
      assert_equal ["A", "1/2", "A"], num.segments
    end

    test "#segments splits up numbers and non numbers, including improper fractions appropriately" do
      num = AddressNumber.new(value: "23/4 C 2A")
      assert_equal ["23/4", "C", "2", "A"], num.segments
    end

    test "#segments splits up numbers and non numbers, including mixed fractions appropriately" do
      num = AddressNumber.new(value: "C 2 3/4 2A")
      assert_equal ["C", "2 3/4", "2", "A"], num.segments
    end
  end
end
