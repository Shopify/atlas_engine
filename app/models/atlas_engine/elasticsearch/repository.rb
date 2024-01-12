# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Repository
      include RepositoryInterface
      extend T::Sig
      extend T::Helpers

      INITIAL_INDEX_VERSION = 0

      sig { returns(ClientInterface) }
      attr_reader :client

      sig { returns(String) }
      attr_reader :index_base_name

      sig { returns(T::Hash[String, T.untyped]) }
      attr_reader :index_mappings

      sig { returns(T::Hash[Symbol, T.untyped]) }
      attr_reader :index_settings

      sig { returns(T.proc.params(arg0: T.untyped).returns(T.untyped)) }
      attr_reader :mapper_callable

      sig do
        override.params(
          index_base_name: String,
          index_settings: T::Hash[Symbol, T.untyped],
          index_mappings: T.nilable(T::Hash[String, T.untyped]),
          mapper_callable: T.nilable(T.proc.params(arg0: T.untyped).returns(T.untyped)),
        ).void
      end
      def initialize(index_base_name:, index_settings:, index_mappings:, mapper_callable: nil)
        @client = T.let(Client.new, ClientInterface)
        @index_base_name = T.let(index_base_name, String)
        @index_mappings = T.let(index_mappings || default_mapping, T::Hash[String, T.untyped])
        @index_settings = T.let(index_settings, T::Hash[Symbol, T.untyped])
        @mapper_callable = T.let(
          mapper_callable || ->(record) { record.to_hash },
          T.proc.params(arg0: T.untyped).returns(T.untyped),
        )
      end

      sig { override.returns(String) }
      def base_alias_name
        if Rails.env.test?
          "test_#{index_base_name.to_s.downcase}"
        else
          index_base_name.to_s.downcase
        end
      end

      sig { override.returns(String) }
      def read_alias_name
        base_alias_name
      end

      sig do
        override.params(
          ensure_clean: T::Boolean,
          raise_errors: T::Boolean,
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
            new_alias.to_s => {
              is_write_index: true,
            },
          },
          settings: index_settings,
          mappings: index_mappings,
        }

        client.put(versioned_index_name, body)
      rescue
        raise if raise_errors
      end

      sig do
        override.params(
          raise_errors: T::Boolean,
        ).void
      end
      def switch_to_next_index(raise_errors: false)
        update_all_aliases_of_index if client.index_or_alias_exists?(new_alias)
      rescue
        raise if raise_errors
      end

      sig do
        override.params(
          records: T.any(ActiveRecord::Relation, T::Array[PostAddressData]),
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

      sig { override.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def search(query)
        path = "/#{active_alias}/_search"
        response = client.post(path, query, {})

        response.body
      rescue ::Elastic::Transport::Transport::Error
        { "hits" => { "hits" => [] } }
      end

      sig { override.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def analyze(query)
        path = "/#{active_alias}/_analyze"
        response = client.post(path, query, {})

        response.body
      rescue ::Elastic::Transport::Transport::Error
        { "tokens" => [] }
      end

      sig { override.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def term_vectors(query)
        path = "/#{active_alias}/_mtermvectors"
        response = client.post(path, query, {})

        response.body
      rescue ::Elastic::Transport::Transport::Error
        { "docs" => [] }
      end

      sig { override.params(id: T.any(String, Integer)).returns(T::Hash[String, T.untyped]) }
      def find(id)
        path = "/#{active_alias}/_doc/#{id}"
        response = client.get(path, nil, {})

        response.body["_source"]
      rescue ::Elastic::Transport::Transport::Error
        {}
      end

      sig { override.params(post_address: PostAddressData).returns(T::Hash[Symbol, T.untyped]) }
      def record_source(post_address)
        mapper_callable.call(post_address).compact
      end

      sig { returns(T::Array[T.untyped]) }
      def indices
        path = "/_cat/indices?format=json"
        response = client.get(path, nil, {})

        response.body
      end

      private

      sig { returns(T::Hash[String, T.untyped]) }
      def default_mapping
        {
          "dynamic" => "false",
          "properties" => {
            "id" => { "type" => "long" },
          },
        }
      end

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
            add_alias: archived_alias,
          )
        end

        # activate the .new alias
        if next_index_name.present?
          update_aliases_for_index(
            index_name: next_index_name,
            remove_alias: new_alias,
            add_alias: active_alias,
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
        is_writable = add_alias == active_alias ? true : false

        body = {
          actions: [
            { remove: { index: index_name, alias: remove_alias } },
            { add: { index: index_name, alias: add_alias, is_write_index: is_writable } },
          ],
        }

        client.post("/_aliases", body)
      end
    end
  end
end
