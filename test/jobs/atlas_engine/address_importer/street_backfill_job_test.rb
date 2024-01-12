# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporter
    class StreetBackfillJobTest < ActiveSupport::TestCase
      setup do
        @country_code = "CH"
        @country_import = CountryImport.create!(country_code: @country_code)
        @country_import.start!
        @de_address = FactoryBot.create(:ch_address, :de, source_id: "123")
        @fr_address = FactoryBot.create(:ch_address, :fr, source_id: "123", street: nil)
        @it_address = FactoryBot.create(:ch_address, :it, source_id: "123", street: nil)

        # to simulate a record that will not be included in the join
        FactoryBot.create(:ch_address, source_id: "1", locale: "zz")

        StreetBackfillJob.any_instance.stubs(:import_log_info)
      end

      test "#perform does nothing when there are no index locales set for the country" do
        AtlasEngine::CountryProfileValidationSubset.any_instance.expects(:index_locales).returns([])
        StreetBackfillJob.perform_now(
          country_code: @country_code,
          country_import_id: @country_import.id,
        )
        assert_nil @fr_address.reload.street
        assert_nil @it_address.reload.street
      end

      test "#perform does nothing when there is only one index locale set for the country" do
        AtlasEngine::CountryProfileValidationSubset.any_instance.expects(:index_locales).returns(["de"])
        StreetBackfillJob.perform_now(
          file_path: @blob_key,
          country_code: @country_code,
          country_import_id: @country_import.id,
          followed_by: [],
        )
        assert_nil @fr_address.reload.street
        assert_nil @it_address.reload.street
      end

      test "#perform backfills blank streets using the value from first priority locale's record" do
        AtlasEngine::CountryProfileValidationSubset.any_instance.expects(:index_locales).returns(["de", "fr", "it"])
        StreetBackfillJob.perform_now(
          country_code: @country_code,
          country_import_id: @country_import.id,
        )

        assert_equal @de_address.street, @fr_address.reload.street
        assert_equal @de_address.street, @it_address.reload.street
      end

      test "#perform backfills blank streets using the value from next priority locale's record if others are blank" do
        @de_address.update(street: nil)
        @fr_address.update(street: "Sagistrasse")
        AtlasEngine::CountryProfileValidationSubset.any_instance.expects(:index_locales).returns([
          "de",
          "fr",
          "it",
          "zz",
        ])

        StreetBackfillJob.perform_now(
          country_code: @country_code,
          country_import_id: @country_import.id,
        )
        assert_equal @fr_address.reload.street, @it_address.reload.street
        assert_equal @fr_address.reload.street, @de_address.reload.street
      end

      test "#perform does nothing if street values are blank for all locales" do
        @de_address.update(street: nil)
        AtlasEngine::CountryProfileValidationSubset.any_instance.expects(:index_locales).returns(["de", "fr", "it"])

        StreetBackfillJob.perform_now(
          country_code: @country_code,
          country_import_id: @country_import.id,
        )
        assert_nil @de_address.reload.street
        assert_nil @fr_address.reload.street
        assert_nil @it_address.reload.street
      end
    end
  end
end
