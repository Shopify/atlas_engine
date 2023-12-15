# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    class ResumableImportJob < ApplicationJob
      include JobIteration::Iteration
      include ImportLogHelper
      include Concerns::AddressImporter::HandlesErrors

      on_complete do |job|
        next_job = job.argument(:followed_by)&.shift
        if next_job.present?
          job_args_with_followed_by = next_job[:job_args].merge({ followed_by: job.argument(:followed_by) })
          next_job[:job_name].perform_later(**job_args_with_followed_by)
        elsif country_import.present?
          country_import.complete!
          log_final_stats
        end
      end

      sig { void }
      def log_final_stats
        message = if country_import.detected_invalid_addresses?
          "Invalid addresses detected"
        else
          "No invalid addresses detected"
        end

        import_log_info(
          country_import: country_import,
          message: message,
          notify: true,
        )

        import_log_info(
          country_import: country_import,
          message: "Import complete!",
          notify: true,
        )
      end

      def country_import
        country_import_id = argument(:country_import_id)
        CountryImport.find(country_import_id) if country_import_id.present?
      end
    end
  end
end
