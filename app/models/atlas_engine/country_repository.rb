# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CountryRepository
    include LogHelper
    extend T::Sig

    PostAddressData = T.type_alias { T.any(PostAddress, T::Hash[Symbol, T.untyped]) }

    delegate :active_alias,
      :archived_alias,
      :new_alias,
      :read_alias_name,
      :record_source,
      :create_next_index,
      :switch_to_next_index,
      :save_records_backfill,
      to: :repository

    sig do
      params(
        country_code: T.any(String, Symbol),
        repository_class: T::Class[Elasticsearch::RepositoryInterface],
        locale: T.nilable(String),
        index_configuration: T.nilable(IndexConfigurationFactory::IndexConfigurations),
      ).void
    end
    def initialize(country_code:, repository_class:, locale: nil, index_configuration: nil)
      @country_code = T.let(country_code.to_s.downcase, String)
      @country_profile = T.let(CountryProfile.for(@country_code, locale), CountryProfile)

      @repository = T.let(
        repository_class.new(
          index_base_name: index_name(country_code: @country_code, locale: locale),
          index_mappings: index_configuration.present? ? index_configuration["mappings"] : {},
          index_settings: index_configuration.present? ? index_configuration["settings"] : {},
          mapper_callable: mapper_callable,
        ),
        Elasticsearch::RepositoryInterface,
      )
    end

    sig { params(id: T.any(String, Integer)).returns(T::Hash[String, T.untyped]) }
    def find(id)
      repository.find(id).deep_stringify_keys
    end

    sig { params(query: T::Hash[String, T.untyped]).returns(T::Array[T::Hash[String, T.untyped]]) }
    def search(query)
      repository.search(query)["hits"]["hits"]
    end

    sig { params(query: T::Hash[String, T.untyped]).returns(T::Array[T::Hash[String, T.untyped]]) }
    def analyze(query)
      build_analyze_result(repository.analyze(query))
    end

    sig { params(query: T::Hash[String, T.untyped]).returns(T::Array[T::Hash[String, T.untyped]]) }
    def term_vectors(query)
      build_term_vectors(repository.term_vectors(query))
    end

    private

    sig { params(country_code: T.any(String, Symbol), locale: T.nilable(String)).returns(String) }
    def index_name(country_code:, locale: nil)
      if country_profile.validation.multi_locale?
        if country_profile.validation.index_locales.include?(locale)
          "#{country_code}_#{locale}"
        else
          raise ArgumentError, "#{country_code} is a multi-locale country and requires a locale"
        end
      else
        country_code.to_s.downcase
      end
    end

    sig { returns(CountryProfile) }
    attr_reader :country_profile

    sig { returns(Elasticsearch::RepositoryInterface) }
    attr_reader :repository

    sig { params(es_response: T::Hash[String, T.untyped]).returns(T::Array[T.untyped]) }
    def build_analyze_result(es_response)
      Array(es_response["tokens"])
    end

    sig { params(es_response: T::Hash[String, T.untyped]).returns(T::Array[T.untyped]) }
    def build_term_vectors(es_response)
      Array(es_response["docs"])
    end

    sig { returns(T.nilable(T.proc.params(arg0: T.untyped).returns(T.untyped))) }
    def mapper_callable
      # Caching because there's only one per country
      return @mapper_callable if @mapper_callable

      mapper_class = country_profile.ingestion.data_mapper

      @mapper_callable = T.let(
        ->(address) {
          mapper_class.new(post_address: address, country_profile:).map_data
        },
        T.nilable(T.proc.params(arg0: T.untyped).returns(T.untyped)),
      )
    end
  end
end
