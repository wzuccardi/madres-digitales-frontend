# Script para probar la aplicación localmente en Windows

Write-Host "🧪 Probando aplicación localmente..." -ForegroundColor Cyan
Write-Host ""

# Limpiar
Write-Host "1️⃣ Limpiando proyecto..." -ForegroundColor Yellow
flutter clean

# Obtener dependencias
Write-Host "2️⃣ Obteniendo dependencias..." -ForegroundColor Yellow
flutter pub get

# Analizar código
Write-Host "3️⃣ Analizando código..." -ForegroundColor Yellow
flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Errores encontrados en el análisis" -ForegroundColor Red
    exit 1
}

# Verificar que no haya errores de compilación
Write-Host "4️⃣ Verificando compilación..." -ForegroundColor Yellow
flutter build web --debug

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Errores de compilación encontrados" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Pruebas completadas exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "Para ejecutar localmente:" -ForegroundColor Cyan
Write-Host "  flutter run -d chrome" -ForegroundColor White
Write-Host ""
Write-Host "Para ejecutar en modo web:" -ForegroundColor Cyan
Write-Host "  flutter run -d web-server --web-port=8080" -ForegroundColor White
Write-Host ""
Write-Host "Para ver en el navegador:" -ForegroundColor Cyan
Write-Host "  http://localhost:8080" -ForegroundColor White
