# syntax=docker/dockerfile:1

## Composer stage: resolve and install PHP dependencies ##
FROM composer:2.10.3 AS vendor
WORKDIR /app
COPY composer.json composer.lock* ./
RUN --mount=type=cache,target=/tmp/cache \
    composer install --no-dev --no-scripts --no-autoloader --prefer-dist --no-interaction
COPY . .
RUN composer dump-autoload --no-dev --optimize --no-interaction

## Run stage ##
# FrankenPHP bundles the web server (Caddy) and PHP, so one process serves the app.
FROM dunglas/frankenphp:1.13.3-php8.5.12-alpine
WORKDIR /app

# Production php.ini; secrets (APP_KEY, database credentials) come from the environment at runtime.
RUN cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && addgroup -S -g 10001 app && adduser -S -u 10001 -G app app \
    && chown -R app:app /config/caddy /data/caddy

COPY --from=vendor --chown=app:app /app /app

ENV SERVER_NAME=:8080
USER app

# APP_KEY must be provided at runtime: docker run -e APP_KEY=base64:...
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:8080/up"]
