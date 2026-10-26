# syntax=docker/dockerfile:1

## Build stage ##
FROM node:26.12.1-alpine3.24 AS build
WORKDIR /app

# Install dependencies first so this layer is cached until the lockfile changes.
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY . .
RUN npm run build

## Run stage ##
FROM nginxinc/nginx-unprivileged:1.30.6-alpine3.24

# Build output directory: "build" (Create React App), "dist" (Vite, Vue, Angular).
ARG OUT_DIR=build

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/${OUT_DIR} /usr/share/nginx/html

# The base image already runs as the unprivileged "nginx" user (uid 101).
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:8080/"]
