# typed: false
# frozen_string_literal: true

module Maintenance
  module AtlasEngine
    class GeoJsonImportTask < MaintenanceTasks::Task
      include ::AtlasEngine::HandlesBlob

      no_collection

      attribute :clear_records, :boolean, default: true
      # ISO3166 two-letter country code.
      attribute :country_code, :string
      validates :country_code, presence: true
      # Filename to import. When running in staging or production, the worker expects to find
      # this file in the relevant GCS bucket, configured in `config/storage/{environment}.yml`
      # It must be placed under `openaddress/` with the same filename.
      attribute :geojson_file_path, :string
      attribute :locale, :string

      def process = ::AtlasEngine::AddressImporter::OpenAddress::GeoJsonImportLauncherJob.perform_later(
        country_code:,
        geojson_file_path: geojson_file_path.strip,
        clear_records:,
        locale:,
      )
    end
  end
end
