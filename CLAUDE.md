# Claude Guide for Rails Starter Template

This repository is based on the Rails Starter Template - a modern Rails 8.1.1 application configured with production-ready tooling and best practices.

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

### Production Infrastructure
- **Web Server**: Puma (3 threads by default)
- **HTTP Proxy**: Thruster (asset caching, compression, X-Sendfile)
- **Background Jobs**: Solid Queue (SQLite-backed)
- **Caching**: Solid Cache (SQLite-backed)
- **WebSockets**: Solid Cable (SQLite-backed)
- **Deployment**: Kamal (Docker-based, zero-downtime)

### Testing & Quality
- **Test Framework**: Minitest (< 6.0)
- **System Tests**: Capybara + Selenium WebDriver (headless Chrome)
- **Linting**: RuboCop with Rails Omakase style
- **Security Scanning**:
  - Brakeman (Rails vulnerabilities)
  - Bundler-audit (gem vulnerabilities)
  - Importmap audit (JS dependencies)

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

### Database
- **Default**: SQLite3 for all environments
- **Production**: Separate SQLite databases for cache, queue, and cable
- Always create migrations for schema changes
- Use `rails db:migrate` before running tests

### Frontend
- **Tailwind CSS**: Use utility classes, avoid custom CSS when possible
- **Turbo**: Default for all navigation (SPA-like experience)
- **Stimulus**: Use for interactive components
- **Import Maps**: Add JS packages via `bin/importmap pin <package>`

### Testing
- **Controllers**: Test HTTP responses and business logic
- **Models**: Test validations, associations, and methods
- **System Tests**: Test critical user flows end-to-end
- **Parallel Tests**: Tests run in parallel by default (see `test_helper.rb`)

### Git Workflow
- Work on feature branches
- Run `bin/ci` before committing
- CI must pass before merging
- Follow conventional commit messages

### Security
- Review Brakeman warnings before deploying
- Keep gems updated (`bundle update`)
- Audit JavaScript dependencies (`bin/importmap audit`)
- Use environment variables for secrets (not committed)

## File Locations & Patterns

### Adding New Features

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

This is a **generic starter template** designed to be forked. It includes:

### What's Included
✅ Modern Rails 8 setup with Tailwind CSS
✅ Production-ready deployment (Kamal + Docker)
✅ Comprehensive CI/CD pipeline
✅ Security scanning automation
✅ PWA support (manifest, service worker)
✅ Background jobs, caching, WebSockets (Solid*)
✅ System tests with Capybara
✅ Landing page example

### What's NOT Included (By Design)
❌ Authentication system (add Devise, Rodauth, or custom)
❌ Domain models (build your own)
❌ Authorization (add Pundit, CanCanCan, or custom)
❌ Admin interface (add Rails Admin, ActiveAdmin, or custom)
❌ API versioning (add when needed)
❌ External services (Redis, PostgreSQL, etc.)

**Philosophy**: Start lean, add what you need.

## Working with Forked Repositories

When working with a repository forked from this template:

1. **Read the README**: Check for project-specific setup instructions
2. **Check `config/routes.rb`**: Understand available endpoints
3. **Review Models**: Look in `app/models/` for domain objects
4. **Check Migrations**: `db/schema.rb` shows current database structure
5. **Environment Variables**: Ask about required `.env` variables
6. **Run Tests First**: Ensure existing tests pass before making changes

## Common Questions

**Q: How do I switch from SQLite to PostgreSQL?**
A: Update `Gemfile` (swap `sqlite3` for `pg`), modify `config/database.yml`, update `Dockerfile` to include libpq-dev.

**Q: How do I add authentication?**
A: Add Devise (`gem 'devise'`), run `rails generate devise:install`, then `rails generate devise User`.

**Q: Why Minitest < 6?**
A: Version constraint added for compatibility (see `Gemfile`).

**Q: How do I add a new JavaScript package?**
A: Use `bin/importmap pin <package>` (e.g., `bin/importmap pin chart.js`).

**Q: How do I deploy?**
A: Configure `config/deploy.yml`, ensure Docker is installed on target server, run `kamal setup` then `kamal deploy`.

**Q: Can I use Redis instead of Solid Queue/Cache/Cable?**
A: Yes, uncomment Redis configuration in `config/environments/production.rb` and update `config/cable.yml`, `config/cache.yml`.

## Tips for Claude

- Always run `bin/setup` after cloning
- Use `bin/dev` for development (not `rails s`)
- Run `bin/ci` before committing changes
- Check existing tests for patterns before writing new ones
- Follow Rails conventions (don't fight the framework)
- Keep Tailwind CSS utility classes in views (avoid custom CSS)
- Use Turbo for dynamic updates (avoid full page reloads)
- Add Stimulus controllers for interactive components
- Write system tests for critical user journeys
- Keep controllers RESTful when possible
- Use concerns for shared model/controller behavior

---

**This template is designed to be adapted.** Remove what you don't need, add what you do. The goal is to start with solid foundations while maintaining flexibility for your specific product requirements.
