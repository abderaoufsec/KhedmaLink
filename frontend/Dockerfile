# KhedmaLink Frontend Dockerfile
# Multi-stage build for Flutter web application

# =============================================================================
# STAGE 1: BUILD
# =============================================================================

FROM ubuntu:22.04 as builder

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter doctor -v

# Set working directory
WORKDIR /app

# Copy Flutter project files
COPY pubspec.yaml ./
COPY pubspec.lock ./
RUN flutter pub get

# Copy source code
COPY . .

# Build Flutter web application
RUN flutter build web --release

# =============================================================================
# STAGE 2: RUNTIME
# =============================================================================

FROM nginx:alpine

# Copy built web application from builder
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
