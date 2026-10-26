# syntax=docker/dockerfile:1

## Build stage ##
# The Alpine image targets musl, which links statically by default, so the binary runs on scratch.
FROM rust:1.99.1-alpine3.24 AS build
WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/app/target \
    cargo build --release --locked \
    && cp target/release/app /usr/local/bin/app

## Run stage ##
FROM scratch
COPY --from=build /usr/local/bin/app /app

# scratch has no /etc/passwd, so use a numeric non-root uid:gid.
USER 65532:65532

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/app", "healthcheck"]
ENTRYPOINT ["/app"]
