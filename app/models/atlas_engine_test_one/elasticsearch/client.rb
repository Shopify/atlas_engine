
module AtlasEngineTestOne
  module Elasticsearch
    class Client

      DEFAULT_OPTIONS = {
        read_timeout: 1,
        open_timeout: 1,
        keep_alive_timeout: 60,
        retry_on_failure: false,
      }

      def initialize(config = {})
        @config = DEFAULT_OPTIONS.merge(config).freeze

        options = {
          url: @config[:url] || ENV["ELASTICSEARCH_URL"],
          retry_on_failure: false,
        }.compact

        @client = Elastic::Transport::Client.new(options) do |faraday_connection|
          faraday_connection.options.timeout = read_timeout
          faraday_connection.options.open_timeout = open_timeout

          if ENV["ELASTICSEARCH_API_KEY"].present?
            config[:headers].merge!({ Authorization: "ApiKey #{ ENV["ELASTICSEARCH_API_KEY"] }" })
          end
          faraday_connection.headers = config[:headers] if config[:headers].present?

          if ENV["ELASTICSEARCH_CLIENT_CERT"] && ENV["ELASTICSEARCH_CLIENT_KEY"]
            faraday_connection.ssl.client_cert = ENV["ELASTICSEARCH_CLIENT_CERT"]
            faraday_connection.ssl.client_key = ENV["ELASTICSEARCH_CLIENT_KEY"] # Not sure if we use this in prod or not
            faraday_connection.ssl.verify = true
          end

          if ENV["ELASTICSEARCH_CLIENT_CA_CERT"]
            faraday_connection.ssl.ca_file = ENV["ELASTICSEARCH_CLIENT_CA_CERT"]
            faraday_connection.ssl.verify = true # Not sure if we use this in prod or not
          end

          if ENV["ELASTICSEARCH_INSECURE_NO_VERIFY_SERVER"]
            f.ssl.verify = false
          end

          # faraday_adapter(f) do |client|
          #   timeout = @config[:keep_alive_timeout]

          #   client.keep_alive_timeout = timeout if client.respond_to?(:keep_alive_timeout=)
          #   client.idle_timeout = timeout if client.respond_to?(:idle_timeout=)
          # end
        end
      end

      def request(method, path, body = nil, options = {})
        raw_request(method, path, body, options) # TODO: bring back semian and tracing when necessary
      end

      private

      # Value is in seconds
      def read_timeout
        @config[:read_timeout]
      end

      # Value is in seconds
      def open_timeout
        @config[:open_timeout]
      end

      def raw_request(method, path, body, options)
        params = options[:params] ||= {}
        headers = options[:headers] ||= {}
        @client.transport.perform_request(method, path, params, body, headers)
      end
    end
  end
end
