# typed: false
# frozen_string_literal: true

require "test_helper"

module Maintenance
  module AtlasEngine
    class ElasticsearchIndexCreateTaskTest < ActiveSupport::TestCase
      def setup
        @repository = typed_mock(::AtlasEngine::CountryRepository)
        @repository.stubs(:create_next_index).returns(true)

        create(:illinois_address, zip: "60601")
        create(:illinois_address, zip: "60602")
        create(:california_address)
        create(:massachusetts_address)
        create(:gb_address)
      end

      test "initialize creates a country repository if not provided" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US" }
        repository = task.repository

        assert repository.present?
        assert_equal ::AtlasEngine::CountryRepository, repository.class
      end

      test "#collection retrieves all data for country" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", repository: @repository }
        actual_iterator = task.collection

        assert_equal(4, actual_iterator.relation.size)
      end

      test "#collection handles empty province code" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", province_codes: "", repository: @repository }
        actual_iterator = task.collection

        assert_equal(4, actual_iterator.relation.size)
      end

      test "#collection uses only province data when attribute is set" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", province_codes: "IL", repository: @repository }
        actual_iterator = task.collection

        assert_equal(2, actual_iterator.relation.size)
      end

      test "#collection uses province data of comma-delimited province codes when set" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", province_codes: "IL,ca", repository: @repository }
        actual_iterator = task.collection

        assert_equal(3, actual_iterator.relation.size)
      end

      test "#collection raises error on invalid country code" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "xx", repository: @repository }

        error = assert_raises(ArgumentError) { task.collection }
        assert_equal("Invalid country code: xx", error.message)
      end

      test "#collection raises error if there is no data for country" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "CA", repository: @repository }

        error = assert_raises(RuntimeError) { task.collection }
        assert_equal("No records to process for country code: CA", error.message)
      end

      test "#process persists batch to elasticsearch with provided index type" do
        @repository.stubs(:read_alias_name).returns("us")
        @repository.stubs(:save_records_backfill).once.returns(true)

        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", repository: @repository }
        actual_iterator = task.collection

        task.process(actual_iterator.relation)
      end

      test "#collection initializes a next index with ensure_clean flag set" do
        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", province_codes: "IL", repository: @repository }

        @repository.expects(:create_next_index).with(ensure_clean: true).returns(true)

        task.collection
      end

      test "#switch_index activates index when activate_index param is true" do
        @repository.stubs(:read_alias_name)

        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", repository: @repository, activate_index: true }
        task.collection

        @repository.expects(:switch_to_next_index).once

        task.switch_index
      end

      test "#switch_index does not activate index when activate_index param is false" do
        @repository.stubs(:read_alias_name)

        task = Maintenance::AtlasEngine::ElasticsearchIndexCreateTask.new
        task.attributes = { country_code: "US", repository: @repository, activate_index: false }
        task.collection

        @repository.expects(:switch_to_next_index).never

        task.switch_index
      end
    end
  end
end
