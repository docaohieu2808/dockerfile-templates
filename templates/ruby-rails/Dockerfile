# syntax=docker/dockerfile:1

## Builder stage: compile native gems ##
FROM ruby:4.0.9-alpine3.24 AS builder
# Alpine package versions rotate inside a release, so pinning them would break rebuilds.
# hadolint ignore=DL3018
RUN apk add --no-cache build-base
WORKDIR /app
# BUNDLE_PATH is explicit because deployment mode otherwise installs into ./vendor/bundle.
ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test"
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 \
    && rm -rf /usr/local/bundle/cache

## Run stage ##
FROM ruby:4.0.9-alpine3.24
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development:test" \
    RAILS_LOG_TO_STDOUT=1
WORKDIR /app

RUN addgroup -S -g 10001 app && adduser -S -u 10001 -G app app \
    && mkdir -p tmp log && chown app:app tmp log

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=app:app Gemfile Gemfile.lock config.ru ./

USER app

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:3000/health"]
CMD ["bundle", "exec", "puma", "--bind", "tcp://0.0.0.0:3000"]
