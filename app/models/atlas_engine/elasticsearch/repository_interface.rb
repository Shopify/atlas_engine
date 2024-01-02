# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    module RepositoryInterface
      extend T::Sig
      extend T::Helpers
      abstract!

      PostAddressData = T.type_alias { T.any(PostAddress, T::Hash[Symbol, T.untyped]) }

      sig do
        abstract.params(
          index_base_name: String,
          index_settings: T::Hash[Symbol, T.untyped],
          index_mappings: T.nilable(T::Hash[String, T.untyped]),
          mapper_callable: T.nilable(T.proc.params(arg0: T.untyped).returns(T.untyped)),
        ).void
      end
      def initialize(index_base_name:, index_settings:, index_mappings:, mapper_callable:); end

      sig { returns(String) }
      def archived_alias
        "#{base_alias_name}.archive"
      end

      sig { returns(String) }
      def active_alias
        base_alias_name
      end

      sig { returns(String) }
      def new_alias
        "#{base_alias_name}.new"
      end

      sig { abstract.returns(String) }
      def read_alias_name; end

      sig { abstract.params(record: PostAddressData).returns(T::Hash[Symbol, T.untyped]) }
      def record_source(record); end

      sig { abstract.returns(String) }
      def base_alias_name; end

      sig do
        abstract.params(
          ensure_clean: T::Boolean,
          raise_errors: T::Boolean,
        ).void
      end
      def create_next_index(ensure_clean: false, raise_errors: false); end

      sig do
        abstract.params(
          raise_errors: T::Boolean,
        ).void
      end
      def switch_to_next_index(raise_errors: false); end

      sig do
        abstract.params(
          records: T.any(ActiveRecord::Relation, T::Array[PostAddressData]),
        ).returns(T.nilable(Response))
      end
      def save_records_backfill(records); end

      sig { abstract.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def search(query); end

      sig { abstract.params(id: T.any(String, Integer)).returns(T::Hash[String, T.untyped]) }
      def find(id); end

      sig { abstract.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def analyze(query); end

      sig { abstract.params(query: T::Hash[String, T.untyped]).returns(T::Hash[String, T.untyped]) }
      def term_vectors(query); end
    end
  end
end
