# typed: true
# frozen_string_literal: true

module Maintenance
  module AtlasEngine
    class ElasticsearchIndexCreateTask < MaintenanceTasks::Task
      include ::AtlasEngine::LogHelper
      extend T::Sig

      attribute :country_code, :string
      attribute :locale, :string # optional (no locale implies index = country_code)
      attribute :province_codes, :string # optional comma separated list of province codes
      attribute :shard_override, :integer, default: nil
      attribute :replica_override, :integer, default: nil
      attribute :activate_index, :boolean, default: false unless Rails.env.production?

      validates :country_code, presence: true

      attr_writer :repository

      after_complete :switch_index unless Rails.env.production?

      sig { returns(T.nilable(ActiveRecord::Batches::BatchEnumerator)) }
      def collection
        @batch_number = 0
        batch_size = 2000

        sanitized_country_code = validate(T.must(country_code))

        address_conditions = {
          country_code: sanitized_country_code,
          province_code: sanitized_province_codes,
          locale: sanitized_locale,
        }.compact_blank

        record_count = ::AtlasEngine::PostAddress.where(address_conditions).size
        raise "No records to process for country code: #{country_code}" if record_count.zero?

        repository.create_next_index(ensure_clean: true)

        ::AtlasEngine::PostAddress.where(address_conditions).in_batches(of: batch_size)
      end

      sig { params(batch_of_post_address: ActiveRecord::Relation).void }
      def process(batch_of_post_address)
        log_info("Processing batch #{@batch_number} for repository #{repository.read_alias_name.upcase}.")
        repository.save_records_backfill(batch_of_post_address)
        @batch_number += 1
      end

      sig { returns(::AtlasEngine::CountryRepository) }
      def repository
        @repository ||= ::AtlasEngine::CountryRepository.new(
          country_code: T.must(country_code),
          repository_class: ::AtlasEngine.elasticsearch_repository.constantize,
          locale: sanitized_locale,
          index_configuration: index_configuration,
        )
      end

      sig { void }
      def switch_index
        if activate_index
          repository.switch_to_next_index
          log_info("Switched index `#{repository.read_alias_name}` live.")
        end
      end

      private

      sig { params(country_code: String).returns(String) }
      def validate(country_code)
        region = Worldwide.region(code: country_code)
        unless region.country?
          raise ArgumentError, "Invalid country code: #{country_code}"
        end

        region.iso_code
      end

      sig { returns(T::Array[String]) }
      def sanitized_province_codes
        return [] if province_codes.blank?

        T.must(province_codes).downcase.split(",").map(&:strip)
      end

      sig { returns(String) }
      def sanitized_locale
        locale.to_s.downcase
      end

      sig { returns(::AtlasEngine::IndexConfigurationFactory::IndexConfigurations) }
      def index_configuration
        ::AtlasEngine::IndexConfigurationFactory.new(
          country_code: T.must(country_code),
          locale: sanitized_locale,
          shard_override: shard_override,
          replica_override: replica_override,
        ).index_configuration(
          creating: true,
        )
      end
    end
  end
end
