# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Repository
      include RepositoryInterface
      extend T::Sig
      extend T::Helpers
      abstract!

      INITIAL_INDEX_VERSION = 0

      sig { override.returns(ClientInterface) }
      attr_reader :client

      sig { params(client: T.nilable(ClientInterface)).void }
      def initialize(client: nil)
        @client = T.let(client || Client.new, ClientInterface)
      end

      sig { override.returns(T.nilable(T::Hash[String, T.untyped])) }
      def index_mappings
        {
          "dynamic" => "false",
          "properties" => {
            "id" => { "type" => "long" },
          },
        }
      end

      sig { override.returns(T::Hash[Symbol, T.untyped]) }
      def index_settings
        {
          "index" => {
            "number_of_shards" => "1",
            "number_of_replicas" => "1",
            "mapping" => {
              "ignore_malformed" => "true",
            },
          },
        }
      end

      sig { override.returns(String) }
      def base_alias_name
        if Rails.env.test?
          "test_#{read_alias_name}"
        else
          read_alias_name
        end
      end

      sig do
        override.params(
          ensure_clean: T::Boolean,
          raise_errors: T::Boolean
        ).void
      end
      def create_next_index(ensure_clean: false, raise_errors: false)
        # PENDING: cleanup next index if ensure_clean = true
        return if client.index_or_alias_exists?(new_alias)

        versioned_index_name = if client.index_or_alias_exists?(active_alias)
          T.must(client.find_index_by(alias_name: active_alias)).next
        else
          "#{active_alias}.#{INITIAL_INDEX_VERSION}"
        end

        body = {
          aliases: {
            "#{new_alias}" => {
              is_write_index: true
            }
          },
          settings: index_settings,
          mappings: index_mappings
        }

        client.put(versioned_index_name, body)
      rescue
        raise if raise_errors
      end

      sig do
        override.params(
          raise_errors: T::Boolean
        ).void
      end
      def switch_to_next_index(raise_errors: false)
        update_all_aliases_of_index if client.index_or_alias_exists?(new_alias)
      rescue
        raise if raise_errors
      end

      sig do
        override.params(
          records: T.any(ActiveRecord::Relation, T::Array[PostAddressData])
        ).returns(T.nilable(Response))
      end
      def save_records_backfill(records)
        return if records.blank?

        alias_name = if client.index_or_alias_exists?(new_alias)
          new_alias
        elsif client.index_or_alias_exists?(active_alias)
          active_alias
        else
          raise "Next or current index must exist to backfill records"
        end

        body = ""
        records.each do |record|
          body += <<-NDJSON
            { "create": {} }
            #{record_source(record).to_json}
          NDJSON
        end

        client.post("/#{alias_name}/_bulk", body)
      end

      private

      sig { void }
      def update_all_aliases_of_index
        previous_index_name = client.find_index_by(alias_name: archived_alias)
        current_index_name = client.find_index_by(alias_name: active_alias)
        next_index_name = client.find_index_by(alias_name: new_alias)

        # delete the .archive alias
        if previous_index_name.present?
          client.delete(previous_index_name)
        end

        # archve the current alias
        if current_index_name.present?
          update_aliases_for_index(
            index_name: current_index_name,
            remove_alias: active_alias,
            add_alias: archived_alias
            )
        end

        # activate the .new alias
        if next_index_name.present?
          update_aliases_for_index(
            index_name: next_index_name,
            remove_alias: new_alias,
            add_alias: active_alias
            )
        end
      end

      sig do
        params(
          index_name: String,
          remove_alias: String,
          add_alias: String,
        ).void
      end
      def update_aliases_for_index(index_name:, remove_alias:, add_alias:)
        is_writable = (add_alias == active_alias) ? true : false

        body = {
          actions: [
            { remove: { index: index_name, alias: remove_alias } },
            { add: { index: index_name, alias: add_alias, is_write_index: is_writable } }
          ]
        }

        client.post("/_aliases", body)
      end
    end
  end
end
