# syntax=docker/dockerfile:1

## Build stage ##
FROM swift:6.4.1-noble AS build
WORKDIR /build

# Resolve dependencies first so this layer is cached until Package.swift changes.
COPY Package.swift ./
RUN swift package resolve

COPY Sources ./Sources
# --static-swift-stdlib: the Swift runtime is linked in, so the final image needs no Swift install.
RUN swift build -c release --static-swift-stdlib \
    && mkdir /staging \
    && cp "$(swift build -c release --show-bin-path)/App" /staging/

## Run stage ##
FROM ubuntu:26.04
# Package versions rotate inside an Ubuntu release, so pinning them would break rebuilds.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --system --uid 10001 --create-home --home-dir /app vapor

WORKDIR /app
COPY --from=build --chown=vapor:vapor /staging /app

USER vapor

# No HEALTHCHECK: ubuntu has no curl or wget, and installing one only for a probe is not worth the size.
EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
