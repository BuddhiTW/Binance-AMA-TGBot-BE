###############################
# Builder stage
###############################
FROM node:22-alpine AS builder

WORKDIR /app

# Copy only manifest files first for better caching
COPY package*.json ./
COPY pnpm-lock.yaml ./

# Install dependencies (includes dev deps for build)
RUN npm install

# Copy the rest of the source code
COPY . .

# Build the application (Nest compiles src -> dist)
RUN npm run build

###############################
# Runtime stage
###############################
FROM node:22-alpine AS runtime

# Install curl for health checks
RUN apk add --no-cache curl

WORKDIR /app

# Copy only required runtime artifacts
COPY package*.json ./

# Install production dependencies only
RUN npm install --omit=dev && npm cache clean --force

# Copy built app and necessary runtime files
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/public ./public
COPY --from=builder /app/scripts ./scripts
COPY --from=builder /app/knexfile.js ./knexfile.js

# Expose application port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD curl -sf http://localhost:3000/health || exit 1

# Default environment
ENV NODE_ENV=production

# Entrypoint runs DB migrations then starts the app
RUN chmod +x ./scripts/entrypoint.sh
ENTRYPOINT ["sh", "./scripts/entrypoint.sh"]