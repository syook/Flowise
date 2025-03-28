# Development Dockerfile for Flowise
FROM node:20-alpine

USER root
WORKDIR /app

# Install pnpm and development tools
RUN npm install -g pnpm
RUN apk add --no-cache git python3 py3-pip make g++ build-base curl chromium

# Set the environment variable for Puppeteer to find Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Copy package files first for better caching
COPY package.json pnpm-workspace.yaml* ./
COPY packages/components/package.json ./packages/components/
COPY packages/server/package.json ./packages/server/
COPY packages/ui/package.json ./packages/ui/
COPY packages/api-documentation/package.json ./packages/api-documentation/

# Install dependencies with hoisting
RUN pnpm install --recursive --no-strict-peer-dependencies --shamefully-hoist

# Copy the rest of the application code
COPY . .

# Build the packages in the correct order
RUN pnpm --filter flowise-components build
RUN pnpm --filter flowise-server build
RUN pnpm --filter flowise-ui build

EXPOSE 3000-9000

# Default environment variables
ENV NODE_ENV=development

# Use bash for better debugging
RUN apk add --no-cache bash

CMD [ "pnpm", "start" ]