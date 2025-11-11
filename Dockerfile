# ----------------------------
# Step 1: Build Flutter Web app
# ----------------------------
FROM debian:bookworm-slim AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa && \
    rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web support
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy your Flutter project into the container
COPY . .

# Get dependencies & build optimized web app
RUN flutter pub get && flutter build web --release

# ----------------------------
# Step 2: NGINX for serving Flutter Web build
# ----------------------------
FROM nginx:alpine

# Copy the build output from the previous stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 for web traffic
EXPOSE 80

# Run Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
