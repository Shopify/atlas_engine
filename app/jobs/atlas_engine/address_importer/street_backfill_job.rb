# typed: false
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    class StreetBackfillJob < AddressImporter::ResumableImportJob
      include ImportLogHelper
      include LogHelper

      def build_enumerator(params, cursor:)
        enumerator_builder.build_times_enumerator(1, cursor: cursor)
      end

      def each_iteration(batch, params)
        @country_code = params[:country_code]
        @locales = CountryProfile.for(@country_code).validation.index_locales
        return if @locales.nil? || @locales.size < 2

        import_log_info(
          country_import: country_import,
          message: "Backfilling street data for locales #{@locales}...",
        )

        ActiveRecord::Base.connection.execute(backfill_streets_sql)
      end

      private

      def backfill_streets_sql
        <<-SQL.squish
          UPDATE #{PostAddress.table_name} AS target
          INNER JOIN (
            SELECT
              #{@locales.first}.source_id AS source_id,
              COALESCE(#{@locales.map { |loc| "#{loc}.street" }.join(", ")}) AS final_street,
              #{@locales.map { |loc| "CASE WHEN #{loc}.source_id IS NOT NULL THEN 1 ELSE 0 END AS #{loc}_present" }.join(",")}
            FROM (#{records_by_locale[@locales.first]}) AS #{@locales.first}
              #{join_tables_on_statement}
            HAVING (#{locale_presence_count}) > 1
          ) AS effective ON target.source_id = effective.source_id AND target.country_code = '#{@country_code}'
          SET target.street = effective.final_street
          WHERE target.country_code = '#{@country_code}' AND (target.street = '' OR target.street IS NULL)
        SQL
      end

      def records_by_locale
        @records_by_locale ||= @locales.index_with do |locale|
          PostAddress.where(country_code: @country_code, locale: locale).to_sql
        end
      end

      def join_tables_on_statement
        T.must(@locales[1..-1]).map do |loc|
          "LEFT JOIN (#{records_by_locale[loc]}) AS #{loc} ON #{@locales.first}.source_id = #{loc}.source_id"
        end.join("\n")
      end

      def locale_presence_count
        @locales.map { |loc| "#{loc}_present" }.join(" + ")
      end
    end
  end
end
