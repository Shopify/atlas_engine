# typed: false
# frozen_string_literal: true

require "atlas_engine/version"
require "atlas_engine/engine"
require "graphql"
require "graphiql/rails"
require "elastic-transport"
require "elasticsearch/model"
require "elasticsearch/rails"
require "worldwide"
require "state_machines-activerecord"
require "zip"
require "frozen_record"
require "annex_29"
require "maintenance_tasks"
require "htmlentities"
require "sorbet-runtime"
require "statsd-instrument"

module AtlasEngine
  # @!attribute elasticsearch_repository
  #   @scope class
  #
  #   The elasticsearch repository implementation that the es datastore will use.
  #
  #   @return [String] the class name of the elasticsearch repository implementation.
  mattr_accessor :elasticsearch_repository, default: "AtlasEngine::Elasticsearch::Repository"

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

  # @!attribute address_importer_additional_field_validations
  #   The Host application can add additional validations to the address importer
  #   by setting this attribute to a hash of the following format:
  #   {
  #     field_name: [Array of additional validation classes]
  #   }
  #
  #   example:
  #   AtlasEngine.address_importer_additional_field_validations = {
  #     city: [MyCustomCityValidator],
  #     province_code: [MyCustomProvinceValidator],
  #     zip: [MyCustomZipValidator],
  #   }
  mattr_accessor :address_importer_additional_field_validations, default: {}

  # @!attribute import_events_notifier
  #   The Host application can define its own notifier for import events by configuring
  #   AtlasEngine.address_importer_notifier = MyCustomNotifier
  mattr_accessor :address_importer_notifier, default: "AtlasEngine::AddressImporter::ImportEventsNotifier::Notifier"
end
