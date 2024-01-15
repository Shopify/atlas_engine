# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "elasticsearch_test_helper"

module AtlasEngine
  module Elasticsearch
    class RepositoryTest < ActiveSupport::TestCase
      include Elasticsearch::TestHelper

      class DefaultSampleRepository < AtlasEngine::Elasticsearch::Repository
        def initialize
          index_mappings = {
            "dynamic" => "false",
            "properties" => {
              "id" => { "type" => "long" },
            },
          }

          index_settings = {
            "index" => {
              "number_of_shards" => "1",
              "number_of_replicas" => "1",
              "mapping" => {
                "ignore_malformed" => "true",
              },
            },
          }
          super(index_base_name: "sample", index_settings:, index_mappings:)
        end

        def read_alias_name
          "default"
        end

        def record_source(record)
          {}
        end

        def hit_source_to_record(source)
          source.to_h
        end

        def build_analyze_result(es_response)
          es_response["tokens"]
        end

        def build_search_result(es_response)
          es_response["hits"]["hits"]
        end

        def build_term_vectors(es_response)
          es_response["docs"]
        end
      end

      class SampleRepository < AtlasEngine::Elasticsearch::Repository
        def initialize(base_name: "sample")
          @base_name = base_name
          index_base_name = base_name

          index_mappings = {
            "dynamic" => "false",
            "properties" => {
              "id" => { "type" => "long" },
            },
          }

          index_settings = {
            "index" => {
              "number_of_shards" => "1",
              "number_of_replicas" => "1",
              "mapping" => {
                "ignore_malformed" => "true",
              },
            },
          }
          super(index_base_name:, index_settings:, index_mappings:)
        end

        def read_alias_name
          @base_name
        end

        def record_source(record)
          {
            "name" => record[:name],
            "email" => record[:email],
            "age" => record[:age],
          }
        end

        def index_mappings
          {
            "properties" => {
              "name" => { "type" => "text" },
              "email" => { "type" => "keyword" },
              "age" => { "type" => "integer" },
            },
          }
        end

        def index_settings
          {
            "index" => {
              "number_of_replicas" => 1,
            },
          }
        end

        def hit_source_to_record(source)
          source.to_h
        end

        def build_analyze_result(es_response)
          es_response["tokens"]
        end

        def build_search_result(es_response)
          es_response["hits"]["hits"]
        end

        def build_term_vectors(es_response)
          es_response["docs"]
        end
      end

      def setup
        WebMock.disable!

        @client = AtlasEngine::Elasticsearch::Client.new
        @repository = SampleRepository.new
      end

      def teardown
        WebMock.enable!
      end

      test "index_mappings have default values" do
        assert_equal(
          {
            "dynamic" => "false",
            "properties" => {
              "id" => { "type" => "long" },
            },
          },
          DefaultSampleRepository.new.index_mappings,
        )
      end

      test "index_settings have default values" do
        assert_equal(
          {
            "index" => {
              "number_of_shards" => "1",
              "number_of_replicas" => "1",
              "mapping" => {
                "ignore_malformed" => "true",
              },
            },
          },
          DefaultSampleRepository.new.index_settings,
        )
      end

      test "#base_alias_name is same as read_alias_name in non test environments" do
        Rails.env.stubs(:test?).returns(false)
        assert_equal("sample", @repository.read_alias_name)
        assert_equal("sample", @repository.base_alias_name)
      end

      test "#base_alias_name prepends test_ to read_alias_name in test environment" do
        assert_equal("sample", @repository.read_alias_name)
        assert_equal("test_sample", @repository.base_alias_name)
      end

      test "#archived_alias computes the alias of the archived index" do
        assert_equal("test_sample.archive", @repository.archived_alias)
      end

      test "#active_alias computes the alias of the currently active index" do
        assert_equal("test_sample", @repository.active_alias)
      end

      test "#new_alias computes the alias of the next index that is not yet active" do
        assert_equal("test_sample.new", @repository.new_alias)
      end

      test "#create_next_index raises any errors if raise_errors is true" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        @repository.client.stubs(:index_or_alias_exists?).raises(StandardError)

        assert_raises(StandardError) do
          @repository.create_next_index(raise_errors: true)
        end
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#create_next_index creates an index with provided mappings" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        actual_alias_name = @repository.new_alias

        @repository.create_next_index

        actual_mappings = @repository.client.get("#{actual_alias_name}/_mappings").body.values.first.dig("mappings")

        assert(client.index_or_alias_exists?(actual_alias_name))
        assert_equal(@repository.index_mappings, actual_mappings)
      ensure
        cleanup_by_prefix(@repository.base_alias_name)
      end

      test "#create_next_index creates an index with .new alias if no indices exist" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.create_next_index

        assert(client.index_or_alias_exists?(@repository.new_alias))
      ensure
        cleanup_by_prefix(@repository.base_alias_name)
      end

      test "#create_next_index creates an index with the right settings and mappings" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        @repository.client.stubs(:index_or_alias_exists?).returns(false)

        @repository.client.expects(:put).with(
          correct_name("#{base_name}.0"),
          {
            aliases: {
              @repository.new_alias.to_s => {
                is_write_index: true,
              },
            },
            settings: @repository.index_settings,
            mappings: @repository.index_mappings,
          },
        ).once

        @repository.create_next_index
      end

      test "#create_next_index creates an index having suffix .0" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.create_next_index

        assert_equal(
          "#{correct_name(base_name)}.0",
          client.find_index_by(alias_name: @repository.new_alias),
        )
      ensure
        cleanup_by_prefix(@repository.base_alias_name)
      end

      test "#create_next_index does not create an index if a .new alias already exists" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        create_index(
          index_name: "#{base_name}_existing",
          alias_name: @repository.new_alias,
        )

        @repository.client.expects(:put).never

        @repository.create_next_index
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#create_next_index creates an index with a .new alias if an active index exists, \
        but a .new alias does not exist" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        # simulate an active index already exists
        create_index(
          index_name: "#{base_name}.0",
          alias_name: @repository.active_alias,
        )

        @repository.create_next_index
        assert(client.index_or_alias_exists?(@repository.new_alias))
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#create_next_index create new index with an incremented version" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        # simulate an active index already exists
        create_index(
          index_name: "#{base_name}.0",
          alias_name: @repository.active_alias,
        )

        @repository.create_next_index

        assert_equal(
          "#{correct_name(base_name)}.1",
          client.find_index_by(alias_name: @repository.new_alias),
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#switch_to_next_index raises any errors if raise_errors = true" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.client.stubs(:index_or_alias_exists?).raises(StandardError)

        assert_raises StandardError do
          @repository.switch_to_next_index(raise_errors: true)
        end
      end

      test "#switch_to_next_index converts a .new alias to an active alias" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.create_next_index

        previously_new_index = client.find_index_by(alias_name: @repository.new_alias)

        @repository.switch_to_next_index

        assert_not(@repository.client.index_or_alias_exists?(@repository.new_alias))
        assert(@repository.client.index_or_alias_exists?(@repository.active_alias))

        assert_equal(
          previously_new_index,
          client.find_index_by(alias_name: @repository.active_alias),
          "the previously index with .new alias shold now be activated",
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#switch_to_next_index does not archive an active alias if a .new alias is not available" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        @repository.create_next_index
        @repository.switch_to_next_index # switch to make .new as active

        # Attempt to archive an active alias (when a .new alias does not exist)
        @repository.switch_to_next_index

        assert_not(@repository.client.index_or_alias_exists?(@repository.new_alias))
        assert(
          @repository.client.index_or_alias_exists?(@repository.active_alias),
          "active alias should remain if a .new alias was not available",
        )
        assert_not(
          @repository.client.index_or_alias_exists?(@repository.archived_alias),
          "a .archive alias should not be created if a .new alias was not available",
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#switch_to_next_index archives an active alias if a .new alias exists" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        @repository.create_next_index
        @repository.switch_to_next_index  # switch to make .new as active
        @repository.create_next_index     # create a new .new alias

        previously_active_index = client.find_index_by(alias_name: @repository.active_alias)

        # Attempt to archive an active alias (when a .new alias exists)
        @repository.switch_to_next_index

        assert_not(@repository.client.index_or_alias_exists?(@repository.new_alias))
        assert(@repository.client.index_or_alias_exists?(@repository.active_alias))
        assert(
          @repository.client.index_or_alias_exists?(@repository.archived_alias),
          "a .archive alias should be created from the active alias",
        )

        assert_equal(
          previously_active_index,
          client.find_index_by(alias_name: @repository.archived_alias),
          "previously active index should be archived if a .new alias was available",
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#switch_to_next_index deletes an archived alias if a .new alias exists" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)

        @repository.create_next_index     # creates a .new alias
        @repository.switch_to_next_index  # switch to make .new as active
        @repository.create_next_index     # create a new .new alias
        @repository.switch_to_next_index  # switch to make active as .archive
        @repository.create_next_index     # create a new .new alias

        previously_archived_index = client.find_index_by(alias_name: @repository.archived_alias)

        @repository.switch_to_next_index  # should delete the currently archived index

        assert_not(
          @repository.client.index_or_alias_exists?(previously_archived_index),
          "a .archive index should be deleted if a .new alias was available",
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#save_records_backfill returns early if records are empty" do
        @repository = SampleRepository.new(base_name: "sample")
        assert_nil(@repository.save_records_backfill([]))
      end

      test "#save_records_backfill raises an error if no .new or active indices are present" do
        @repository = SampleRepository.new(base_name: "sample")
        records = [
          { name: "A", email: "a@email.com", age: 20 },
          { name: "B", email: "b@email.com", age: 30 },
        ]

        @repository.client.stubs(:index_or_alias_exists?).returns(false)

        error = assert_raises(StandardError) do
          @repository.save_records_backfill(records)
        end
        assert_equal("Next or current index must exist to backfill records", error.message)
      end

      test "#save_records_backfill inserts records into the .new index if it exists" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.create_next_index

        records = [
          { name: "A", email: "a@email.com", age: 20 },
          { name: "B", email: "b@email.com", age: 30 },
        ]

        @repository.save_records_backfill(records)

        # Waiting for the index to update
        sleep(1)

        response = @repository.client.get("#{@repository.new_alias}/_search")
        assert_equal(
          [
            { "name" => "A", "email" => "a@email.com", "age" => 20 },
            { "name" => "B", "email" => "b@email.com", "age" => 30 },
          ],
          response.body["hits"]["hits"].pluck("_source"),
        )
      ensure
        cleanup_by_prefix(base_name)
      end

      test "#save_records_backfill inserts records into the active index if no .new index exists" do
        base_name = generate_random_base_name
        @repository = SampleRepository.new(base_name: base_name)
        @repository.create_next_index
        @repository.switch_to_next_index

        records = [
          { name: "A", email: "a@email.com", age: 20 },
          { name: "B", email: "b@email.com", age: 30 },
        ]

        @repository.save_records_backfill(records)

        # Waiting for the index to update
        sleep(1)

        response = @repository.search({})
        assert_equal(
          [
            { "name" => "A", "email" => "a@email.com", "age" => 20 },
            { "name" => "B", "email" => "b@email.com", "age" => 30 },
          ],
          response["hits"]["hits"].pluck("_source"),
        )

        find_response = @repository.find(response["hits"]["hits"].first["_id"])
        assert_equal({ "name" => "A", "email" => "a@email.com", "age" => 20 }, find_response)
      ensure
        cleanup_by_prefix(base_name)
      end
    end
  end
end
