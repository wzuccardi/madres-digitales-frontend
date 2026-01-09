#!/bin/bash

echo "🧪 Probando aplicación localmente..."
echo ""

# Limpiar
echo "1️⃣ Limpiando proyecto..."
flutter clean

# Obtener dependencias
echo "2️⃣ Obteniendo dependencias..."
flutter pub get

# Analizar código
echo "3️⃣ Analizando código..."
flutter analyze

# Verificar formato
echo "4️⃣ Verificando formato..."
flutter format --set-exit-if-changed lib/

# Compilar para web (modo debug)
echo "5️⃣ Compilando para web (debug)..."
flutter build web --debug

echo ""
echo "✅ Pruebas completadas!"
echo ""
echo "Para ejecutar localmente:"
echo "  flutter run -d chrome"
echo ""
echo "Para ejecutar en modo web:"
echo "  flutter run -d web-server --web-port=8080"
