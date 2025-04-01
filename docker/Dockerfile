# Stage 1: Build stage
FROM node:20-alpine AS build

USER root
WORKDIR /usr/src

# Skip downloading Chrome for Puppeteer (saves build time)
ENV PUPPETEER_SKIP_DOWNLOAD=true

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

# Build all packages via turbo
RUN pnpm build

# Stage 2: Runtime stage
FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache libc6-compat python3 make g++ git py3-pip curl chromium build-base cairo-dev pango-dev

# Set the environment variable for Puppeteer to find Chromium
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

WORKDIR /usr/src

# Copy the built application from the build stage
COPY --from=build /usr/src /usr/src

# Install the local packages globally so they're in the PATH
# This will make "flowise" point to your local code
RUN cd /usr/src && npm install -g ./packages/server

EXPOSE 3000-9000

# Now "flowise start" will use your locally built version
ENTRYPOINT ["flowise", "start"]