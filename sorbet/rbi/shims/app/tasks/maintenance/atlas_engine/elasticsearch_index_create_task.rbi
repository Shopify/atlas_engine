# typed: true
# frozen_string_literal: true

module Maintenance
  module AtlasEngine
    class ElasticsearchIndexCreateTask
      sig { returns(String) }
      def country_code; end

      sig { params(value: T.nilable(::String)).returns(T.nilable(::String)) }
      def country_code=(value); end

      sig { returns(String) }
      def locale; end

      sig { params(value: T.nilable(::String)).returns(T.nilable(::String)) }
      def locale=(value); end

      sig { returns(String) }
      def province_codes; end

      sig { params(value: T.nilable(::String)).returns(T.nilable(::String)) }
      def province_codes=(value); end

      sig { returns(Integer) }
      def shard_override; end

      sig { params(value: T.nilable(::Integer)).returns(T.nilable(::Integer)) }
      def shard_override=(value); end

      sig { returns(Integer) }
      def replica_override; end

      sig { params(value: T.nilable(::Integer)).returns(T.nilable(::Integer)) }
      def replica_override=(value); end

      sig { returns(T::Boolean) }
      def activate_index; end

      sig { params(value: T.nilable(::T::Boolean)).returns(T.nilable(::T::Boolean)) }
      def activate_index=(value); end

    end
  end
end
