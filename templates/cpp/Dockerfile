# syntax=docker/dockerfile:1

## Build stage ##
FROM gcc:15.3.0-trixie AS build
WORKDIR /src
COPY app.cpp ./
# -static: no shared libraries are needed at runtime, so the final image can be empty.
RUN g++ -std=c++20 -O2 -static -o app app.cpp

## Run stage ##
FROM scratch
COPY --from=build /src/app /app

# scratch has no /etc/passwd, so use a numeric non-root uid:gid.
# No HEALTHCHECK: this sample is a run-to-completion program, not a service.
USER 65532:65532
ENTRYPOINT ["/app"]
