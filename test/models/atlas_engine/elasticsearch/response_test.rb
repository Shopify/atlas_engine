# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module Elasticsearch
    class ResponseTest < ActiveSupport::TestCase
      class MockResponse
        attr_reader :body, :status, :headers

        def initialize(body:, status:, headers:)
          @body = body
          @status = status
          @headers = headers
        end
      end

      def setup
        @body = { name: "mock body" }
        @status = 200
        @headers = { name: "mock header" }

        @mock_response = MockResponse.new(body: @body, status: @status, headers: @headers)
      end

      test "#response returns the original response object" do
        response = Response.new(@mock_response)
        assert_equal(@mock_response, response.response)
      end

      test "#body, #status, #headers are accessible from the instance" do
        response = Response.new(@mock_response)

        assert_equal(@body, response.body)
        assert_equal(@status, response.status)
        assert_equal(@headers, response.headers)
      end
    end
  end
end
