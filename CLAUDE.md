# Claude Guide for Rails Starter Template

This repository is based on the Rails Starter Template - a modern Rails 8.1.1 application configured with production-ready tooling and best practices.

## Philosophy: Clean, Pure Rails

This template is **opinionated by design**:

- **SQLite for everything** - No PostgreSQL, no MySQL. SQLite in development, test, AND production.
- **Solid Queue/Cache/Cable** - No Redis, no external services. Keep it simple.
- **Kamal deployments** - Docker-based, zero-downtime, the Rails 8 way.
- **Minimal 3rd party integrations** - Prefer Rails built-ins, avoid external dependencies.
- **Pure Rails approach** - Use the framework, don't fight it.

**Don't deviate from this stack.** It's designed for maintainability, simplicity, and operational ease.

### Why This Stack?

- **Operational Simplicity** - No Redis to manage, no PostgreSQL to configure. Deploy anywhere Docker runs.
- **Lower Costs** - No external service bills. Your database, cache, and queue are files on disk.
- **Faster Deployments** - Fewer moving parts means faster CI/CD and simpler infrastructure.
- **Easier Debugging** - Everything is in one place. No distributed system complexity.
- **Production Ready** - Rails 8 made SQLite production-grade. Trust the framework.

This isn't a prototype stack. It's **designed for production**.

## Repository Structure

```
rails-starter/
├── app/                    # Application code
│   ├── controllers/        # Controllers
│   ├── models/            # ActiveRecord models
│   ├── views/             # ERB templates
│   ├── helpers/           # View helpers
│   ├── jobs/              # Background jobs (Solid Queue)
│   ├── mailers/           # Email mailers
│   ├── assets/            # CSS/SCSS assets (Tailwind CSS)
│   └── javascript/        # JavaScript (Stimulus controllers)
├── config/                # Configuration files
│   ├── environments/      # Environment-specific configs
│   ├── initializers/      # Rails initializers
│   ├── database.yml       # SQLite3 configuration
│   ├── routes.rb          # URL routing
│   ├── deploy.yml         # Kamal deployment config
│   └── importmap.rb       # JavaScript import maps
├── db/                    # Database schema and migrations
├── test/                  # Minitest test suite
│   ├── controllers/       # Controller tests
│   ├── models/           # Model tests
│   ├── system/           # System tests (Capybara)
│   └── integration/      # Integration tests
├── public/               # Static assets
├── bin/                  # Executable scripts
│   ├── setup             # Initial setup script
│   ├── dev               # Development server (Foreman)
│   └── ci                # Local CI pipeline
├── .github/              # GitHub Actions workflows
├── .kamal/               # Kamal deployment artifacts
└── Dockerfile            # Multi-stage production image
```

## Technology Stack

### Core Framework
- **Ruby**: 3.2.9
- **Rails**: 8.1.1
- **Database**: SQLite3 (development, test, production)
  - Separate DBs: primary, cache, queue, cable

### Frontend
- **CSS Framework**: Tailwind CSS (with automatic rebuild)
- **JavaScript**:
  - **Turbo**: SPA-like page navigation
  - **Stimulus**: Lightweight JS framework
  - **Import Maps**: ESM modules without bundling
- **Asset Pipeline**: Propshaft (modern replacement for Sprockets)

### Production Infrastructure (No External Services)
- **Web Server**: Puma (3 threads by default)
- **HTTP Proxy**: Thruster (asset caching, compression, X-Sendfile)
- **Background Jobs**: Solid Queue (SQLite-backed) - **No Redis, No Sidekiq**
- **Caching**: Solid Cache (SQLite-backed) - **No Redis, No Memcached**
- **WebSockets**: Solid Cable (SQLite-backed) - **No Redis, No ActionCable with Redis**
- **Deployment**: Kamal (Docker-based, zero-downtime) - **The only way**

**All infrastructure uses SQLite. No external services required.**

### Testing & Quality
- **Test Framework**: Minitest (< 6.0)
- **System Tests**: Capybara + Selenium WebDriver (headless Chrome)
- **Linting**: RuboCop with Rails Omakase style
- **Security Scanning**:
  - Brakeman (Rails vulnerabilities)
  - Bundler-audit (gem vulnerabilities)
  - Importmap audit (JS dependencies)

## Development Workflow (MANDATORY)

This template enforces a **test-driven, early-commit workflow**:

### The Golden Rule: Every Commit Must Have a Test

1. **Write the test first** - Before implementing any feature or fix
2. **Watch it fail** - Confirm the test catches the issue
3. **Write the implementation** - Make the test pass
4. **Run `bin/ci`** - **ALWAYS** before committing
5. **Commit early, commit often** - Small, focused commits with passing tests

### Commit Workflow (Required Steps)

```bash
# 1. Write your test
# test/models/user_test.rb

# 2. Run the test (should fail)
rails test test/models/user_test.rb

# 3. Implement the feature
# app/models/user.rb

# 4. Run the test (should pass)
rails test test/models/user_test.rb

# 5. Run full CI pipeline (REQUIRED)
bin/ci

# 6. If CI passes, commit
git add .
git commit -m "Add user email validation"

# 7. If CI fails, fix and repeat from step 4
```

### CI Requirements

- **`bin/ci` must pass** before every commit
- No exceptions for "quick fixes"
- No commits without tests
- No skipping linting or security checks

**If `bin/ci` fails, your code is not ready to commit.**

### Commit Message Guidelines

- Use conventional commit format: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Be specific: "Add user email validation" not "Update user model"
- Reference tests: "Add user authentication (test: test/models/user_test.rb)"

### Why This Workflow?

- **Prevents regressions** - Every change is verified
- **Maintains quality** - No broken code in git history
- **Fast debugging** - Small commits are easy to bisect
- **Confidence** - You know it works before pushing

### Pre-commit Hook (Automatic Enforcement)

A pre-commit hook is installed automatically by `bin/setup` that runs `bin/ci` before every commit:

- **Located**: `.githooks/pre-commit`
- **Installed by**: `bin/setup` (configures `git config core.hooksPath .githooks`)
- **What it does**: Runs full CI pipeline (linting, tests, security scans)
- **On failure**: Commit is blocked until issues are fixed
- **Bypass** (NOT RECOMMENDED): `git commit --no-verify`

This hook ensures you can't accidentally commit code that doesn't pass CI.

## Common Development Tasks

### Getting Started
```bash
# Initial setup (idempotent)
bin/setup

# Start development server (Rails + Tailwind watcher)
bin/dev

# Run local CI pipeline
bin/ci
```

### Testing
```bash
# Run all tests
rails test

# Run system tests
rails test:system

# Run specific test file
rails test test/models/user_test.rb

# Run tests in parallel (configured by default)
rails test
```

### Database Operations
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database (drop, create, migrate, seed)
rails db:reset

# Seed database
rails db:seed
```

### Code Quality
```bash
# Run RuboCop linter
rubocop

# Auto-fix RuboCop violations
rubocop -a

# Security scanning
brakeman -q
bundle audit check --update
bin/importmap audit
```

### Deployment (Kamal)
```bash
# First-time setup
kamal setup

# Deploy application
kamal deploy

# Check deployment status
kamal app logs
```

## Conventions & Best Practices

### Coding Standards
- Follow **Rails Omakase** conventions (configured in `.rubocop.yml`)
- Use **RuboCop** for code linting (runs in CI)
- Write tests for all new features (Minitest)
- Keep controllers thin, models fat
- Use concerns for shared behavior

### Database (SQLite Only)
- **SQLite3 for ALL environments** - Development, test, production
- **No PostgreSQL, No MySQL** - Stick with SQLite
- **Production**: Separate SQLite databases for cache, queue, and cable
- Always create migrations for schema changes
- Run `rails db:migrate` before running tests
- SQLite is powerful enough for most applications - don't overcomplicate

### Frontend
- **Tailwind CSS**: Use utility classes, avoid custom CSS when possible
- **Turbo**: Default for all navigation (SPA-like experience)
- **Stimulus**: Use for interactive components
- **Import Maps**: Add JS packages via `bin/importmap pin <package>`

### Testing (Required for Every Commit)
- **Every commit needs a test** - No exceptions
- **Write tests first** - TDD approach
- **Controllers**: Test HTTP responses and business logic
- **Models**: Test validations, associations, and methods
- **System Tests**: Test critical user flows end-to-end
- **Parallel Tests**: Tests run in parallel by default (see `test_helper.rb`)

### Git Workflow (Mandatory Process)
- **ALWAYS run `bin/ci` before every commit** - Non-negotiable
- Work on feature branches (never commit directly to main)
- Commit early and often (small, focused commits)
- Every commit must have a passing test
- Follow conventional commit format (`feat:`, `fix:`, `refactor:`, etc.)
- CI must pass before merging to main
- If `bin/ci` fails, fix before committing

### Security
- Review Brakeman warnings before deploying
- Keep gems updated (`bundle update`)
- Audit JavaScript dependencies (`bin/importmap audit`)
- Use environment variables for secrets (not committed)

## File Locations & Patterns

### Adding New Features

**Authentication (Rails 8 Built-in):**
```bash
rails generate authentication
rails db:migrate
```

**Model:**
```bash
rails generate model User name:string email:string
rails db:migrate
```

**Controller:**
```bash
rails generate controller Users index show
```

**Background Job:**
```bash
rails generate job ProcessUpload
```

**Mailer:**
```bash
rails generate mailer UserMailer welcome
```

### Key Configuration Files

- **Routes**: `config/routes.rb`
- **Database**: `config/database.yml`
- **Environment Variables**: `.env` (not committed, create locally)
- **Deployment**: `config/deploy.yml` (Kamal)
- **Asset Pipeline**: `config/importmap.rb` (JavaScript)
- **Tailwind Config**: `config/tailwind.config.js`

### Important Initializers

- **Content Security Policy**: `config/initializers/content_security_policy.rb`
- **Permissions Policy**: `config/initializers/permissions_policy.rb`
- **Solid Queue/Cache/Cable**: Configured in `config/environments/production.rb`

## CI/CD Pipeline

### GitHub Actions (`.github/workflows/ci.yml`)
Runs on every PR and push to main:
1. **scan_ruby**: Brakeman + Bundler-audit
2. **scan_js**: Importmap audit
3. **lint**: RuboCop
4. **test**: Minitest suite
5. **system-test**: Capybara system tests

### Local CI (`bin/ci`)
Run before committing:
1. Setup dependencies
2. Lint with RuboCop
3. Security scanning
4. Run all tests
5. Validate database seed

## Starter Template Characteristics

This is an **opinionated starter template** designed to be forked for new Rails applications.

### What's Included
✅ Modern Rails 8.1.1 with Ruby 3.2.9
✅ SQLite for all environments (dev, test, production)
✅ Solid Queue/Cache/Cable (no external services)
✅ Tailwind CSS + Turbo + Stimulus
✅ Kamal deployment configuration
✅ Comprehensive CI/CD pipeline (GitHub Actions + `bin/ci`)
✅ Security scanning automation (Brakeman, Bundler-audit)
✅ System tests with Capybara
✅ RuboCop with Rails Omakase style
✅ PWA support ready
✅ Landing page example

### What's NOT Included (Add as Needed)
❌ Authentication system (use `rails generate authentication`)
❌ Domain models (build your own)
❌ Authorization (add Pundit, CanCanCan, or custom)
❌ Admin interface (add Rails Admin, ActiveAdmin, or custom)
❌ API versioning (add when needed)

### What You Should NOT Add
🚫 PostgreSQL or MySQL (stick with SQLite)
🚫 Redis or Memcached (use Solid Queue/Cache/Cable)
🚫 Alternative deployment tools (Kamal is the standard)
🚫 Complex build pipelines (Import Maps are enough)
🚫 Unnecessary 3rd party services

**Philosophy**: Start lean, stay pure Rails, add only what you truly need.

## Working with Forked Repositories

When working with a repository forked from this template:

1. **Read the README**: Check for project-specific setup instructions
2. **Check `config/routes.rb`**: Understand available endpoints
3. **Review Models**: Look in `app/models/` for domain objects
4. **Check Migrations**: `db/schema.rb` shows current database structure
5. **Environment Variables**: Ask about required `.env` variables
6. **Run Tests First**: Ensure existing tests pass before making changes

## Common Questions

**Q: Why SQLite instead of PostgreSQL?**
A: Simplicity. SQLite is powerful, requires no external services, and scales further than most think. Rails 8 made it production-ready. Don't switch unless you have a specific, measured need.

**Q: Can I use PostgreSQL/MySQL instead?**
A: No. This template is opinionated. Stick with SQLite. It reduces operational complexity and keeps deployments simple.

**Q: Why no Redis?**
A: Solid Queue/Cache/Cable use SQLite. No external services means simpler deployments, fewer failure points, and lower costs. Redis is overkill for most apps.

**Q: How do I add authentication?**
A: Use the built-in Rails 8 authentication generator: `rails generate authentication`. This creates a lightweight, Rails-native auth system. Alternatively, use Devise or Rodauth for more features, or build custom auth.

**Q: Why Minitest < 6?**
A: Version constraint added for compatibility (see `Gemfile`).

**Q: How do I add a new JavaScript package?**
A: Use `bin/importmap pin <package>` (e.g., `bin/importmap pin chart.js`). Keep JavaScript minimal.

**Q: How do I deploy with Kamal?**
A: Configure `config/deploy.yml`, ensure Docker is installed on target server, run `kamal setup` then `kamal deploy`. Kamal is the only supported deployment method.

**Q: Do I really need to run `bin/ci` before every commit?**
A: **Yes.** Non-negotiable. It prevents broken code from entering the repository and maintains quality standards.

**Q: Can I skip writing tests for small changes?**
A: **No.** Every commit needs a test. "Small changes" cause bugs too. Write the test.

## Tips for Claude

### Mandatory Practices
- **ALWAYS run `bin/ci` before every commit** - This is non-negotiable
- **Write tests first** - Every feature, every fix, every change
- **Commit early and often** - Small, focused commits with passing tests
- Every commit must include a test that verifies the change

### Development Best Practices
- Always run `bin/setup` after cloning
- Use `bin/dev` for development (never `rails s`)
- Check existing tests for patterns before writing new ones
- Follow Rails Omakase conventions (don't fight the framework)
- Keep Tailwind CSS utility classes in views (avoid custom CSS)
- Use Turbo for dynamic updates (avoid full page reloads)
- Add Stimulus controllers for interactive components
- Write system tests for critical user journeys
- Keep controllers RESTful when possible
- Use concerns for shared model/controller behavior

### Tech Stack Enforcement
- **Never suggest switching to PostgreSQL** - SQLite is the choice
- **Never suggest adding Redis** - Solid Queue/Cache/Cable only
- **Never suggest alternative deployment methods** - Kamal only
- Minimize 3rd party gems - prefer Rails built-ins
- Keep the stack pure and simple

### Quality Gates
- If `bin/ci` fails, **do not commit**
- If tests are missing, **write them first**
- If RuboCop complains, **fix it**
- If Brakeman warns, **address it**
- No shortcuts, no exceptions

---

**This template is opinionated by design.** The constraints exist to maintain simplicity, quality, and operational ease. Stick with the stack, follow the workflow, and you'll build maintainable Rails applications.
