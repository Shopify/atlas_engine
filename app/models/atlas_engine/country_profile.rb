# typed: strict
# frozen_string_literal: true

module AtlasEngine
  class CountryProfile < FrozenRecord::Base
    extend T::Sig

    class CountryNotFoundError < StandardError; end

    module Backend
      extend FrozenRecord::Backends::Yaml

      class << self
        extend T::Sig

        sig { params(file_path: String).returns(T.untyped) }
        def load(file_path)
          # FrozenRecord's default is to operate on a single YAML file containing all the records.
          # A custom backend like ours, that uses separate files, must load all of them and return an array.
          CountryProfile.country_paths.flat_map do |directory_pattern|
            Dir[directory_pattern]
          end.map do |country_profile|
            super(country_profile)
          end.group_by do |profile|
            profile["id"]
          end.transform_values do |profile_fragments|
            profile_fragments.inject({}) do |memo, fragment|
              memo.deep_merge(fragment)
            end
          end.values
        end
      end
    end

    DEFAULT_PROFILE = "DEFAULT"

    add_index :id, unique: true
    self.base_path = ""
    self.backend = Backend

    @default_paths = T.let([
      File.join(AtlasEngine::Engine.root, "db/data/country_profiles/default.yml")
    ], T::Array[String])

    @country_paths = T.let([
      File.join(AtlasEngine::Engine.root, "app/countries/*/country_profile.yml")
    ], T::Array[String])

    class << self
      extend T::Sig

      sig { returns(T::Array[String]) }
      attr_accessor :default_paths

      sig { returns(T::Array[String]) }
      attr_accessor :country_paths

      sig { params(paths: T.any(String, T::Array[String])).void }
      def add_default_paths(paths)
        T.unsafe(@default_paths).append(*Array(paths))
      end

      sig { params(paths: T.any(String, T::Array[String])).void }
      def add_country_paths(paths)
        T.unsafe(@country_paths).append(*Array(paths))
      end

      sig { void }
      def reset!
        unload!
        @default_paths = []
        @country_paths = []
        @default_attributes = nil
      end

      sig { params(country_code: String).returns(CountryProfile) }
      def for(country_code)
        raise CountryNotFoundError if country_code.blank?

        unless country_code == DEFAULT_PROFILE || Worldwide.region(code: country_code).country?
          raise CountryNotFoundError
        end

        begin
          CountryProfile.find(country_code.upcase)
        rescue FrozenRecord::RecordNotFound
          CountryProfile.new(default_attributes.merge("id" => country_code.upcase))
        end
      end

      sig { returns(T::Hash[String, T.untyped]) }
      def default_attributes
        @default_attributes ||= T.let(
          default_paths.each_with_object({}) do |path, hash|
            hash.deep_merge!(YAML.load_file(path))
          end,
          T.nilable(T::Hash[String, T.untyped]),
        )
      end

      sig { override.params(record: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def assign_defaults!(record)
        default_attributes.deep_merge(record)
      end

      sig { returns(T::Set[String]) }
      def partial_zip_allowed_countries
        @partial_zip_allowed_countries ||= T.let(
          where.not(id: DEFAULT_PROFILE).filter do |country_profile|
            country_profile.ingestion.allow_partial_zip?
          end.map(&:id).to_set,
          T.nilable(T::Set[String]),
        )
      end

      sig { returns(T::Set[String]) }
      def validation_enabled_countries
        @validation_enabled_countries ||= T.let(
          where.not(id: DEFAULT_PROFILE).filter do |country_profile|
            country_profile.validation.enabled
          end.pluck(:id).to_set,
          T.nilable(T::Set[String]),
        )
      end
    end

    sig { returns(CountryProfileValidationSubset) }
    def validation
      CountryProfileValidationSubset.new(hash: attributes["validation"] || {})
    end

    sig { returns(CountryProfileIngestionSubset) }
    def ingestion
      CountryProfileIngestionSubset.new(hash: attributes["ingestion"])
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def open_address = (attributes["open_address"] || {}).with_indifferent_access

    sig { params(field: Symbol).returns(T::Array[String]) }
    def decompounding_patterns(field)
      attributes.dig("decompounding_patterns", field.to_s) || []
    end
  end
end