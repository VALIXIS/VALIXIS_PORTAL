# ==============================================================================
# Multi-stage Dockerfile for VALIXIS Portal (Flutter Web)
# ==============================================================================

# Stage 1: Build Flutter Web application
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS builder

WORKDIR /app

# Copy dependency specifications first to leverage layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application source code
COPY . .

# Build web release bundle
RUN flutter build web --release

# Stage 2: Production web server using lightweight Nginx
FROM nginx:alpine

# Copy built web artifacts to nginx html directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
RUN printf 'server {\n\
    listen 8080;\n\
    server_name localhost;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
