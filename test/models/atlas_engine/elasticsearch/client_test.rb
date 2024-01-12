# typed: false
# frozen_string_literal: true

require "test_helper"
require_relative "elasticsearch_test_helper"

module AtlasEngine
  module Elasticsearch
    class ClientTest < ActiveSupport::TestCase
      include Elasticsearch::TestHelper

      def setup
        @mock_http_response = mock
        mock.stubs(:status).returns(200)
        mock.stubs(:body).returns({ "data-type" => "mock-response" })
        mock.stubs(:headers).returns({ "content-type" => "application/json" })

        @mock_response = Response.new(@mock_http_response)
      end

      test "#request connects to ES and returns a response successfully" do
        path = "/"

        mock_response_body = {
          "name" => "mock-name",
          "cluster_name" => "mock-cluster",
          "cluster_uuid" => "mock-uuid",
          "version" =>
          {
            "number" => "8.7.1",
            "build_flavor" => "default",
            "build_type" => "docker",
            "build_hash" => "f229ed3f893a515d590d0f39b05f68913e2d9b53",
            "build_date" => "2023-04-27T04:33:42.127815583Z",
            "build_snapshot" => false,
            "lucene_version" => "9.5.0",
            "minimum_wire_compatibility_version" => "7.17.0",
            "minimum_index_compatibility_version" => "7.0.0",
          },
          "tagline" => "You Know, for Search",
        }

        mock_elasticsearch_response(
          method: :get,
          path: path,
          body: mock_response_body,
        )

        response = client.request(:get, path)

        assert_equal(Response, response.class)
        assert_equal(200, response.status)
        assert_equal({ "content-type" => "application/json" }, response.headers)
        assert_equal(mock_response_body, response.body)
      end

      test "#get makes a successful :get request" do
        client.expects(:request).with(:get, "/", nil, { mock: "options" }).once.returns(@mock_response)
        client.get("/", nil, { mock: "options" })
      end

      test "#head makes a successful :head request" do
        client.expects(:request).with(:head, "/", nil, { mock: "options" }).once.returns(@mock_response)
        client.head("/", nil, { mock: "options" })
      end

      test "#post makes a successful :post request" do
        client.expects(:request).with(:post, "/", "mock body", { mock: "options" }).once.returns(@mock_response)
        client.post("/", "mock body", { mock: "options" })
      end

      test "#put makes a successful :put request" do
        client.expects(:request).with(:put, "/", "mock body", { mock: "options" }).once.returns(@mock_response)
        client.put("/", "mock body", { mock: "options" })
      end

      test "#delete makes a successful :delete request" do
        client.expects(:request).with(:delete, "/", "mock body", { mock: "options" }).once.returns(@mock_response)
        client.delete("/", "mock body", { mock: "options" })
      end

      test "#find_index_by returns first index associated with alias" do
        alias_name = "sample"
        mock_elasticsearch_response(
          method: :get,
          path: "/_alias/#{alias_name}",
          body: { "sample.0" => { "aliases" => { "sample" => { "is_write_index" => true } } } },
        )

        assert_equal("sample.0", client.find_index_by(alias_name: alias_name))
      end

      test "#find_index_by returns nil if alias was not found" do
        alias_name = "sample"
        client.stubs(:get).raises(Elastic::Transport::Transport::Errors::NotFound)

        assert_nil(client.find_index_by(alias_name: alias_name))
      end

      test "#index_or_alias_exists? returns true if index/alias exists" do
        index_or_alias_name = "sample"

        mock_elasticsearch_response(
          method: :head,
          path: index_or_alias_name,
        )

        assert(client.index_or_alias_exists?(index_or_alias_name))
      end

      test "#index_or_alias_exists? returns false if index/alias does not exists" do
        index_or_alias_name = "sample"
        client.stubs(:head).raises(Elastic::Transport::Transport::Errors::NotFound)

        assert_not(client.index_or_alias_exists?(index_or_alias_name))
      end
    end
  end
end
