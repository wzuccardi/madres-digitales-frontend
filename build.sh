#!/bin/bash

# Install Flutter
echo "Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Verify Flutter installation
flutter --version

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build web app
echo "Building Flutter web app..."
ENVIRONMENT_VALUE=${ENVIRONMENT:-production}
API_URL_VALUE=${API_URL:-https://madres-digitales-backend.vercel.app}
BACKEND_URL_VALUE=${BACKEND_URL:-}
flutter build web --release \
  --dart-define=ENVIRONMENT=$ENVIRONMENT_VALUE \
  --dart-define=API_URL=$API_URL_VALUE \
  --dart-define=BACKEND_URL=$BACKEND_URL_VALUE

echo "Build completed successfully!"
