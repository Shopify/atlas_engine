# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class CountryProfileSubsetBaseTest < ActiveSupport::TestCase
    class SampleProfileSubset < CountryProfileSubsetBase
      def predefined_method
        "predefined value"
      end
    end

    test "#initialize creates methods dynamically from hash keys" do
      hash = { "my_key" => "sample value" }
      subset = SampleProfileSubset.new(hash: hash)
      assert subset.respond_to?(:my_key)
      assert_equal "sample value", subset.my_key
    end

    test "#attributes provide the correct attribute values" do
      hash = { "my_key" => "sample value", "my_other_key" => "other value" }
      subset = SampleProfileSubset.new(hash: hash)
      assert_equal hash, subset.attributes
    end

    test "a defined method overrides a dynamically created method" do
      hash = { "predefined_method" => "original value" }
      subset = SampleProfileSubset.new(hash: hash)
      assert_equal "predefined value", subset.predefined_method
    end
  end
end
