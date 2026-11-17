# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Rails 8.1 SaaS boilerplate template. It uses PostgreSQL 16, Redis 7, Sidekiq for background jobs, Devise for authentication, Tailwind CSS, Turbo/Stimulus, and Kamal for deployment.

## Development Commands

```bash
bin/dev                          # Start dev server (Rails + Tailwind watcher)
bin/setup                        # Full setup: install deps, copy .env files, prepare DB, start server
bin/setup --skip-server          # Setup without starting server
bin/setup --reset                # Setup and reset DB
bin/rails setup:copy_env         # Copy .env.*.template → .env.* files
bin/rails setup:rename_app       # Rename the application globally
```

`setup:rename_app` is how the template becomes a real project — it rewrites the module, DB, Docker and Kamal names in every form (Title, CamelCase, snake_case, SCREAMING_SNAKE). Don't hand-edit those names.

## Testing

```bash
bundle exec rspec                          # Full test suite
bundle exec rspec spec/models/user_spec.rb # Single file
bundle exec rspec spec/models/user_spec.rb:9 # Single test by line
bundle exec rspec --only-failures          # Re-run failures
bundle exec rspec spec/system              # System specs only (headless Chrome)
```

System specs (`spec/system/`, `type: :system`) run in headless Chrome via Selenium (`spec/support/capybara_config.rb`); Google Chrome must be installed, Selenium Manager fetches chromedriver. Failure screenshots go to `tmp/capybara` (uploaded by CI). `Capybara.enable_aria_label` is on, and Devise `sign_in` works in system specs. Tag a system spec `:mobile` to run it at 390×844 (separate named driver, so the size doesn't leak into desktop specs). Chrome's password manager and breach detection are disabled in the test browser (`CHROME_TEST_OPTIONS`) — its bubble outlives Capybara's reset and made later form sign-ins silently not submit. Keep them off. They don't run inside the Docker dev image (no Chrome there).

SimpleCov runs automatically with RSpec; coverage excludes bin, db, spec, config. Specs run in random order (`--seed N` to reproduce).

`app/assets/builds/` is not committed. The layout needs the compiled stylesheet, so on a fresh clone run `bin/rails tailwindcss:build` (or `bin/dev`) before specs — otherwise they fail with `Propshaft::MissingAssetError`. CI does this as its own step.

## Linting & Security

```bash
bin/rubocop                  # Lint (inherits rubocop-rails-suite, Ruby 3.4 target)
bin/brakeman --no-pager      # Rails security scan
bin/bundler-audit            # Gem vulnerability scan
bin/importmap audit          # JS dependency security scan
```

## Architecture

### Authentication & Authorization

- Devise with `user` / `admin` role enum on the `User` model
- `ApplicationController` enforces `authenticate_user!` globally
- Admin-only routes (`/sidekiq`, `/pghero`) guarded by `->(user) { user.admin? }`
- Devise sanitizer configured for `first_name` and `last_name`
- CSP nonce is stored in the session (`session[:csp_nonce]`), not `request.session.id` (blank on first visit) and not per-request (breaks Turbo-tracked importmap). Don't change it to either.
- Custom flash types: `:primary, :secondary, :success, :error, :warning, :danger, :info`

### Frontend

- Tailwind CSS v4 (`app/assets/tailwind/application.css`): a bare `border`/`border-t`/`border-b` defaults to `currentColor` (dark), so always pair it with a colour — the template uses `border-gray-200`.

### Background Jobs

- **Sidekiq** (concurrency via `SIDEKIQ_CONCURRENCY` env var, default 5) with queue priorities: `critical → default → mailers → maintenance`
- **Sidekiq-Scheduler** for recurring tasks defined in `config/scheduler/<env>.yml` (development and production configs provided)
- Job classes live in `app/sidekiq/` and `include Sidekiq::Job`
- **Active Job adapter is Sidekiq by default** (set explicitly in `config/environments/{development,production}.rb`; `test.rb` uses `:test`). So `perform_later`/`deliver_later` also go to Sidekiq; mail uses the `mailers` queue.
- **Solid Queue is kept but opt-in**: swap to the commented `:solid_queue` adapter lines in the env file + a `queue` DB (only production defines one) + `bin/jobs` or `SOLID_QUEUE_IN_PUMA`. It only affects Active Job — `app/sidekiq/` jobs and sidekiq-scheduler always need Redis/Sidekiq. Don't remove the Solid Queue gem/config.
- Production (Kamal): Sidekiq runs as the `job` role, Redis as the `redis` accessory (`config/deploy.yml`)

### Performance & Monitoring

- **Bullet** (N+1 detection) enabled in development
- **Rack Mini Profiler** available in development (optional require)
- **Scout APM** — enabled when `SCOUT_KEY` env var is set
- **PgHero** for PostgreSQL monitoring; query stats captured hourly and cleared weekly via Sidekiq jobs
- **Rollbar** for error tracking — enabled when `ROLLBAR_ACCESS_TOKEN` is set

### Testing Patterns

- **FactoryBot** syntax methods included globally (`create(:user)`)
- **Shoulda Matchers** for model validations/associations
- **Transactional fixtures** enabled — database is rolled back between tests
- **Faker** for test data generation

### Environment Variables

Copy templates before first run:
```bash
bin/rails setup:copy_env
```
`.env.development.template` covers: DB credentials, seed user credentials, Sidekiq Redis URL and concurrency, Scout APM key, Rollbar token. `.env.test.template` covers only DB credentials. `REDIS_CACHE_URL`/`REDIS_CABLE_URL` are intentionally kept for when cache/cable move to Redis — they're not wired up yet (dev uses memory cache and async cable). Don't remove them. Leaving optional values blank (Scout, Rollbar) disables those features cleanly — the initializers already handle it, so don't add fallback logic for missing keys.

### Docker

`docker-compose.yml` runs PostgreSQL 16 (with `pg_stat_statements`), Redis 7, Rails app, Sidekiq worker, and a Tailwind watcher (`css` service). Use `Dockerfile.dev` for development, `Dockerfile` for production.

### Deployment

Kamal is configured in `config/deploy.yml`. Production uses Sidekiq + Redis for jobs, and Solid Cable and Solid Cache (database-backed adapters). SSL is off by default (Rails generator default): to enable it, uncomment the Kamal `proxy` block (`ssl: true` + real `host`) and `assume_ssl`/`force_ssl` in `production.rb` together. The production image excludes the `development` and `test` gem groups.
