# syntax = docker/dockerfile:1

# ---------------------------
# Base image
# ---------------------------
# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=2.4.3
FROM ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    LANG=en_US.UTF-8 \
    RAILS_LOG_TO_STDOUT=true \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development" \
    RAILS_SERVE_STATIC_FILES=true

# ---------------------------
# Build stage:
# ---------------------------
# Throw-away build stage to reduce size of final image
FROM base AS build

# Use archive.debian.org for Stretch and disable expired checks
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Install build dependencies (without nodejs package to avoid old version)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y --allow-unauthenticated \
      build-essential curl git libpq-dev libvips pkg-config python && \
    rm -rf /var/lib/apt/lists/*

# Install Node and Yarn
ARG NODE_VERSION=10.24.1
ARG YARN_VERSION=1.22.21
ENV PATH=/usr/local/node/bin:$PATH

RUN curl -sL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz | tar -xJ -C /tmp/ && \
    mv /tmp/node-v${NODE_VERSION}-linux-x64 /usr/local/node && \
    /usr/local/node/bin/npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-v*

# Install Ruby gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git


# Install JS dependencies
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy app code and precompile assets without requiring secret SECRET_KEY_BASE
COPY . .
RUN SECRET_KEY_BASE=1 ./bin/rails assets:precompile

# ---------------------------
# Final runtime image
# ---------------------------
FROM base AS final

# Use archive.debian.org for Stretch
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y --allow-unauthenticated \
      curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /usr/local/node /usr/local/node
COPY --from=build /rails /rails

ENV PATH=$PATH:/usr/local/node/bin

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
