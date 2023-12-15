# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class StreetTest < ActiveSupport::TestCase
    test "#name returns the base name of the street" do
      street = Street.new(street: "W Main St N")
      assert_equal "Main", street.name
    end

    test "#name returns the base name when pre/post directionals and suffix are missing" do
      street = Street.new(street: "Cloverleaf")
      assert_equal "Cloverleaf", street.name
    end

    test "#name works on base names having several words" do
      street = Street.new(street: "S Clover Leaf St")
      assert_equal "Clover Leaf", street.name
    end

    test "#with_stripped_name returns the street name with spaces removed in the base name" do
      street = Street.new(street: "S Clover Leaf St")
      assert_equal "S CloverLeaf St", street.with_stripped_name
    end
  end
end
