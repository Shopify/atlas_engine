# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressValidation
    class ZipTruncatorTest < ActiveSupport::TestCase
      test "#truncate shortens postal code to three characters for IE" do
        assert_equal "D15", ZipTruncator.new(country_code: "ie").truncate(zip: "D15 FP99")
      end

      test "#truncate shortens postal code to five characters for US" do
        assert_equal "12345", ZipTruncator.new(country_code: "us").truncate(zip: "1234560")
      end

      test "#truncate does not modify postal for other countries" do
        assert_equal "M5W 1E6", ZipTruncator.new(country_code: "ca").truncate(zip: "M5W 1E6")
      end

      test "#truncate prefers the method's country_code param over the instance's country_code" do
        assert_equal "12345", ZipTruncator.new(country_code: "ie").truncate(zip: "1234560", country_code: "us")
      end

      test "#truncate returns nil when zip is nil" do
        assert_nil ZipTruncator.new(country_code: "tt").truncate(zip: nil, country_code: "tt")
      end
    end
  end
end
