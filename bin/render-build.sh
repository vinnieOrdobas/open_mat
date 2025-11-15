#!/usr/bin/env bash

# Exit on error
set -o errexit

# Install dependencies
bundle install

# Precompile assets
bin/rails assets:precompile

# Clean up old assets
bin/rails assets:clean

# Run database migrations
# As the doc notes, this is fine in the build command for the free tier.
bin/rails db:migrate