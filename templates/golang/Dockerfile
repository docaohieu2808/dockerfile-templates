# syntax=docker/dockerfile:1

## Build stage ##
# Run the compiler on the build machine and cross-compile for the target platform.
FROM --platform=$BUILDPLATFORM golang:1.27.3-alpine3.24 AS build
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src

COPY go.mod ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags="-s -w" -o /out/app .

## Run stage ##
FROM scratch
COPY --from=build /out/app /app

# scratch has no /etc/passwd, so use a numeric non-root uid:gid.
USER 65532:65532

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["/app", "-healthcheck"]
ENTRYPOINT ["/app"]
