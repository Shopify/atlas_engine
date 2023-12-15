# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class GeoJsonImportLauncherJob < ApplicationJob
        extend T::Sig
        include ImportLogHelper

        sig { params(country_code: String, geojson_file_path: String, clear_records: T::Boolean, locale: String).void }
        def perform(country_code:, geojson_file_path:, clear_records:, locale:)
          import = CountryImport.create!(country_code: country_code)
          import.start!

          import_log_info(
            country_import: import,
            message: "Starting import",
            additional_params: { file: geojson_file_path },
            notify: true,
          )

          geojson_file_paths = geojson_file_path.split(",")

          geojson_import_jobs = geojson_file_paths.map do |geojson_file_path|
            geojson_job_args = {
              country_code: country_code,
              country_import_id: import.id,
              geojson_file_path: geojson_file_path,
              locale: locale,
            }
            { job_name: GeoJsonImportJob, job_args: geojson_job_args }
          end

          street_backfill_job = {
            job_name: AddressImporter::StreetBackfillJob,
            job_args: { country_code: country_code, country_import_id: import.id },
          }

          if clear_records
            import_log_info(country_import: import, message: "Clearing records before import...")

            AddressImporter::ClearRecordsJob.perform_later(
              country_import_id: import.id,
              country_code: country_code.upcase,
              followed_by: geojson_import_jobs + [street_backfill_job],
            )
          else
            import_log_info(country_import: import, message: "Importing without clearing records...")

            GeoJsonImportJob.perform_later(
              **T.must(geojson_import_jobs.first)[:job_args],
              followed_by: geojson_import_jobs.drop(1) + [street_backfill_job],
            )
          end
        rescue StandardError => e
          import_log_error(
            country_import: T.must(import),
            message: "Import failed with #{e.class}",
            additional_params: { error: e },
          )
          import&.interrupt
        end
      end
    end
  end
end
