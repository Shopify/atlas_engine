# frozen_string_literal: true

source "https://rubygems.org"

gemspec

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails"
# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"
# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"
# for the dummy app
gem "sqlite3"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 6.4"

gem "elastic-transport"
gem 'worldwide'
gem 'sorbet-runtime'
gem "state_machines-activerecord"

group :development, :test do
  gem 'dotenv-rails', require: 'dotenv/rails-now'

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop-shopify", require: false
  gem "graphiql-rails"
  gem 'sorbet'
  gem 'tapioca', require: false
end

group :development do
  gem "pry"
end

group :test do
  gem "minitest-distributed"
  gem "minitest-silence", ">= 0.2.4", require: false
  gem 'mocha'
  gem 'webmock'
  gem 'minitest-focus'
  gem 'minitest-suite'
end

gem "maintenance_tasks", "~> 2.3"
