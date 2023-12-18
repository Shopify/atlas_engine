# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/index_configuration_helper"

module AtlasEngine
  module De
    class IndexConfigurationTest < ActiveSupport::TestCase
      setup do
        @config = IndexConfigurationFactory.new(country_code: "DE").index_configuration
        @mappings = @config["mappings"]
        @settings = @config["settings"]
      end

      test "mappings for DE are returned as expected" do
        assert_equal "street_indexing_analyzer", @mappings.dig("properties", "street", "analyzer")
        assert_equal "street_indexing_analyzer", @mappings.dig("properties", "street_stripped", "analyzer")

        expected_street_decompounded_mapping = {
          "type" => "text",
          "analyzer" => "text_analyzer",
          "fields" => {
            "keyword" => {
              "type" => "keyword",
            },
          },
        }
        assert_equal expected_street_decompounded_mapping, @mappings.dig("properties", "street_decompounded")
      end

      test "settings for DE are returned as expected" do
        common_filter_chain = ["lowercase", "german_normalization", "icu_folding", "strip_special_characters"]

        analyzer_definitions = @settings.dig("index", "analysis", "analyzer")

        analyzer_definitions.values.all? do |analyzer|
          assert_equal common_filter_chain, analyzer["filter"].first(4)
        end

        assert_equal ["street_suffix_decompounder"],
          analyzer_definitions["street_indexing_analyzer"]["filter"][4..-1]

        assert_equal ["street_suffix_decompounder", "street_synonyms"],
          analyzer_definitions["street_analyzer"]["filter"][4..-1]

        decompounder_filter = {
          "type" => "pattern_capture",
          "preserve_original" => "false",
          "patterns" => [
            "(?<name>\\w+)(?<suffix>allee|gasse|kai|lande|pfad|platz|pl|ring|strasse|str|weg|zeile)(?:\\b)",
          ],
        }

        assert_equal decompounder_filter, @settings.dig("index", "analysis", "filter", "street_suffix_decompounder")
      end
    end
  end
end
