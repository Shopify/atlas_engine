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

  # @!attribute log_base
  #
  #   The parent module for logging. Must be a module that implements the
  #   `log_message` method.
  #
  #   @return [String] the name of the parent module for loggers.
  mattr_accessor :log_base, default: "AtlasEngine::LogBase"

  # @!attribute validation_eligibility
  #
  #   The module for validation eligibility. Must be a module that implements the
  #   `validation_enabled(address)` method which returns a boolean that indicates if the provided
  #   address is eligible for validation.
  #
  #   @return [String] the name of the module for validation elibility.
  mattr_accessor :validation_eligibility, default: "AtlasEngine::Services::ValidationEligibility"
end
