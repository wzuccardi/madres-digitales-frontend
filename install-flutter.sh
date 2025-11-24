#!/bin/bash

# Script para instalar Flutter en Vercel
set -e

echo "🚀 Installing Flutter for Vercel build..."

# Definir versión de Flutter
FLUTTER_VERSION="3.19.6"
FLUTTER_CHANNEL="stable"

# Verificar si Flutter ya está instalado
if [ -d "$HOME/flutter" ]; then
    echo "✅ Flutter already installed"
    export PATH="$HOME/flutter/bin:$PATH"
    flutter --version
    exit 0
fi

# Descargar Flutter
echo "📦 Downloading Flutter ${FLUTTER_VERSION}..."
cd $HOME
git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} --depth 1

# Agregar Flutter al PATH
export PATH="$HOME/flutter/bin:$PATH"

# Configurar Flutter
echo "⚙️ Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web

# Verificar instalación
echo "✅ Flutter installed successfully!"
flutter --version
flutter doctor -v

echo "🎉 Flutter installation complete!"
