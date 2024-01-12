# frozen_string_literal: true

require_relative "lib/atlas_engine/version"

Gem::Specification.new do |spec|
  spec.name        = "atlas_engine"
  spec.version     = AtlasEngine::VERSION
  spec.authors     = ["Shopify"]
  spec.email       = ["developers@shopify.com"]
  spec.homepage    = "https://github.com/Shopify/atlas-engine"
  spec.summary     = "Global Address Validation API"
  spec.description = "The Atlas Engine is a rails engine that provides a GraphQL API for global address validation."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shopify/atlas-engine"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/atlas-engine/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency("annex_29")
  spec.add_dependency("elasticsearch-model")
  spec.add_dependency("elasticsearch-rails")
  spec.add_dependency("elastic-transport")
  spec.add_dependency("frozen_record")
  spec.add_dependency("graphiql-rails")
  spec.add_dependency("graphql")
  spec.add_dependency("htmlentities")
  spec.add_dependency("maintenance_tasks")
  spec.add_dependency("rails", ">= 7.0.7.2")
  spec.add_dependency("rubyzip")
  spec.add_dependency("sorbet-runtime")
  spec.add_dependency("state_machines-activerecord")
  spec.add_dependency("statsd-instrument")
  spec.add_dependency("worldwide")
end
