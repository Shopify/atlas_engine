# typed: false
# frozen_string_literal: true

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"

require "rails/test_help"
require "webmock/minitest"
require "mocha/minitest"
require "minitest/focus"
require "minitest/suite"
require "minitest/mock"
require "pry"
require_relative "helpers/atlas_engine/mocha/typed"

ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
ActiveRecord::Migrator.migrations_paths << File.expand_path("../db/migrate", __dir__)

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures(:all)
end

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods
    include AtlasEngine::Mocha::Typed
  end
end
