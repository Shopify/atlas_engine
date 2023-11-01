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
gem "sorbet-static-and-runtime"


# # Use Redis adapter to run Action Cable in production
# # gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop-shopify", require: false
  gem "graphiql-rails"
  gem 'tapioca', require: false
end

group :development do
  # # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "pry"
end

group :test do
  gem "minitest-distributed"
  gem "minitest-silence", ">= 0.2.4", require: false
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem "capybara"
  # gem "selenium-webdriver"
  # gem "webdrivers"
end

gem "maintenance_tasks", "~> 2.3"
