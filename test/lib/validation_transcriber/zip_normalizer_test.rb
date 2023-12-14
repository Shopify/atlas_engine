# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class ZipNormalizerTest < ActiveSupport::TestCase
      test "#normalized_zip" do
        assert_equal "H0H 0H0", ZipNormalizer.normalize(country_code: "CA", zip: "h0h0h0")
      end

      test "#normalized_zip truncates ZIP+4 zips for the US" do
        assert_equal "10001", ZipNormalizer.normalize(country_code: "US", zip: "10001-7777")
      end

      test "#normalized_zip truncates ZIP when it contains extra optional characters" do
        assert_equal "1010", ZipNormalizer.normalize(country_code: "AT", zip: "A-1010")
      end

      test "#normalized_zip does not truncate the zip when it is invalid for the country" do
        assert_equal "10001-HHHH", ZipNormalizer.normalize(country_code: "US", zip: "10001-HHHH")
      end
    end
  end
end
