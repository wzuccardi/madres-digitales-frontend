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
  --base-href="/" \
  --dart-define=ENVIRONMENT=$ENVIRONMENT_VALUE \
  --dart-define=API_URL=$API_URL_VALUE \
  --dart-define=BACKEND_URL=$BACKEND_URL_VALUE

echo "Build completed successfully!"

# Verify critical files exist
echo "Verifying build output..."
if [ -f "build/web/index.html" ]; then
  echo "✓ index.html found"
else
  echo "✗ index.html NOT found"
fi

if [ -f "build/web/manifest.json" ]; then
  echo "✓ manifest.json found"
else
  echo "✗ manifest.json NOT found"
fi

if [ -f "build/web/flutter_bootstrap.js" ]; then
  echo "✓ flutter_bootstrap.js found"
else
  echo "✗ flutter_bootstrap.js NOT found"
fi

echo "Build verification complete!"
