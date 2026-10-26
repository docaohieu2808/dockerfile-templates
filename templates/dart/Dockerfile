# syntax=docker/dockerfile:1

## Build stage ##
FROM dart:3.13.7-sdk AS build
WORKDIR /app

COPY pubspec.yaml ./
RUN dart pub get

COPY bin ./bin
RUN dart compile exe bin/server.dart -o /app/server

## Run stage ##
# /runtime/ in the dart image holds the minimal libc and certificates an AOT binary needs.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/server /app/server

# scratch has no /etc/passwd, so use a numeric non-root uid:gid.
# No HEALTHCHECK: scratch has no probe tool and the sample has no probe mode.
USER 65532:65532

EXPOSE 8080
ENTRYPOINT ["/app/server"]
