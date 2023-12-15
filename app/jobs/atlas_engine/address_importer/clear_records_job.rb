# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    class ClearRecordsJob < AddressImporter::ResumableImportJob
      include ImportLogHelper
      include LogHelper
      DELETION_BATCH_SIZE = 2000

      def build_enumerator(params, cursor:)
        enumerator_builder.build_times_enumerator(1, cursor: cursor)
      end

      def each_iteration(batch, params)
        @country_code = params[:country_code]
        clear_records
      end

      def clear_records
        import_log_info(
          country_import: country_import,
          message: "Clearing all records from PostAddress where country_code: #{@country_code}...",
        )
        rows_deleted = delete_rows
        rows_deleted = delete_rows until rows_deleted != DELETION_BATCH_SIZE
        import_log_info(country_import: country_import, message: "PostAddress records cleared.")
      end

      def delete_rows
        PostAddress.connection.exec_delete(
          "DELETE FROM #{PostAddress.table_name} where country_code = '#{@country_code}' LIMIT #{DELETION_BATCH_SIZE}",
          "DELETE",
          [],
        )
      end
    end
  end
end
