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
flutter build web --release

echo "Build completed successfully!"