# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Elasticsearch
    module RepositoryInterface
      extend T::Sig
      extend T::Helpers
      abstract!

      PostAddressData = T.type_alias { T.any(PostAddress, T::Hash[Symbol, T.untyped]) }

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

      sig { abstract.returns(ClientInterface) }
      def client; end

      sig { abstract.returns(String) }
      def read_alias_name; end

      sig { abstract.params(record: PostAddressData).returns(T::Hash[Symbol, T.untyped]) }
      def record_source(record); end

      sig { abstract.returns(T.nilable(T::Hash[String, T.untyped])) }
      def index_mappings; end

      sig { abstract.returns(T::Hash[Symbol, T.untyped]) }
      def index_settings; end

      sig { abstract.returns(String) }
      def base_alias_name; end

      sig do
        abstract.params(
          ensure_clean: T::Boolean,
          raise_errors: T::Boolean
        ).void
      end
      def create_next_index(ensure_clean: false, raise_errors: false); end

      sig do
        abstract.params(
          raise_errors: T::Boolean
        ).void
      end
      def switch_to_next_index(raise_errors: false); end

      sig do
        abstract.params(
          records: T.any(ActiveRecord::Relation, T::Array[PostAddressData])
        ).returns(T.nilable(Response))
      end
      def save_records_backfill(records); end
    end
  end
end
