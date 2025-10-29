source "https://rubygems.org"

gem "bootsnap", require: false
gem "importmap-rails"
gem "jbuilder"
gem "kamal", require: false
gem "propshaft"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.1"
gem "redis"
gem "stimulus-rails"
gem "thruster", require: false
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[windows jruby]

# Tailwind
gem "tailwindcss-rails", "~> 4.3"
gem "tailwindcss-ruby", "~> 4.1"

# BackgroundJob and Scheduling
gem "sidekiq"
gem "sidekiq-scheduler"

# Database and Performance Tracking
gem "pg", "~> 1.1"
gem "pghero"

# Authentication
gem "devise"

# Performance and Error Tracking
gem "rollbar"
gem "scout_apm"

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "dotenv-rails"

  # Code Quality & Linting
  gem "rubocop-rails-suite", require: false

  # Rspec
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", "~> 8.0.2"

  # Security
  gem "brakeman", require: false
  gem "bundler-audit", require: false

  # Performance
  gem "bullet"
end

group :development do
  gem "web-console"

  # Performance
  gem "rack-mini-profiler", require: false
end

group :test do
  gem "capybara"
  gem "rspec-sidekiq"
  gem "selenium-webdriver"
  gem "shoulda-matchers"
  gem "simplecov", require: false
end
