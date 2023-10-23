require "atlas_engine/version"
require "atlas_engine/engine"
require "graphql"
require "graphiql/rails"

module AtlasEngine

  # @!attribute parent_controller
  #   @scope class
  #
  #   The parent controller all web UI controllers will inherit from.
  #   Must be a class that inherits from `ActionController::Base`.
  #   Defaults to `"ActionController::Base"`
  #
  #   @return [String] the name of the parent controller for web UI.
  mattr_accessor :parent_controller, default: "ActionController::Base"
end
