# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module ValidationTranscriber
    class ProvinceCodeNormalizerTest < ActiveSupport::TestCase
      test "#normalize when provided with valid ISO format" do
        assert_equal "JP-14", ProvinceCodeNormalizer.normalize(country_code: "JP", province_code: "jp-14")
        assert_equal "PR", ProvinceCodeNormalizer.normalize(country_code: "US", province_code: "us-pr")
        assert_equal "CA-ON", ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: "ca-on")
        assert_equal "AR-B", ProvinceCodeNormalizer.normalize(country_code: "AR", province_code: "ar-b")
      end

      test "#normalize when provided with subdivision codes" do
        assert_equal "JP-14", ProvinceCodeNormalizer.normalize(country_code: "JP", province_code: "14")
        assert_equal "PR", ProvinceCodeNormalizer.normalize(country_code: "US", province_code: "pr")
        assert_equal "CA-ON", ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: "on")
        assert_equal "AR-B", ProvinceCodeNormalizer.normalize(country_code: "AR", province_code: "b")
      end

      test "#normalize when provided with CLDR format" do
        assert_equal "JP-14", ProvinceCodeNormalizer.normalize(country_code: "JP", province_code: "jp14")
        assert_equal "PR", ProvinceCodeNormalizer.normalize(country_code: "US", province_code: "uspr")
        assert_equal "CA-ON", ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: "caon")
        assert_equal "AR-B", ProvinceCodeNormalizer.normalize(country_code: "AR", province_code: "arb")
      end

      test "#normalize returns province when country or province is invalid" do
        assert_nil ProvinceCodeNormalizer.normalize(country_code: nil, province_code: nil)
        assert_nil ProvinceCodeNormalizer.normalize(country_code: "", province_code: "")
        assert_equal "caon", ProvinceCodeNormalizer.normalize(country_code: nil, province_code: "caon")
        assert_equal "caon", ProvinceCodeNormalizer.normalize(country_code: "", province_code: "caon")
        assert_nil ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: nil)
        assert_nil ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: "")
        assert_equal "caon", ProvinceCodeNormalizer.normalize(country_code: "XX", province_code: "caon")
        assert_equal "blah", ProvinceCodeNormalizer.normalize(country_code: "CA", province_code: "blah")
      end
    end
  end
end
