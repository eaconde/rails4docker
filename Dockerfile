# Use barebones of Ruby v2.2.4
FROM ruby:2.4.4-slim

MAINTAINER Eric Conde <condeeric@outlook.com>

# Install deps
RUN apt-get update && apt-get install -qq -y \
    build-essential nodejs libpq-dev postgresql-9.5 \
    --fix-missing --no-install-recommends \
    apt-utils

# Env Vars
ENV INSTALL_PATH /ec-ror4
RUN mkdir -p $INSTALL_PATH

# Context where commands will be ran
WORKDIR $INSTALL_PATH

# Cache gems
COPY Gemfile Gemfile
RUN bundle install

# Copy application code
COPY . .

# Assets precompilation
RUN RAILS_ENV=production \
    DATABASE_URL=postgresql://user:pass@127.0.0.1/dbname \
    SECRET_KEY_BASE=fc6a5cf1e11916f0ff3bf77d2febb64d814e79f3b469081b810efb56a311ca1183918472377518b72abc26125a25ae6598324cb8396a9e6c863992bd9c5376dd \
    bundle exec rake assets:precompile

# Exposed nginx volume for production assets
VOLUME ["$INSTALL_PATH/public"]

# Finally start unicorn server
CMD bundle exec unicorn -c config/unicorn.rb
