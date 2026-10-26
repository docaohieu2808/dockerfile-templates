# syntax=docker/dockerfile:1

## Dependencies stage: production dependencies only ##
FROM node:26.12.1-alpine3.24 AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci --omit=dev

## Run stage ##
FROM node:26.12.1-alpine3.24
ENV NODE_ENV=production
WORKDIR /app

COPY --from=deps --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package.json app.js ./

# The official node image ships a non-root "node" user (uid 1000).
USER node

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD ["wget", "-q", "--spider", "http://127.0.0.1:8080/health"]
CMD ["node", "app.js"]
