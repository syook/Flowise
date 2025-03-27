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

# Build the application
RUN pnpm build

# Expose the default port
EXPOSE 3000

# Default environment variables
ENV PORT=3000
ENV NODE_ENV=development

# Install nodemon and concurrently for development workflow
RUN npm install -g nodemon concurrently

# Create a start script to watch for component changes
COPY ./docker/dev-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dev-entrypoint.sh

# Use the custom entrypoint script
ENTRYPOINT ["dev-entrypoint.sh"]