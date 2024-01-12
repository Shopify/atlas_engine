# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    class Client
      extend T::Sig
      include ClientInterface

      DEFAULT_OPTIONS = T.let(
        {
          read_timeout: 1,
          open_timeout: 1,
          keep_alive_timeout: 60,
          retry_on_failure: false,
          headers: {},
        },
        ConfigType,
      )

      sig { override.returns(ConfigType) }
      attr_reader :config

      sig { params(config: ConfigType).void }
      def initialize(config = {})
        @config = T.let(DEFAULT_OPTIONS.merge(config).freeze, ConfigType)

        options = {
          url: @config[:url] || ENV["ELASTICSEARCH_URL"],
          retry_on_failure: false,
        }.compact

        @client = T.let(
          Elastic::Transport::Client.new(options) do |faraday_connection|
            faraday_connection.options.timeout = read_timeout
            faraday_connection.options.open_timeout = open_timeout
            @config[:headers][:"Content-Type"] = "application/json"

            if ENV["ELASTICSEARCH_API_KEY"].present?
              @config[:headers][:Authorization] = "ApiKey #{ENV["ELASTICSEARCH_API_KEY"]}"
            end
            faraday_connection.headers = @config[:headers] if @config[:headers].present?

            if ENV["ELASTICSEARCH_CLIENT_CERT"] && ENV["ELASTICSEARCH_CLIENT_KEY"]
              faraday_connection.ssl.client_cert = ENV["ELASTICSEARCH_CLIENT_CERT"]
              faraday_connection.ssl.client_key = ENV["ELASTICSEARCH_CLIENT_KEY"]
              faraday_connection.ssl.verify = true
            end

            if ENV["ELASTICSEARCH_CLIENT_CA_CERT"]
              faraday_connection.ssl.ca_file = ENV["ELASTICSEARCH_CLIENT_CA_CERT"]
              faraday_connection.ssl.verify = true
            end

            if ENV["ELASTICSEARCH_INSECURE_NO_VERIFY_SERVER"]
              faraday_connection.ssl.verify = false
            end
          end,
          Elastic::Transport::Client,
        )
      end

      sig do
        override.params(
          method: T.any(Symbol, String),
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(AtlasEngine::Elasticsearch::Response)
      end
      def request(method, path, body = nil, options = config.dup)
        raw_request(method, path, body, options)
      end

      sig { override.params(alias_name: String).returns(T.nilable(String)) }
      def find_index_by(alias_name:)
        get("_alias/#{alias_name}").body.keys.first
      rescue Elastic::Transport::Transport::Errors::NotFound
        nil
      end

      sig { override.params(name: String).returns(T::Boolean) }
      def index_or_alias_exists?(name)
        head(name).status == 200
      rescue Elastic::Transport::Transport::Errors::NotFound
        false
      end

      private

      sig { returns(Integer) }
      def read_timeout
        @config[:read_timeout] # Value is in seconds
      end

      sig { returns(Integer) }
      def open_timeout
        @config[:open_timeout] # Value is in seconds
      end

      sig do
        params(
          method: T.any(Symbol, String),
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def raw_request(method, path, body, options)
        params = options[:params] ||= {}
        headers = options[:headers] ||= {}
        Response.new(@client.transport.perform_request(method, path, params, body, headers))
      end
    end
  end
end
