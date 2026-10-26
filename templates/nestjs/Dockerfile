# syntax=docker/dockerfile:1

## Dev stage: all dependencies, hot reload ##
# docker build --target dev -t app:dev . && docker run -v "$PWD/src:/usr/src/app/src" app:dev
FROM node:26.12.1-alpine3.24 AS dev
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
CMD ["npm", "run", "start:dev"]

## Build stage: compile TypeScript with the dev dependencies ##
FROM dev AS build
RUN npm run build

## Production dependencies only ##
FROM node:26.12.1-alpine3.24 AS prod-deps
WORKDIR /usr/src/app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev

## Run stage ##
FROM node:26.12.1-alpine3.24 AS prod
ENV NODE_ENV=production
WORKDIR /usr/src/app

COPY --from=prod-deps --chown=node:node /usr/src/app/node_modules ./node_modules
COPY --from=build --chown=node:node /usr/src/app/dist ./dist
COPY --chown=node:node package.json ./

# The official node image ships a non-root "node" user (uid 1000).
USER node

EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:3000/health"]
CMD ["node", "dist/main.js"]
