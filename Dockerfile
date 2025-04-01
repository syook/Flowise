# Build local monorepo image
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 flowise

FROM node:20-alpine

# Install runtime dependencies
RUN apk add --no-cache libc6-compat python3 make g++ git py3-pip curl chromium build-base cairo-dev pango-dev

#install PNPM globaly
RUN npm install -g pnpm

ENV PUPPETEER_SKIP_DOWNLOAD=true

ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

ENV NODE_OPTIONS=--max-old-space-size=8192

WORKDIR /usr/src

# Copy package files first for better caching
COPY package.json pnpm-workspace.yaml* ./
COPY packages/components/package.json ./packages/components/
COPY packages/server/package.json ./packages/server/
COPY packages/ui/package.json ./packages/ui/
COPY packages/api-documentation/package.json ./packages/api-documentation/

# Install dependencies using pnpm (skip strict peer dependency checking)
RUN pnpm install --recursive --no-strict-peer-dependencies --shamefully-hoist

# Copy app source
COPY . .

RUN pnpm build

EXPOSE 3000-9000

CMD [ "pnpm", "start" ]
