# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    class ClearRecordsJobTest < ActiveSupport::TestCase
      class DummyClass
      end
      setup do
        @blob_key = SecureRandom.hex
        @base_path = "/simulated/data/path"
        @country_code = "CA"
        @country_import = CountryImport.create!(country_code: @country_code)
        @country_import.start!
        FactoryBot.create(:ca_address, zip: "V5L 4S1")
        FactoryBot.create(:ca_address, zip: "V5M 1Y4")
        FactoryBot.create(:california_address, zip: "90210")
        FactoryBot.create(:california_address, zip: "90211")
      end

      test "#perform clears all country records from the PostAddress table" do
        ClearRecordsJob.any_instance.stubs(:import_log_info)

        untouched_records_count = PostAddress.where.not(country_code: @country_code).count
        ClearRecordsJob.perform_now(
          file_path: @blob_key,
          country_code: @country_code,
          country_import_id: @country_import.id,
          followed_by: [],
        )
        assert_equal untouched_records_count, PostAddress.count
        assert_equal 0, PostAddress.where(country_code: @country_code).count
      end
    end
  end
end
