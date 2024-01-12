# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    module ClientInterface
      extend T::Sig
      extend T::Helpers
      abstract!

      ConfigType = T.type_alias { T::Hash[Symbol, T.untyped] }
      BodyType = T.type_alias { T.any(String, T::Hash[T.untyped, T.untyped]) }

      sig { abstract.returns(ConfigType) }
      def config; end

      sig do
        params(
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def get(path, body = nil, options = config.dup)
        request(:get, path, nil, options)
      end

      sig do
        params(
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def head(path, body = nil, options = config.dup)
        request(:head, path, body, options)
      end

      sig do
        params(
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def post(path, body = nil, options = config.dup)
        request(:post, path, body, options)
      end

      sig do
        params(
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def put(path, body = nil, options = config.dup)
        request(:put, path, body, options)
      end

      sig do
        params(
          path: String,
          body: T.nilable(BodyType),
          options: ConfigType,
        ).returns(Response)
      end
      def delete(path, body = nil, options = config.dup)
        request(:delete, path, body, options)
      end

      sig do
        abstract.params(
          method: T.any(Symbol, String),
          path: String,
          body: T.nilable(BodyType),
          options: T::Hash[Symbol, T.untyped],
        ).returns(Response)
      end
      def request(method, path, body = nil, options = {}); end

      sig { abstract.params(alias_name: String).returns(T.nilable(String)) }
      def find_index_by(alias_name:); end

      sig { abstract.params(name: String).returns(T::Boolean) }
      def index_or_alias_exists?(name); end
    end
  end
end
