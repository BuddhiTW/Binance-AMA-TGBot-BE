#!/bin/sh
set -e

# Print environment summary (safe)
echo "Starting Binance AMA Bot"
echo "Node: $(node -v)"

# Set network preferences for better connectivity
export NODE_OPTIONS="--dns-result-order=ipv4first --max-http-header-size=16384"
export GRPC_DNS_RESOLVER="native"
export UV_THREADPOOL_SIZE=128

# Configure Node.js HTTP timeouts
export HTTPS_AGENT_TIMEOUT=60000
export HTTP_AGENT_TIMEOUT=60000
export NODE_TLS_REJECT_UNAUTHORIZED=0

# Configure additional network settings
ulimit -n 65536 2>/dev/null || true

# Default NODE_ENV
export NODE_ENV=${NODE_ENV:-production}

# Network diagnostics
echo "Testing network connectivity..."
echo "DNS resolution test for api.telegram.org:"
nslookup api.telegram.org || echo "DNS lookup failed"

echo "Ping test to 8.8.8.8:"
ping -c 1 8.8.8.8 || echo "Ping to 8.8.8.8 failed"

echo "Testing HTTPS connectivity to Telegram API (with longer timeout):"
curl -s --connect-timeout 30 --max-time 60 -I https://api.telegram.org/ || echo "Telegram API base connectivity test failed"

echo "Testing bot token connectivity:"
if [ ! -z "$TELEGRAM_BOT_TOKEN" ]; then
    curl -s --connect-timeout 30 --max-time 60 -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe" || echo "Bot token test failed"
else
    echo "TELEGRAM_BOT_TOKEN not set"
fi

# Migrations (skip for now to focus on network issue)
echo "Skipping migrations temporarily to focus on network connectivity issue..."
# if npx --yes knex --help >/dev/null 2>&1; then
#   npx knex migrate:latest || true
# else
#   echo "Knex CLI not available; skipping migrations."
# fi

# Start application with increased timeout settings
exec npm run start:prod
