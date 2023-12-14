# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class FormatterTest < ActiveSupport::TestCase
      class MockFormatter
        include Formatter
      end

      test "#strip_trailing_punctuation removes trailing punctuation" do
        formatter = MockFormatter.new
        assert_equal "123 Main St", formatter.strip_trailing_punctuation("123 Main St,")
        assert_equal "123 Main St", formatter.strip_trailing_punctuation("123 Main St-")
        assert_equal "123 Main St", formatter.strip_trailing_punctuation("123 Main St   ")
        assert_equal "123 Main St", formatter.strip_trailing_punctuation("123 Main St, ")
      end

      test "#strip_word strips the given needle from the haystack" do
        formatter = MockFormatter.new
        assert_equal "123 Main St", formatter.strip_word("123 Main St Apt 1", "Apt 1")
      end

      test "#strip_word removes surrounding commas/spaces when stripping the needle from the haystack" do
        formatter = MockFormatter.new
        assert_equal "123 Main St, NY", formatter.strip_word("123 Main St, Apt 1, NY", "Apt 1")
      end

      test "#strip_word strips the given needle from the haystack, even if it has special regex chars" do
        formatter = MockFormatter.new
        assert_equal "123 Main St", formatter.strip_word("123 Main St Apt (", "Apt (")
      end

      test "#strip_word replaces with a space when the needle is surrounded by spaces" do
        formatter = MockFormatter.new
        assert_equal "123 Main St Arizona", formatter.strip_word("123 Main St Pheonix Arizona", "Pheonix")
      end

      test "#strip_word does not add a space when the needle is not surrounded by spaces" do
        formatter = MockFormatter.new
        assert_equal "123 Main St Arizona", formatter.strip_word("123 Main St,Pheonix, Arizona", "Pheonix")
      end

      test "#strip_word removes trailing punctuation" do
        formatter = MockFormatter.new
        assert_equal "123 Main St, Apt 1", formatter.strip_word("123 Main St, Apt 1, NY", "NY")
      end

      test "#build_address builds an address" do
        address = MockFormatter.new.build_address(
          address1: "290 Bremner Blvd",
          city: "Toronto",
          province_code: "ON",
          zip: "M5V 3L9",
          country_code: "CA",
          phone: "4168686937",
        )

        assert_equal "290 Bremner Blvd", address.address1
        assert_equal "", address.address2
        assert_equal "Toronto", address.city
        assert_equal "ON", address.province_code
        assert_equal "M5V 3L9", address.zip
        assert_equal "CA", address.country_code
        assert_equal "4168686937", address.phone
      end
    end
  end
end
