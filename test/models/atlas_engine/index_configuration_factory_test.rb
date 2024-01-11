# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/index_configuration_helper"

module AtlasEngine
  class IndexConfigurationFactoryTest < ActiveSupport::TestCase
    include IndexConfigurationHelper

    test "index_configuration sets shard and replica counts when creating is set to true" do
      configurations = IndexConfigurationFactory.new(
        country_code: "ca",
      ).index_configuration(creating: true)

      assert configurations.dig("settings", "index").key?("number_of_shards")
      assert configurations.dig("settings", "index").key?("number_of_replicas")
    end

    test "index_configuration unsets shard and replica counts when creating is set to false" do
      configurations = IndexConfigurationFactory.new(
        country_code: "ca",
      ).index_configuration(creating: false)

      assert_not configurations.dig("settings", "index").key?("number_of_shards")
      assert_not configurations.dig("settings", "index").key?("number_of_replicas")
    end

    test "index_configuration unsets shard and replica counts when creating is not specified" do
      configurations = IndexConfigurationFactory.new(
        country_code: "ca",
      ).index_configuration

      assert_not configurations.dig("settings", "index").key?("number_of_shards")
      assert_not configurations.dig("settings", "index").key?("number_of_replicas")
    end

    test "index_configuration correctly returns data for a country with a custom index config file" do
      factory = IndexConfigurationFactory.new(
        country_code: "AT",
      )

      actual_config = factory.index_configuration

      assert actual_config.dig(
        "settings", "index", "analysis", "analyzer", "text_analyzer", "filter"
      ).include?("german_normalization")
    end

    test "index_configuration correctly returns data for a country and locale with a custom index config file" do
      factory = IndexConfigurationFactory.new(
        country_code: "CH",
        locale: "de",
      )

      actual_config = factory.index_configuration

      assert actual_config.dig(
        "settings", "index", "analysis", "analyzer", "text_analyzer", "filter"
      ).include?("german_normalization")
    end

    test "index_configuration correctly returns data for a country with no custom index config file" do
      configurations = IndexConfigurationFactory.new(
        country_code: "kp",
      ).index_configuration

      assert configurations["settings"].present?
      assert configurations["mappings"].present?
    end

    test "index_configuration correctly returns data for a country and locale with no custom index config file" do
      configurations = IndexConfigurationFactory.new(
        country_code: "kp",
        locale: "ko",
      ).index_configuration

      assert configurations["settings"].present?
      assert configurations["mappings"].present?
    end

    test "zip_edge_ngram uses country profile values when defined" do
      config = IndexConfigurationFactory.new(
        country_code: "CA",
      ).index_configuration(creating: true)

      profile = CountryProfile.for("CA")

      assert_equal(
        profile.ingestion.settings_min_zip_edge_ngram,
        config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "min_gram"),
      )
      assert_equal(
        profile.ingestion.settings_max_zip_edge_ngram,
        config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "max_gram"),
      )
    end

    test "zip_edge_ngram defaults set for a country with postal codes and example values" do
      config = IndexConfigurationFactory.new(
        country_code: "AD",
      ).index_configuration(creating: true)

      profile = CountryProfile.for("AD")
      assert_nil profile.ingestion.settings_min_zip_edge_ngram
      assert_nil profile.ingestion.settings_max_zip_edge_ngram
      assert_equal 5, Worldwide.region(code: "AD").zip_example.length

      assert_equal "1", config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "min_gram")
      assert_equal "5", config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "max_gram")
    end

    test "zip_edge_ngram defaults set for a country with postal codes but no example values" do
      config = IndexConfigurationFactory.new(
        country_code: "KP",
      ).index_configuration(creating: true)

      profile = CountryProfile.for("KP")
      assert_nil profile.ingestion.settings_min_zip_edge_ngram
      assert_nil profile.ingestion.settings_max_zip_edge_ngram
      assert_nil Worldwide.region(code: "KP").zip_example

      assert_equal "1", config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "min_gram")
      assert_equal "10", config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "max_gram")
    end

    test "zip_edge_ngram defaults not set for a country with no postal codes" do
      config = IndexConfigurationFactory.new(
        country_code: "AW",
      ).index_configuration(creating: true)

      assert_not Worldwide.region(code: "AW").has_zip?

      assert_nil config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "min_gram")
      assert_nil config.dig("settings", "index", "analysis", "tokenizer", "zip_edge_ngram", "max_gram")
    end

    test "shard and replica overrides replace defaults" do
      configurations = IndexConfigurationFactory.new(
        country_code: "ca",
        shard_override: 3,
        replica_override: 4,
      ).index_configuration(creating: true)

      assert_equal "3", configurations.dig("settings", "index", "number_of_shards")
      assert_equal "4", configurations.dig("settings", "index", "number_of_replicas")
    end

    test "country profile can specify shard and replica counts" do
      AtlasEngine::CountryProfileIngestionSubset.any_instance.expects(:settings_number_of_shards).returns("3")
      AtlasEngine::CountryProfileIngestionSubset.any_instance.expects(:settings_number_of_replicas).returns("4")

      configurations = IndexConfigurationFactory.new(
        country_code: "ca",
      ).index_configuration(creating: true)

      assert_equal "3", configurations.dig("settings", "index", "number_of_shards")
      assert_equal "4", configurations.dig("settings", "index", "number_of_replicas")
    end

    test "includes city_synonyms in city_filter when countries/<cc>/synonyms.yml file is present" do
      config = IndexConfigurationFactory.new(
        country_code: "US",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/us/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "analyzer", "city_analyzer", "filter"),
        "city_synonyms"
    end

    test "adds a city_synonyms filter with values from countries/<cc>/synonyms.yml when present" do
      config = IndexConfigurationFactory.new(
        country_code: "US",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/us/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "filter", "city_synonyms", "synonyms"),
        "township, twp"
    end

    test "includes city_synonyms in city_filter when countries/<cc>/locales/<locale>/synonyms.yml file is present and locale is provided" do
      config = IndexConfigurationFactory.new(
        country_code: "CH",
        locale: "fr",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/ch/locales/fr/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "analyzer", "city_analyzer", "filter"),
        "city_synonyms"
    end

    test "adds a city_synonyms filter with values from countries/<cc>/locales/<locale>/synonyms.yml when present and locale is provided" do
      config = IndexConfigurationFactory.new(
        country_code: "CH",
        locale: "de",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/ch/locales/de/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "filter", "city_synonyms", "synonyms"),
        "sankt, st"
    end

    test "includes street_synonyms in street_filter when countries/<cc>/synonyms.yml file is present" do
      config = IndexConfigurationFactory.new(
        country_code: "US",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/us/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "analyzer", "street_analyzer", "filter"),
        "street_synonyms"
    end

    test "adds a street_synonyms filter with values from countries/<cc>/synonyms.yml when present" do
      config = IndexConfigurationFactory.new(
        country_code: "US",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/us/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "filter", "street_synonyms", "synonyms"),
        "first, 1st"
    end

    test "includes street_synonyms in street_filter when countries/<cc>/locales/<locale>/synonyms.yml file is present and locale is provided" do
      config = IndexConfigurationFactory.new(
        country_code: "CH",
        locale: "fr",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/ch/locales/fr/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "analyzer", "street_analyzer", "filter"),
        "street_synonyms"
    end

    test "adds a street_synonyms filter with values from countries/<cc>/locales/<locale>/synonyms.yml when present and locale is provided" do
      config = IndexConfigurationFactory.new(
        country_code: "CH",
        locale: "de",
      ).index_configuration(creating: true)

      assert AtlasEngine::Engine.root.join("app/countries/atlas_engine/ch/locales/de/synonyms.yml").exist?
      assert_includes config.dig("settings", "index", "analysis", "filter", "street_synonyms", "synonyms"),
        "strasse, str"
    end
  end
end
