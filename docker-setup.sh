#!/bin/bash
# Docker Development Setup Script for kunthik

set -e

echo "🚀 Setting up kunthik Docker development environment..."

# Detect user and group IDs
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

echo "📋 Detected User ID: $USER_ID, Group ID: $GROUP_ID"

# Create .env.dev file if it doesn't exist
if [ ! -f .env.dev ]; then
    echo "📝 Creating .env.dev file..."
    cp .env.dev.example .env.dev
    sed -i.bak "s/USER_ID=1000/USER_ID=$USER_ID/" .env.dev
    sed -i.bak "s/GROUP_ID=1000/GROUP_ID=$GROUP_ID/" .env.dev
    rm .env.dev.bak 2>/dev/null || true
    echo "✅ .env.dev created. Please review and update with your credentials."
else
    echo "✅ .env.dev already exists"
fi

# Create necessary directories with proper permissions
echo "📁 Creating necessary directories..."
mkdir -p log tmp tmp/pids tmp/cache tmp/sockets public/uploads storage

# Update .gitignore to exclude bash history
echo "🔒 Ensuring bash history is not tracked by git..."
if ! grep -q ".bash_history" .gitignore 2>/dev/null; then
    cat >> .gitignore << 'EOF'

# Docker bash history (do not commit)
.bash_history
**/.bash_history
**/bash_history
EOF
    echo "✅ Updated .gitignore to exclude bash history"
else
    echo "✅ .gitignore already excludes bash history"
fi

# Build the development images
echo "🔨 Building Docker images..."
docker-compose -f docker-compose.dev.yml build --build-arg USER_ID=$USER_ID --build-arg GROUP_ID=$GROUP_ID

# Create and start containers
echo "🐳 Starting Docker containers..."
docker-compose -f docker-compose.dev.yml up -d db redis

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Setup database
echo "💾 Setting up database..."
docker-compose -f docker-compose.dev.yml run --rm web bash -c "bundle exec rails db:create db:migrate db:seed"

echo "
✨ Setup complete! ✨

To start the application:
  docker-compose -f docker-compose.dev.yml up

To run commands inside the container:
  docker-compose -f docker-compose.dev.yml exec web bash
  docker-compose -f docker-compose.dev.yml exec web rails console
  docker-compose -f docker-compose.dev.yml exec web rails db:migrate

To run tests:
  docker-compose -f docker-compose.dev.yml exec web rails test

To stop the application:
  docker-compose -f docker-compose.dev.yml down

To reset everything (including volumes):
  docker-compose -f docker-compose.dev.yml down -v

Access the application at: http://localhost:3000
Webpacker dev server at: http://localhost:3035

Note: Your bash history will be preserved in a Docker volume and will NOT be committed to git.
"
