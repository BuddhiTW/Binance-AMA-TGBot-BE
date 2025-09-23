#!/bin/sh
set -e

# Print environment summary (safe)
echo "Starting Binance AMA Bot"
echo "Node: $(node -v)"

# Set network preferences
export NODE_OPTIONS="--dns-result-order=ipv4first"
export GRPC_DNS_RESOLVER="native"

# Default NODE_ENV
export NODE_ENV=${NODE_ENV:-production}

# Network diagnostics
echo "Testing network connectivity..."
echo "DNS resolution test for api.telegram.org:"
nslookup api.telegram.org || echo "DNS lookup failed"

echo "Ping test to 8.8.8.8:"
ping -c 1 8.8.8.8 || echo "Ping to 8.8.8.8 failed"

echo "Testing HTTPS connectivity to Telegram API (without token):"
curl -s --connect-timeout 10 --max-time 30 -I https://api.telegram.org/ || echo "Telegram API base connectivity test failed"

# Migrations
echo "Running migrations..."
if npx --yes knex --help >/dev/null 2>&1; then
  npx knex migrate:latest || true
else
  echo "Knex CLI not available; skipping migrations."
fi

# Start application
exec npm run start:prod
