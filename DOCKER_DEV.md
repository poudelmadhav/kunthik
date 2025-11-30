# Docker Development Setup Guide

This guide helps you set up the kunthik project locally using Docker with proper permissions and development configurations.

## Prerequisites

- Docker Desktop for Mac (or Docker Engine + Docker Compose)
- Git
- Basic terminal knowledge

## Quick Start

### 1. Initial Setup

Run the setup script to configure your development environment:

```bash
./docker-setup.sh
```

This script will:
- Detect your user/group IDs for proper file permissions
- Create `.env.dev` from the example file
- Build Docker images with Ruby 2.4.3 and Node 10.24.1 (matching production)
- Create and start database and redis containers
- Setup the database (create, migrate, seed)
- Configure bash history preservation

### 2. Start the Application

```bash
docker-compose -f docker-compose.dev.yml up
```

Access the application at: **http://localhost:3000**

To run in the background (detached mode):
```bash
docker-compose -f docker-compose.dev.yml up -d
```

### 3. Stop the Application

```bash
docker-compose -f docker-compose.dev.yml down
```

## Common Commands

### Access Rails Console
```bash
docker-compose -f docker-compose.dev.yml exec web rails console
```

### Run Database Migrations
```bash
docker-compose -f docker-compose.dev.yml exec web rails db:migrate
```

### Run Tests
```bash
docker-compose -f docker-compose.dev.yml exec web rails test
```

### Access Bash Shell
```bash
docker-compose -f docker-compose.dev.yml exec web bash
```

### Install New Gems
```bash
# Add gem to Gemfile, then:
docker-compose -f docker-compose.dev.yml exec web bundle install
docker-compose -f docker-compose.dev.yml restart web
```

### Install New NPM/Yarn Packages
```bash
docker-compose -f docker-compose.dev.yml exec web yarn add <package-name>
docker-compose -f docker-compose.dev.yml restart webpacker
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.dev.yml logs -f

# Specific service
docker-compose -f docker-compose.dev.yml logs -f web
docker-compose -f docker-compose.dev.yml logs -f sidekiq
```

### Database Commands
```bash
# Create database
docker-compose -f docker-compose.dev.yml exec web rails db:create

# Drop database
docker-compose -f docker-compose.dev.yml exec web rails db:drop

# Reset database
docker-compose -f docker-compose.dev.yml exec web rails db:reset

# Access PostgreSQL directly
docker-compose -f docker-compose.dev.yml exec db psql -U postgres -d kunthik_development
```

### Rebuild Containers
```bash
# Rebuild after Dockerfile or dependency changes
docker-compose -f docker-compose.dev.yml build

# Force rebuild without cache
docker-compose -f docker-compose.dev.yml build --no-cache
```

### Clean Up
```bash
# Stop and remove containers (keeps volumes)
docker-compose -f docker-compose.dev.yml down

# Remove containers and volumes (DELETES DATABASE DATA)
docker-compose -f docker-compose.dev.yml down -v

# Remove all unused Docker resources
docker system prune -a
```

## Services

The development environment includes:

| Service | Container Name | Ports | Purpose |
|---------|---------------|-------|---------|
| **web** | kunthik_web_dev | 3000 | Rails application server |
| **webpacker** | kunthik_webpacker_dev | 3035 | Webpack development server |
| **db** | kunthik_db_dev | 5432 | PostgreSQL 11 database |
| **redis** | kunthik_redis_dev | 6379 | Redis for Sidekiq/caching |
| **sidekiq** | kunthik_sidekiq_dev | - | Background job processor |

## Features

### ✅ Proper Permissions
- Files created in containers have your host user/group ownership
- No permission issues when editing files locally
- USER_ID and GROUP_ID are automatically detected

### ✅ Bash History Preservation
- Your bash history is preserved in a Docker volume
- History persists across container restarts
- **NOT committed to git** (protected by .gitignore and .dockerignore)

### ✅ Development Optimizations
- Hot reloading with webpack-dev-server
- Fast file sync with cached volumes
- Separate volumes for node_modules and gems
- Spring disabled for consistent behavior

### ✅ Production Parity
- Ruby 2.4.3 (matches production)
- Node.js 10.24.1 (matches production)
- Yarn 1.22.21 (matches production)
- Same base image as production

## Environment Variables

Edit `.env.dev` to customize your local environment:

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/kunthik_development

# Redis
REDIS_URL=redis://redis:6379/1

# Add your service credentials
CLOUDINARY_URL=cloudinary://...
FACEBOOK_APP_ID=...
FACEBOOK_APP_SECRET=...
```

**Note:** Never commit `.env.dev` to git. It's already in `.gitignore`.

## Troubleshooting

### Port Already in Use
If port 3000 or 5432 is already in use:
```bash
# Find and stop the process using the port
lsof -ti:3000 | xargs kill -9  # For port 3000
lsof -ti:5432 | xargs kill -9  # For port 5432
```

### Permission Denied Errors
Rebuild with your current user ID:
```bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
docker-compose -f docker-compose.dev.yml build --build-arg USER_ID=$USER_ID --build-arg GROUP_ID=$GROUP_ID
```

### Database Connection Errors
Wait for the database to be fully ready:
```bash
docker-compose -f docker-compose.dev.yml up db
# Wait for "database system is ready to accept connections"
# Then start other services
```

### Stale PID Files
```bash
docker-compose -f docker-compose.dev.yml exec web rm -f tmp/pids/server.pid
docker-compose -f docker-compose.dev.yml restart web
```

### Bundle/Yarn Issues
```bash
# Reinstall dependencies
docker-compose -f docker-compose.dev.yml exec web bundle install
docker-compose -f docker-compose.dev.yml exec web yarn install
docker-compose -f docker-compose.dev.yml restart
```

## Running Individual Commands

You can run any Rails, Rake, or shell command:

```bash
# Generate a migration
docker-compose -f docker-compose.dev.yml exec web rails g migration AddFieldToModel

# Run a specific test
docker-compose -f docker-compose.dev.yml exec web rails test test/models/user_test.rb

# Execute a rake task
docker-compose -f docker-compose.dev.yml exec web rake sitemap:refresh

# Run a one-off command
docker-compose -f docker-compose.dev.yml run --rm web rails runner "puts User.count"
```

## Production vs Development

- **Production**: Uses `Dockerfile` with optimized build and security
- **Development**: Uses `Dockerfile.dev` with dev tools and proper permissions
- **Production Compose**: Not included (managed by deployment platform)
- **Development Compose**: `docker-compose.dev.yml` (this file)

## Need Help?

- Check logs: `docker-compose -f docker-compose.dev.yml logs -f`
- Inspect services: `docker-compose -f docker-compose.dev.yml ps`
- Restart everything: `docker-compose -f docker-compose.dev.yml restart`

For more information, see [DOCKER.md](DOCKER.md) for production setup details.
