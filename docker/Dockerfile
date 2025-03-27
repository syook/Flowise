# Stage 1: Build stage
FROM node:20-alpine AS build

USER root
WORKDIR /app

# Install pnpm globally
RUN npm install -g pnpm

# Copy package files first for better caching
COPY package.json pnpm-workspace.yaml* ./
COPY packages/components/package.json ./packages/components/
COPY packages/server/package.json ./packages/server/
COPY packages/ui/package.json ./packages/ui/
COPY packages/api-documentation/package.json ./packages/api-documentation/

# Install dependencies using pnpm (skip strict peer dependency checking)
RUN pnpm install --recursive --no-strict-peer-dependencies --shamefully-hoist

# Copy the rest of the application code
COPY . .

# (Optional) Ensure UI package dependencies are installed
RUN cd packages/ui && pnpm install

# Build all packages via turbo
RUN pnpm build

# Stage 2: Runtime stage
FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache chromium git python3 py3-pip make g++ build-base cairo-dev pango-dev curl

# Set the environment variable for Puppeteer to find Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /app

# Copy the built application from the build stage
COPY --from=build /app /app

# Expose default port
EXPOSE 3000

# Set environment variables
ENV PORT=3000

# Start the application using the local build
ENTRYPOINT ["node", "packages/server/dist/index.js"]