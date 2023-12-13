# typed: false
# frozen_string_literal: true

require "test_helper"
require "models/atlas_engine/address_validation/token_helper"

module AtlasEngine
  module AddressValidation
    class Token
      class ComparatorTest < ActiveSupport::TestCase
        include AddressValidation::TokenHelper

        test "same token" do
          left = token(value: "sooper")
          right = token(value: "sooper")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :equal,
            edit_distance: 0,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "close match" do
          left = token(value: "sooper")
          right = token(value: "dooper")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :comp,
            edit_distance: 1,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "left-hand side prefix match" do
          left = token(value: "soo")
          right = token(value: "sooper")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :prefix,
            edit_distance: 3,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "right-hand side prefix match" do
          left = token(value: "sooper")
          right = token(value: "soo")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :prefix,
            edit_distance: 3,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "left-hand side suffix match" do
          left = token(value: "oper")
          right = token(value: "sooper")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :suffix,
            edit_distance: 2,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "right-hand side suffix match" do
          left = token(value: "sooper")
          right = token(value: "oper")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :suffix,
            edit_distance: 2,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end

        test "not a close match" do
          left = token(value: "boulevard")
          right = token(value: "blvd")
          expected = AddressValidation::Token::Comparison.new(
            left: left,
            right: right,
            qualifier: :comp,
            edit_distance: 5,
          )

          comparator = AddressValidation::Token::Comparator.new(left, right)
          assert_equal expected, comparator.compare
        end
      end
    end
  end
end
