module AtlasEngineTestOne
  module Types
    class BaseInputObject < GraphQL::Schema::InputObject
      argument_class Types::BaseArgument
    end
  end
end
