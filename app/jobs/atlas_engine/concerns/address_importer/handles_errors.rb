# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Concerns
    module AddressImporter
      module HandlesErrors
        extend ActiveSupport::Concern
        include ::AtlasEngine::AddressImporter::ImportLogHelper

        included do
          discard_on(StandardError) do |job, exception|
            country_import_id = job.arguments.first[:country_import_id]
            country_import = CountryImport.find(country_import_id)

            job.import_log_error(
              country_import: country_import,
              message: ":errors: Import failed with exception: #{exception.message}",
              additional_params: { stack_trace: exception.backtrace.inspect },
            )

            country_import.interrupt! if country_import.present?
          end

          retry_on(
            Mysql2::Error::ConnectionError,
            wait: 10.seconds,
            attempts: 5,
          ) do |job, exception|
            country_import_id = job.arguments.first[:country_import_id]
            country_import = CountryImport.find(country_import_id)

            job.import_log_error(country_import: country_import, message:
            "Job failed after 5 retries with error: #{exception.message}")

            country_import.interrupt! if country_import.present?
            raise exception
          end
        end
      end
    end
  end
end
