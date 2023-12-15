# typed: false
# frozen_string_literal: true

require "test_helper"
require "helpers/atlas_engine/active_storage_test_helper"

module AtlasEngine
  module AddressImporter
    class ResumableImportJobTest < ActiveSupport::TestCase
      class DummyAJob < ResumableImportJob
        def build_enumerator(params, cursor:)
          enumerator_builder.build_times_enumerator(1, cursor: cursor)
        end

        def each_iteration(batch, params)
        end
      end

      class DummyBJob < ResumableImportJob
        def build_enumerator(params, cursor:)
          enumerator_builder.build_times_enumerator(1, cursor: cursor)
        end

        def each_iteration(batch, params)
        end
      end

      setup do
        @country_code = "US"
      end

      test "#perform enqueues the jobs in followed_by" do
        country_import = CountryImport.create(country_code: @country_code)
        country_import.start!
        DummyBJob.expects(:perform_later).with(country_import_id: country_import.id, followed_by: [])

        DummyAJob.perform_now(
          country_import_id: country_import.id,
          followed_by: [{
            job_name: AddressImporter::ResumableImportJobTest::DummyBJob,
            job_args: { country_import_id: country_import.id },
          }],
        )
      end

      test "#perform marks the CountryImport as complete" do
        country_import = CountryImport.create(country_code: @country_code)
        country_import.start!

        DummyAJob.any_instance.stubs(:import_log_info)

        DummyAJob.perform_now(
          country_import_id: country_import.id,
          followed_by: [],
        )

        assert_equal "complete", country_import.reload.state
      end

      test "#perform logs when invalid addresses have been detected" do
        country_import = CountryImport.create(country_code: @country_code)
        country_import.start!

        Event.create(country_import: country_import, message: "foo", category: :invalid_address)

        DummyAJob.any_instance.expects(:import_log_info).once.with(
          country_import: country_import,
          message: "Import complete!",
          notify: true,
        )

        DummyAJob.any_instance.expects(:import_log_info).once.with(
          country_import: country_import,
          message: "Invalid addresses detected",
          notify: true,
        )

        DummyAJob.perform_now(
          country_import_id: country_import.id,
          followed_by: [],
        )
      end

      test "#perform logs when invalid addresses have not been detected" do
        country_import = CountryImport.create(country_code: @country_code)
        country_import.start!

        DummyAJob.any_instance.expects(:import_log_info).once.with(
          country_import: country_import,
          message: "Import complete!",
          notify: true,
        )

        DummyAJob.any_instance.expects(:import_log_info).once.with(
          country_import: country_import,
          message: "No invalid addresses detected",
          notify: true,
        )

        DummyAJob.perform_now(
          country_import_id: country_import.id,
          followed_by: [],
        )
      end
    end
  end
end
