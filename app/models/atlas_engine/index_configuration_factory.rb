# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class IndexConfigurationFactory
    extend T::Sig

    IndexConfigurations = T.type_alias { T::Hash[T.any(String, Symbol), T.untyped] }

    INDEX_CONFIGURATIONS_ROOT = T.let(
      File.join(AtlasEngine::Engine.root, "db/data/address_synonyms/index_configurations"), String
    )
    COUNTRIES_ROOT = T.let(File.join(AtlasEngine::Engine.root, "app/countries/atlas_engine"), String)

    DEFAULT_NUMBER_OF_SHARDS = 1
    DEFAULT_NUMBER_OF_REPLICAS = 1
    DEFAULT_MIN_ZIP_EDGE_GRAM = 1
    DEFAULT_MAX_ZIP_EDGE_GRAM = 10

    sig { returns(Symbol) }
    attr_reader :country_code

    sig { returns(T.nilable(String)) }
    attr_reader :locale

    sig { returns(CountryProfile) }
    attr_reader :country_profile

    sig { returns(T.nilable(Integer)) }
    attr_reader :shard_override

    sig { returns(T.nilable(Integer)) }
    attr_reader :replica_override

    sig do
      params(
        country_code: String,
        locale: T.nilable(String),
        shard_override: T.nilable(Integer),
        replica_override: T.nilable(Integer),
      ).void
    end
    def initialize(
      country_code:,
      locale: nil,
      shard_override: nil,
      replica_override: nil
    )
      @country_code = T.let(country_code.downcase.to_sym, Symbol)
      @locale = T.let(locale.present? ? locale.downcase : nil, T.nilable(String))
      @country = T.let(Worldwide.region(code: @country_code), Worldwide::Region)
      @country_profile = T.let(CountryProfile.for(@country_code.to_s.upcase, @locale), CountryProfile)
      @shard_override = T.let(shard_override, T.nilable(Integer))
      @replica_override = T.let(replica_override, T.nilable(Integer))
    end

    sig do
      params(
        creating: T::Boolean,
      ).returns(IndexConfigurations)
    end
    def index_configuration(creating: false)
      remove_create_only_settings unless creating
      configuration
    end

    private

    sig { returns(IndexConfigurations) }
    def configuration
      @configuration ||= T.let(
        defaults.deep_merge(country_overrides).deep_merge(locale_overrides),
        T.nilable(IndexConfigurations),
      )
    end

    sig { returns(IndexConfigurations) }
    def defaults
      render_file(:default)
    end

    sig { returns(IndexConfigurations) }
    def country_overrides
      render_file(country_code)
    end

    sig { returns(IndexConfigurations) }
    def locale_overrides
      return {} if locale.blank?

      render_file(country_code, locale)
    end

    sig { params(country_code: Symbol, locale: T.nilable(String)).returns(IndexConfigurations) }
    def render_file(country_code, locale = nil)
      file_path = file_path(country_code, locale)

      return {} if file_path.nil?

      configuration_file = ActiveSupport::ConfigurationFile.new(file_path)
      configuration_file.parse(context: binding).deep_stringify_keys
    end

    sig { params(country_code: Symbol, locale: T.nilable(String)).returns(T.nilable(String)) }
    def file_path(country_code, locale = nil)
      if country_code == :default
        return File.join(INDEX_CONFIGURATIONS_ROOT, "default.yml")
      end

      path = if locale.present?
        File.join(COUNTRIES_ROOT, "#{country_code}/locales/#{locale}/index_configuration.yml")
      else
        File.join(COUNTRIES_ROOT, "#{country_code}/index_configuration.yml")
      end

      path if File.file?(path)
    end

    sig { void }
    def remove_create_only_settings
      configuration.dig("settings", "index")&.delete("number_of_shards")
      configuration.dig("settings", "index")&.delete("number_of_replicas")
    end

    sig { returns(T::Array[String]) }
    def city_synonyms
      synonyms[:city_synonyms] || []
    end

    sig { returns(T::Array[String]) }
    def street_synonyms
      synonyms[:street_synonyms] || []
    end

    sig { returns(T::Hash[Symbol, T::Array[String]]) }
    def synonyms
      @synonyms ||= T.let(
        begin
          file_name = if locale.present?
            "#{COUNTRIES_ROOT}/#{country_code}/locales/#{locale}/synonyms.yml"
          else
            "#{COUNTRIES_ROOT}/#{country_code}/synonyms.yml"
          end

          empty_synonyms_hash = { street_synonyms: [], city_synonyms: [] }

          File.file?(file_name) ? YAML.load_file(file_name, freeze: true).deep_symbolize_keys : empty_synonyms_hash
        end,
        T.nilable(T::Hash[Symbol, T::Array[String]]),
      )
    end

    sig { returns(String) }
    def number_of_shards
      (
        shard_override ||
        country_profile.ingestion.settings_number_of_shards ||
        DEFAULT_NUMBER_OF_SHARDS
      ).to_s
    end

    sig { returns(String) }
    def number_of_replicas
      (
        replica_override ||
        country_profile.ingestion.settings_number_of_replicas ||
        DEFAULT_NUMBER_OF_REPLICAS
      ).to_s
    end

    sig { returns(String) }
    def zip_edge_min_gram
      country_profile.ingestion.settings_min_zip_edge_ngram || DEFAULT_MIN_ZIP_EDGE_GRAM.to_s
    end

    sig { returns(T.nilable(String)) }
    def zip_edge_max_gram
      country_profile.ingestion.settings_max_zip_edge_ngram ||
        @country.zip_example&.length&.to_s ||
        DEFAULT_MAX_ZIP_EDGE_GRAM.to_s
    end

    sig { returns(T::Boolean) }
    def country_has_zip?
      @country.has_zip?
    end
  end
end
