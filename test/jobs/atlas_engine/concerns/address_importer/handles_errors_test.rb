# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Concerns
    module AddressImporter
      class HandlesErrorsTest < ActiveSupport::TestCase
        include ActiveJob::TestHelper

        class JobSpecificError < StandardError
        end

        class ErrorsJob < ApplicationJob
          include HandlesErrors
          def perform(country_import_id:)
            raise JobSpecificError, "Error"
          end
        end

        class ConnectionErrorsJob < ApplicationJob
          include HandlesErrors
          def perform(country_import_id:)
            raise Mysql2::Error::ConnectionError, "Error"
          end
        end

        class StatementInvalidJob < ApplicationJob
          include HandlesErrors
          def perform(country_import_id:)
            raise ActiveRecord::StatementInvalid, "Error"
          end
        end

        test "StandardError marks the import as failed" do
          country_import = CountryImport.create(country_code: "CA")
          country_import.start!

          ErrorsJob.any_instance.expects(:import_log_error).times(1)

          ErrorsJob.perform_now(country_import_id: country_import.id)
          assert_equal "failed", country_import.reload.state
        end

        test "ConnectionError retries the job" do
          country_import = CountryImport.create(country_code: "US")
          country_import.start!
          assert_enqueued_with(job: ConnectionErrorsJob) do
            ConnectionErrorsJob.perform_now(country_import_id: country_import.id)
          end
          assert_equal "in_progress", country_import.reload.state
        end

        test "interrupting a failed job leaves the job in a failed state" do
          ErrorsJob.any_instance.expects(:import_log_error).times(1)

          country_import = CountryImport.create(country_code: "FR")
          country_import.start!
          country_import.interrupt!

          assert_equal true, country_import.failed?
          ErrorsJob.perform_now(country_import_id: country_import.id)
          assert_equal true, country_import.failed?
        end
      end
    end
  end
end
