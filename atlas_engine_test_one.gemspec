require_relative "lib/atlas_engine_test_one/version"

Gem::Specification.new do |spec|
  spec.name        = "atlas_engine_test_one"
  spec.version     = AtlasEngineTestOne::VERSION
  spec.authors     = ["Roch Lefebvre"]
  spec.email       = ["roch.lefebvre@shopify.com"]
  spec.homepage    = "https://github.com/Shopify/atlas-engine-test-one"
  spec.summary     = "Summary of AtlasEngineTestOne."
  spec.description = "Description of AtlasEngineTestOne."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Shopify/atlas-engine-test-one"
  spec.metadata["changelog_uri"] = "https://github.com/Shopify/atlas-engine-test-one/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.0.7.2"
  spec.add_dependency "graphql"
  spec.add_dependency "graphiql-rails"
end
