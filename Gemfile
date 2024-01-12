# frozen_string_literal: true

source "https://rubygems.org"

gemspec

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem "mysql2"

group :development, :test do
  gem "dotenv-rails", require: "dotenv/rails-now"
  # For loading the /graphiql assests
  gem "sprockets-rails"

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rubocop-shopify", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-sorbet", require: false
  gem "sorbet"
  gem "tapioca", require: false
  gem "factory_bot_rails"
end

group :development do
  gem "pry"
  gem "pry-byebug"
end

group :test do
  gem "minitest-distributed"
  gem "minitest-silence", ">= 0.2.4", require: false
  gem "mocha"
  gem "webmock"
  gem "minitest-focus"
  gem "minitest-suite"
end
