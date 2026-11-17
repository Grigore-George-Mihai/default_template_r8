## Monolith Template

This repository serves as a default template for a monolithic Ruby on Rails (RoR) application. It includes a pre-configured setup with essential gems and tools to streamline development.

### Table of Contents

- [Installation](#installation)
- [Setup](#setup)
- [Gems](#gems)
- [Background Jobs](#background-jobs)
- [Docker Setup](#docker-setup)
- [Contact](#contact)

### Installation
Clone the repository
```bash
git clone https://github.com/Grigore-George-Mihai/default_template_r8
```

---

### Setup
**1. Rename the Application**

This will update the app name everywhere it appears (module name, titles, DB names, cable prefixes, Docker volumes, etc.).
```bash
bin/rails setup:rename_app
```

**2. Create Environment Files**

Copy environment template files into `.env.development` and `.env.test`.
```bash
bin/rails setup:copy_env
```
Then open each file and update values as needed:
- Database credentials (`POSTGRES_USER`, `POSTGRES_PASSWORD`)
- Any other environment-specific variables

**3. Set Up the Database**
```bash
bin/rails db:prepare   # Creates and migrates the database
bin/rails db:seed      # Loads seed data
```

**4. Optional Integrations**
- [Devise](https://github.com/heartcombo/devise) — Adjust configuration in `config/initializers/devise.rb` if needed.
- [Scout APM](https://github.com/scoutapp/scout_apm_ruby) — Add your SCOUT_KEY value in .env.development (or the appropriate .env file) to enable. If left blank, ScoutAPM stays disabled.
- [Rollbar](https://github.com/rollbar/rollbar-gem) — Add your ROLLBAR_ACCESS_TOKEN value in .env.development (or the appropriate .env file) to enable. If left blank, Rollbar stays disabled.
- [PgHero](https://github.com/ankane/pghero) - Add `shared_preload_libraries = 'pg_stat_statements'` to `postgresql.conf` and restart the database. if left blank, PgHero stays disabled.

 ✅ You’re now ready to start development!

---

### Gems

**Database and Monitoring**
- [Pg](https://github.com/ged/ruby-pg): PostgreSQL driver for Ruby, providing fast and efficient database connectivity.
- [PgHero](https://github.com/ankane/pghero): A tool for monitoring PostgreSQL database performance, including query insights, index suggestions, and table size analysis.
- [Pagy](https://github.com/ddnexus/pagy): Fast and lightweight pagination library. Use `pagy(:offset, collection)` in controllers; render with `@pagy.series_nav` in views.

**Authentication**
- [Devise](https://github.com/heartcombo/devise): Flexible authentication solution for Rails based on Warden.

**Background Processing**
- [Sidekiq](https://github.com/mperham/sidekiq): Efficient background processing for Ruby applications.
- [Sidekiq-Scheduler](https://github.com/moove-it/sidekiq-scheduler): Extends Sidekiq to support scheduled and recurring jobs using a simple configuration.
- [Redis](https://github.com/redis/redis-rb): In-memory data structure store used by Sidekiq for managing background job queues, scheduling, and retries.
- [Solid Queue](https://github.com/rails/solid_queue): Database-backed Active Job backend, installed but opt-in. See [Switching to Solid Queue](#switching-to-solid-queue).


**Performance Monitoring**
- [Scout APM](https://github.com/scoutapp/scout_apm_ruby): Application monitoring tool.
- [Bullet](https://github.com/flyerhzm/bullet): Detects N+1 queries and unused eager loading.
- [Rack Mini Profiler](https://github.com/MiniProfiler/rack-mini-profiler): Performance profiling tool.

**Error Tracking**
- [Rollbar](https://github.com/rollbar/rollbar-gem): Real-time error tracking and reporting.

**Code Quality & Linting**
- [Rubocop Rails Suite](https://github.com/Grigore-George-Mihai/rubocop-rails-suite): A custom suite that bundles Rubocop with various plugins for Rails projects.

**Testing**
- [Factory Bot Rails](https://github.com/thoughtbot/factory_bot_rails): Provides fixtures replacement with a straightforward definition syntax.
- [Faker](https://github.com/faker-ruby/faker): A library for generating fake data.
- [RSpec Rails](https://github.com/rspec/rspec-rails): Testing framework for Rails.
- [Shoulda Matchers](https://github.com/thoughtbot/shoulda-matchers): Simplifies testing Rails applications with RSpec.
- [SimpleCov](https://github.com/simplecov-ruby/simplecov): Code coverage analysis tool.
- [Rspec-Sidekiq](https://github.com/philostler/rspec-sidekiq): Testing framework for Sidekiq jobs.

**Security**
- [Brakeman](https://github.com/presidentbeef/brakeman): Static analysis tool for finding security vulnerabilities in Rails applications.
- [Bundler Audit](https://github.com/rubysec/bundler-audit): Scans your Gemfile for known vulnerabilities.

**Development Utilities**
- [Letter Opener Web](https://github.com/fgrehm/letter_opener_web): Preview sent emails in the browser during development at `/letter_opener`.

**Environment Management**
- [Dotenv Rails](https://github.com/bkeepers/dotenv): Loads environment variables from `.env`.

---

### Background Jobs
**Sidekiq is the default** in every environment except test (which uses the in-memory `:test` adapter).

- Sidekiq-native jobs live in `app/sidekiq/` and `include Sidekiq::Job`; recurring ones are scheduled in `config/scheduler/<env>.yml` (sidekiq-scheduler).
- Active Job (`deliver_later`, `ApplicationJob` subclasses, Active Storage, Turbo broadcasts) is also routed to Sidekiq. Mail goes to the `mailers` queue.
- Run a worker locally with `bin/dev` (Procfile.dev starts `bundle exec sidekiq`) or `docker-compose up`.
- In production, Kamal runs Sidekiq as the `job` role and Redis as the `redis` accessory (`config/deploy.yml`). Boot the accessory once with `bin/kamal accessory boot redis`.

#### Switching to Solid Queue
Solid Queue is installed but dormant. To route **Active Job** through it instead of Sidekiq:

1. In `config/environments/development.rb` and/or `production.rb`, replace `config.active_job.queue_adapter = :sidekiq` with the commented Solid Queue lines right below it.
2. Make sure a `queue` database exists. Production already defines one in `config/database.yml`; for development add the same structure:
   ```yaml
   development:
     primary:
       <<: *default
       database: default_template_r8_development
     queue:
       <<: *default
       database: default_template_r8_development_queue
       migrations_paths: db/queue_migrate
   ```
   then run `bin/rails db:prepare` (loads `db/queue_schema.rb`).
3. Run the supervisor: `bin/jobs` as its own process/Kamal role, or `SOLID_QUEUE_IN_PUMA=true` to run it inside Puma.
4. Define recurring Active Job tasks in `config/recurring.yml`.

> **Limitation:** the adapter only affects Active Job. Classes in `app/sidekiq/` (including the PgHero jobs) and the sidekiq-scheduler schedule always need Redis and a Sidekiq process. To drop Sidekiq entirely, rewrite those jobs as `ApplicationJob` subclasses and move their schedule to `config/recurring.yml`.

---

### Docker Setup
If you prefer to run the application inside a Docker container, follow these steps:

1. **Build the Docker image:**
```bash
docker-compose build
```

2. **Start the Application and services:**
```bash
docker-compose up
```

3. **Stop the Application:**
```bash
docker-compose down
```

4. **Remove named Volumes:**
```bash
docker-compose down --volumes
```

---

### Contact
For questions or further information, feel free to reach out via [LinkedIn](https://www.linkedin.com/in/grigore-george-mihai-73981b86/).
