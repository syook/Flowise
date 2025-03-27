#!/bin/sh
set -e

# Start the application directly using node
echo "Starting Flowise server..."
exec node packages/server/dist/index.js