# typed: false
# frozen_string_literal: true

module AtlasEngine
  class Schema < GraphQL::Schema
    extend LogHelper
    query(Types::QueryType)

    class << self
      def dump
        schema_path = Pathname.new(__dir__).join("schema.graphql")
        schema_path.write(to_definition)
        log_info("Updated GraphQL schema dump: #{schema_path}")
        true
      end

      def refresh
        log_info("Refreshed GraphQL schema types.")
        true
      end
    end
  end
end
