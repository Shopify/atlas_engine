# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class GeoJsonImportLauncherJobTest < ActiveSupport::TestCase
        include ActiveJob::TestHelper

        setup do
          @file_path = "/simulated/data/path"
          @country_import = FactoryBot.create(:country_import, :pending)
          @country_code = "CA"
          @locale = "en"
        end

        test "#perform with clear_records:true starts ClearRecordsJob with the right jobs in followed_by" do
          GeoJsonImportLauncherJob.any_instance.expects(:import_log_info).times(2)

          CountryImport.stubs(:create!).with(country_code: @country_code).returns(@country_import)

          import_job_args = {
            country_code: @country_code,
            country_import_id: @country_import.id,
            geojson_file_path: @file_path,
            locale: @locale,
          }

          import_jobs = [
            { job_name: AddressImporter::OpenAddress::GeoJsonImportJob, job_args: import_job_args }, {
              job_name: AddressImporter::StreetBackfillJob,
              job_args: {
                country_code: @country_code, country_import_id: @country_import.id,
              },
            },
          ]

          GeoJsonImportLauncherJob.perform_now(
            country_code: @country_code,
            geojson_file_path: @file_path,
            clear_records: true,
            locale: @locale,
          )

          assert_enqueued_with(
            job: AddressImporter::ClearRecordsJob,
            args: [country_code: @country_code,
                   country_import_id: @country_import.id,
                   followed_by: import_jobs],
          )
        end

        test "#perform with clear_records:false starts GeoJsonImportJob with the right args" do
          GeoJsonImportLauncherJob.any_instance.expects(:import_log_info).times(2)

          CountryImport.stubs(:create!).with(country_code: @country_code).returns(@country_import)

          GeoJsonImportLauncherJob.perform_now(
            country_code: @country_code,
            geojson_file_path: @file_path,
            clear_records: false,
            locale: @locale,
          )

          assert_enqueued_with(
            job: AddressImporter::OpenAddress::GeoJsonImportJob,
            args: [country_code: @country_code,
                   country_import_id: @country_import.id,
                   geojson_file_path: @file_path,
                   locale: @locale,
                   followed_by: [
                     {
                       job_name: AddressImporter::StreetBackfillJob,
                       job_args: { country_code: @country_code, country_import_id: @country_import.id },
                     },
                   ]],
          )
        end

        test "#perform starts GeoJsonImportJob with the right args when multiple file paths are given" do
          GeoJsonImportLauncherJob.any_instance.expects(:import_log_info).times(2)

          CountryImport.stubs(:create!).with(country_code: @country_code).returns(@country_import)

          GeoJsonImportLauncherJob.perform_now(
            country_code: @country_code,
            geojson_file_path: "/simulated/data/path1,/simulated/data/path2",
            clear_records: false,
            locale: @locale,
          )

          assert_enqueued_with(
            job: AddressImporter::OpenAddress::GeoJsonImportJob,
            args: [country_code: @country_code,
                   country_import_id: @country_import.id,
                   geojson_file_path: "/simulated/data/path1",
                   locale: @locale,
                   followed_by: [
                     {
                       job_name: AddressImporter::OpenAddress::GeoJsonImportJob,
                       job_args: {
                         country_code: @country_code,
                         country_import_id: @country_import.id,
                         geojson_file_path: "/simulated/data/path2",
                         locale: @locale,
                       },
                     },
                     {
                       job_name: AddressImporter::StreetBackfillJob,
                       job_args: { country_code: @country_code, country_import_id: @country_import.id },
                     },
                   ]],
          )
        end

        test "#perform will fail the country import and log upon exception" do
          GeoJsonImportLauncherJob.any_instance.expects(:import_log_error).times(1)

          CountryImport.stubs(:create!).with(country_code: @country_code).returns(@country_import)

          CountryImport.any_instance.stubs(:start!).raises(StateMachines::InvalidTransition)

          GeoJsonImportLauncherJob.perform_now(
            country_code: @country_code,
            geojson_file_path: @file_path,
            clear_records: false,
            locale: @locale,
          )

          assert @country_import.reload.failed?
        end
      end
    end
  end
end
