# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem "rails"
# # The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
# gem "sprockets-rails"
# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"
# Use the Puma web server [https://github.com/puma/puma]
# gem "puma", "~> 5.0"
# # Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails"
# # Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"
# # Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails"
# # Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# # Use Redis adapter to run Action Cable in production
# # gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# # Reduces boot times through caching; required in config/boot.rb
# gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# gem "ejson-rails"

# source "https://pkgs.shopify.io/basic/gems/ruby" do
#   gem "monorail"
#   gem "kafka-client-ruby"
#   gem "shopify-cloud"
#   gem "shopify_metrics"
#   gem "opentelemetry-shopify"
#   gem "shopify-types"
#   gem "shopify_security_base"
#   # User authentication via Minerva. See https://github.com/Shopify/minerva-gem
#   gem "minerva"
# end

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop-shopify", require: false
end

group :development do
  # # Use console on exceptions pages [https://github.com/rails/web-console]
  # gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem "minitest-distributed"
  gem "minitest-silence", ">= 0.2.4", require: false
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  # gem "capybara"
  # gem "selenium-webdriver"
  # gem "webdrivers"
end
