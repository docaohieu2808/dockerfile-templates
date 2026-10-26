# Dockerfile templates

[![ci](https://github.com/docaohieu2808/dockerfile-templates/actions/workflows/ci.yml/badge.svg)](https://github.com/docaohieu2808/dockerfile-templates/actions/workflows/ci.yml)

Production-minded Dockerfiles for common stacks. Every template ships with a tiny sample app, and CI
builds each one for real on GitHub-hosted runners, then lints it with hadolint and smoke-tests the
running container, so the files here are known to build and start, not just to look right.

What every template follows:

- `# syntax=docker/dockerfile:1` on the first line and exact base-image tags (no `latest`), on currently supported releases.
- Multi-stage builds: toolchains and dev dependencies stay out of the final image.
- The final stage runs as a non-root user.
- A `HEALTHCHECK` only where the image has a tool to run it (busybox `wget`, `python`, or the binary itself on `scratch`).
- Dependency layers come before source layers and use BuildKit cache mounts.
- Each service answers `GET /health`; CI checks the HTTP response, the non-root user and the healthcheck status.

## Templates

| Template | Stack and base images | Purpose | Platforms |
| :-- | :-- | :-- | :-- |
| [react-nginx](templates/react-nginx/Dockerfile) | Node 24 build, nginx-unprivileged 1.30 | Static SPA (React, Vue, Angular): build once, serve with nginx on 8080. `--build-arg OUT_DIR=dist` for Vite, Vue and Angular. | amd64, arm64 |
| [nodejs](templates/nodejs/Dockerfile) | Node 24 (Alpine), Express 5 | Plain Node service: production-only dependencies, `node` user, graceful SIGTERM. | amd64, arm64 |
| [nextjs](templates/nextjs/Dockerfile) | Node 24 (Alpine), Next.js 16 | `output: "standalone"` build, three stages (deps, build, run). | amd64 |
| [nestjs](templates/nestjs/Dockerfile) | Node 24 (Alpine), NestJS 12 | `dev` target with hot reload, `build` stage, slim `prod` target. | amd64 |
| [java-spring-boot](templates/java-spring-boot/Dockerfile) | Maven 3.9 + Temurin 25 build, Temurin 25 JRE (Alpine), Spring Boot 4.1 | Maven build with cached `~/.m2`; JVM flags through `JAVA_TOOL_OPTIONS`, exec-form `ENTRYPOINT`. | amd64 |
| [dotnet](templates/dotnet/Dockerfile) | .NET SDK 10 / ASP.NET 10 (Alpine) | Restore, publish, run as the built-in `app` user on port 8080. | amd64 |
| [laravel](templates/laravel/Dockerfile) | Composer 2.10, FrankenPHP 1.13 on PHP 8.5 (Alpine), Laravel 13 | One process (Caddy + PHP) instead of nginx + php-fpm + supervisor; no `.env` baked into the image. | amd64 |
| [django](templates/django/Dockerfile) | Python 3.14 (slim), Django 6.1, gunicorn | Virtualenv build stage, gunicorn on 8000, secret key required at runtime. | amd64 |
| [flask](templates/flask/Dockerfile) | Python 3.14 (slim), Flask 3.1, gunicorn | Same layout as Django, with gunicorn instead of the Flask dev server. | amd64 |
| [golang](templates/golang/Dockerfile) | Go 1.27 (Alpine) build, `scratch` | Cross-compiles on the build host with `TARGETARCH`; the binary is its own healthcheck probe. | amd64, arm64 |
| [rust](templates/rust/Dockerfile) | Rust 1.99 (Alpine/musl), `scratch` | Static binary with cargo cache mounts; `--locked` build; healthcheck subcommand. | amd64 |
| [ruby-rails](templates/ruby-rails/Dockerfile) | Ruby 4.0 (Alpine), Rails 8.1, Puma 8 | Native gems compiled in a builder stage; deployment-mode bundle; single-file Rails app. | amd64 |
| [swift-vapor](templates/swift-vapor/Dockerfile) | Swift 6.4 (Ubuntu 24.04 build), Ubuntu 24.04, Vapor 4 | Static Swift stdlib so the runtime image needs no Swift install. | amd64 |
| [cpp](templates/cpp/Dockerfile) | GCC 15, `scratch` | Statically linked C++ program in an empty image (run-to-completion, no healthcheck). | amd64 |
| [dart](templates/dart/Dockerfile) | Dart 3.13, `scratch` | AOT-compiled server using the SDK's `/runtime/` libs. | amd64 |

Layout of every template: `templates/<stack>/Dockerfile`, a `.dockerignore`, and the smallest sample app that makes the build real.

## Use a template

```bash
docker build -t myapp templates/nodejs
docker run --rm -p 8080:8080 myapp
curl localhost:8080/health
```

Copy the folder, replace the sample app with yours, keep the Dockerfile structure.

Runtime secrets are never baked in: Django needs `DJANGO_SECRET_KEY`, Laravel needs `APP_KEY`
(`docker run -e ...`). The Laravel sample has no committed `composer.lock`; generate and commit your
own before relying on the template for production, so builds are reproducible.

## CI

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on push, pull request, weekly (base images
move even when this repo does not) and on demand. Per template: hadolint (fails on warning and above),
`docker buildx build`, and a smoke test ([`smoke.sh`](.github/scripts/smoke.sh)). Templates marked arm64
above are also built and started under QEMU. Actions are pinned to full commit SHAs, and Dependabot
(`.github/dependabot.yml`) proposes base-image and action updates per directory.

## Notes on what changed from the first version

The first version was a single README of copy-paste snippets, several of which did not build. The
templates are now real files, and duplicates were merged: React npm/advanced/yarn and Vue/Angular became
`react-nginx`; the three NestJS variants became `nestjs`; the two Swift variants became `swift-vapor`.

## License

[MIT](LICENSE)
