# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    module TestHelper
      def client
        @client ||= AtlasEngine::Elasticsearch::Client.new
      end

      def generate_random_base_name
        "sample_" + (rand * 100000000).to_i.to_s
      end

      def reset
        client.put("_cluster/settings", { "transient" => { "action.destructive_requires_name" => false } })
        client.delete("/*?ignore_unavailable=true")
      end

      def create_index(index_name:, alias_name:, settings: {}, mappings: {})
        test_index_name = correct_name(index_name)
        test_alias_name = correct_name(alias_name)

        body = {
          aliases: {
            test_alias_name.to_s => {
              is_write_index: true,
            },
          },
          settings: settings,
          mappings: mappings,
        }

        client.put("/#{test_index_name}", body)
      end

      def mock_elasticsearch_response(
        method:,
        path:,
        status: 200,
        headers: { "content-type" => "application/json" },
        body: {}
      )
        url = "#{ENV["ELASTICSEARCH_URL"]}/" + path.sub(%r{^/}, "")
        stub_request(method, url).to_return(
          status: status,
          headers: headers,
          body: body.to_json,
        )
      end

      def cleanup_by_prefix(prefix)
        client.put("_cluster/settings", { "transient" => { "action.destructive_requires_name" => false } })
        client.delete("/#{correct_name(prefix)}*?ignore_unavailable=true")
      end

      def correct_name(name)
        "test_" + name.delete_prefix("test_")
      end
    end
  end
end
