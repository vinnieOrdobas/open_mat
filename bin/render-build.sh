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
bin/rails db:migrate

# Run the seed data task
bin/rails db:seed