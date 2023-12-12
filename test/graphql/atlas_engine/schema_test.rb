# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  class SchemaTest < ActiveSupport::TestCase
    setup do
      file_schema.write("") unless file_schema.exist?
    end

    test "check if checked in GraphqlApi::Schema is out of date" do
      current_definition = Schema.to_definition
      previous_definition = file_schema.read

      assert_equal(
        current_definition,
        previous_definition,
        <<~MESSAGE.squish,
          The current schema is out of date.
          Update the schema with `AtlasEngine::Schema.dump`.
        MESSAGE
      )
    end

    private

    def file_schema
      @file_schema ||= AtlasEngine::Engine.root.join("app/graphql/atlas_engine/schema.graphql")
    end
  end
end
