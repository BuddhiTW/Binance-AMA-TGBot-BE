#!/bin/sh
set -e

# Print environment summary (safe)
echo "Starting Binance AMA Bot"
echo "Node: $(node -v)"

# Default NODE_ENV
export NODE_ENV=${NODE_ENV:-production}

# Migrations
echo "Running migrations..."
if npx --yes knex --help >/dev/null 2>&1; then
  npx knex migrate:latest || true
else
  echo "Knex CLI not available; skipping migrations."
fi

# Start application
exec npm run start:prod
