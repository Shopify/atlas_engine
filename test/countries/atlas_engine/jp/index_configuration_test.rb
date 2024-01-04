# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/index_configuration_helper"

module AtlasEngine
  module Jp
    class IndexConfigurationTest < ActiveSupport::TestCase
      test "mappings for JP are returned as expected" do
        config = IndexConfigurationFactory.new(country_code: "JP").index_configuration
        expected_mappings = {
          "properties" => {
            "locale" => { "type" => "keyword" },
            "approx_building_ranges" => { "type" => "integer_range" },
            "region1" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "region2" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "region3" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "region4" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "city_aliases" => {
              "type" => "nested",
              "dynamic" => "false",
              "properties" => {
                "alias" => {
                  "type" => "text",
                  "analyzer" => "text_analyzer",
                  "search_analyzer" => "city_analyzer",
                  "fields" => {
                    "keyword" => {
                      "type" => "keyword",
                    },
                  },
                },
              },
            },
            "suburb" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "street" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "search_analyzer" => "street_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "street_stripped" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "search_analyzer" => "street_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "zip" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => {
                "keyword" => { "type" => "keyword" },
                "ngram" => {
                  "type" => "text",
                  "analyzer" => "edge_ngram_analyzer",
                  "search_analyzer" => "keyword_analyzer",
                },
              },
            },
            "building_name" => {
              "type" => "text",
              "analyzer" => "text_analyzer",
              "fields" => { "keyword" => { "type" => "keyword" } },
            },
            "location" => { "type" => "geo_point" },
          },
        }
        assert_equal expected_mappings, config["mappings"]
      end

      test "settings for JP are returned as expected" do
        config = IndexConfigurationFactory.new(
          country_code: "JP",
        ).index_configuration(creating: true)
        expected_settings = {
          "index" => {
            "number_of_shards" => "1",
            "number_of_replicas" => "1",
            "analysis" => {
              "analyzer" => {
                "text_analyzer" => { "tokenizer" => "standard", "filter" => ["lowercase", "icu_folding"] },
                "keyword_analyzer" => {
                  "tokenizer" => "keyword",
                  "filter" => ["lowercase", "icu_folding"],
                },
                "street_analyzer" => {
                  "tokenizer" => "standard",
                  "filter" => ["lowercase", "icu_folding", "strip_special_characters"],
                },
                "city_analyzer" => {
                  "tokenizer" => "standard",
                  "filter" => ["lowercase", "icu_folding", "strip_special_characters"],
                },
                "edge_ngram_analyzer" => { "tokenizer" => "zip_edge_ngram", "filter" => ["lowercase", "icu_folding"] },
              },
              "filter" => {
                "strip_special_characters" => {
                  "type" => "pattern_replace",
                  "pattern" => "[!|@|%|&|\"|'|*|,|.|(|)|;|:]",
                },
              },
              "tokenizer" => { "zip_edge_ngram" => { "type" => "edge_ngram", "min_gram" => "3", "max_gram" => "8" } },
            },
          },
        }
        assert_equal expected_settings, config["settings"]
      end
    end
  end
end
