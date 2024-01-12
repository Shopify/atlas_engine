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

        sig { params(_file_path: String).returns(T::Array[T.untyped]) }
        def load(_file_path)
          # FrozenRecord's default is to operate on a single YAML file containing all the records.
          # A custom backend like ours, that uses separate files, must load all of them and return an array.
          country_profiles = load_and_merge_fragments(CountryProfile.country_paths)
          locale_profiles = load_and_merge_fragments(CountryProfile.locale_paths)

          # These hashes are not complete country profiles, but rather fragments that will be merged
          # onto the default profile template.
          country_profiles + localize_profiles(country_profiles, locale_profiles)
        end

        private

        sig { params(path_patterns: T::Array[String]).returns(T::Array[T::Hash[String, T.untyped]]) }
        def load_and_merge_fragments(path_patterns)
          path_patterns.flat_map do |directory_pattern|
            Dir[directory_pattern]
          end.map do |profile_path|
            FrozenRecord::Backends::Yaml.load(profile_path)
          end.group_by do |profile|
            profile["id"]
          end.transform_values do |profile_fragments|
            profile_fragments.inject({}) do |memo, fragment|
              memo.deep_merge(fragment)
            end
          end.values
        end

        sig do
          params(country_profiles: T::Array[T.untyped], locale_profiles: T::Array[T.untyped])
            .returns(T::Array[T.untyped])
        end
        def localize_profiles(country_profiles, locale_profiles)
          locale_profiles.map do |locale_profile|
            base_profile_id = country_id_from_locale_id(locale_profile["id"])

            base_profile = country_profiles.find do |country_profile|
              country_profile["id"] == base_profile_id
            end

            (base_profile || {}).deep_merge(locale_profile)
          end
        end

        sig { params(locale_id: String).returns(String) }
        def country_id_from_locale_id(locale_id)
          unless locale_id.match?(/\A[A-Z]{2}_[A-Z]{2}\z/)
            raise "Invalid id for localized country profile: #{locale_id}"
          end

          T.must(locale_id.split("_").first)
        end
      end
    end

    DEFAULT_PROFILE = "DEFAULT"

    add_index :id, unique: true
    self.base_path = ""
    self.backend = Backend

    # rubocop:disable Style/ClassVars
    @@default_paths = T.let(
      [
        File.join(AtlasEngine::Engine.root, "db/data/country_profiles/default.yml"),
      ],
      T::Array[String],
    )

    @@country_paths = T.let(
      [
        File.join(AtlasEngine::Engine.root, "app/countries/atlas_engine/*/country_profile.yml"),
      ],
      T::Array[String],
    )

    @@locale_paths = T.let(
      [
        File.join(AtlasEngine::Engine.root, "app/countries/atlas_engine/*/locales/*/country_profile.yml"),
      ],
      T::Array[String],
    )

    @attributes = T.let([], T::Array[T.untyped])
    @records = T.let(nil, T.nilable(T::Array[T.untyped]))

    class << self
      extend T::Sig

      sig { returns(T::Array[String]) }
      def default_paths
        @@default_paths
      end

      sig { params(paths: T::Array[String]).void }
      def default_paths=(paths)
        @@default_paths = paths
      end

      sig { returns(T::Array[String]) }
      def country_paths
        @@country_paths
      end

      sig { params(paths: T::Array[String]).void }
      def country_paths=(paths)
        @@country_paths = paths
      end

      sig { returns(T::Array[String]) }
      def locale_paths
        @@locale_paths
      end

      sig { params(paths: T::Array[String]).void }
      def locale_paths=(paths)
        @@locale_paths = paths
      end

      sig { params(paths: T.any(String, T::Array[String])).void }
      def add_default_paths(paths)
        T.unsafe(@@default_paths).append(*Array(paths))
      end

      sig { params(paths: T.any(String, T::Array[String])).void }
      def add_country_paths(paths)
        T.unsafe(@@country_paths).append(*Array(paths))
      end

      sig { params(paths: T.any(String, T::Array[String])).void }
      def add_locale_paths(paths)
        T.unsafe(@@locale_paths).append(*Array(paths))
      end

      sig { void }
      def reset!
        unload!
        @@default_paths = []
        @@country_paths = []
        @@locale_paths = []
        @default_attributes = nil
      end
      # rubocop:enable Style/ClassVars

      # Overriding (load_records) from FrozenRecord::Base
      # so that we only create attribute methods that are not already defined
      sig { params(force: T::Boolean).returns(T::Array[T.untyped]) }
      def load_records(force: false)
        if force || (auto_reloading && file_changed?)
          unload!
        end

        @records ||= begin
          records = backend.load(file_path)
          if attribute_deserializers.any? || default_attributes
            records = records.map { |r| assign_defaults!(deserialize_attributes!(r.dup)).freeze }.freeze
          end
          @attributes = list_attributes(records).freeze
          define_attribute_methods(methods_to_be_created)
          records = FrozenRecord.ignore_max_records_scan { records.map { |r| load(r) }.freeze }
          index_definitions.values.each { |index| index.build(records) }
          records
        end
      end

      sig { params(country_code: String, locale: T.nilable(String)).returns(CountryProfile) }
      def for(country_code, locale = nil)
        raise CountryNotFoundError if country_code.blank?

        unless country_code == DEFAULT_PROFILE || Worldwide.region(code: country_code).country?
          raise CountryNotFoundError
        end

        ids = [country_code.upcase]
        ids.push("#{country_code.upcase}_#{locale.upcase}") if locale.present?

        # if a localized profile is not found, fall back to the
        # country's profile before falling back to the default profile
        begin
          id = ids.pop
          find(id)
        rescue FrozenRecord::RecordNotFound
          if ids.present?
            retry
          else
            new(default_attributes.merge("id" => id))
          end
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

      private

      sig { returns(T::Array[T.untyped]) }
      def methods_to_be_created
        @attributes.to_a.flatten.reject do |attribute_name|
          instance_methods.include?(attribute_name.to_sym)
        end
      end
    end

    sig { returns(CountryProfileValidationSubset).checked(:tests) }
    def validation
      CountryProfileValidationSubset.new(hash: attributes["validation"] || {})
    end

    sig { returns(CountryProfileIngestionSubset).checked(:tests) }
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
