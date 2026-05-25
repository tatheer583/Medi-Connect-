# ─── Build Stage ─────────────────────────────────────────────────────────────
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency configuration files
COPY package*.json tsconfig.json ./

# Install all dependencies (including devDependencies for TypeScript building)
RUN npm ci

# Copy source code files
COPY src/ ./src/

# Compile TypeScript to production-ready JavaScript (writes to dist/)
RUN npm run build

# ─── Production Stage ─────────────────────────────────────────────────────────
FROM node:20-alpine AS runner

WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy package files for installing runtime-only dependencies
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Copy built code from builder stage
COPY --from=builder /app/dist ./dist

# Expose standard API server port
EXPOSE 5000

# Start server
CMD ["node", "dist/server.js"]
