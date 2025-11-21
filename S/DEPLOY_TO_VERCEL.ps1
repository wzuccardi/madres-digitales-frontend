# Script de Deployment a Vercel - Madres Digitales Frontend
# Autor: Wilson Zuccardi
# Fecha: 2024-11-21

Write-Host "🚀 Madres Digitales - Deployment a Vercel" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar si Vercel CLI está instalado
Write-Host "📦 Verificando Vercel CLI..." -ForegroundColor Yellow
$vercelInstalled = Get-Command vercel -ErrorAction SilentlyContinue

if (-not $vercelInstalled) {
    Write-Host "❌ Vercel CLI no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Instalando Vercel CLI..." -ForegroundColor Yellow
    npm install -g vercel
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al instalar Vercel CLI" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Vercel CLI instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "✅ Vercel CLI ya está instalado" -ForegroundColor Green
}

Write-Host ""

# Verificar si Flutter está instalado
Write-Host "📦 Verificando Flutter..." -ForegroundColor Yellow
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterInstalled) {
    Write-Host "❌ Flutter no está instalado" -ForegroundColor Red
    Write-Host "Por favor instala Flutter desde: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter está instalado" -ForegroundColor Green
flutter --version
Write-Host ""

# Cambiar al directorio del frontend
Write-Host "📂 Cambiando al directorio del frontend..." -ForegroundColor Yellow
Set-Location "S\aplicacionWZC\madres_digitales_flutter_new"

if (-not (Test-Path "pubspec.yaml")) {
    Write-Host "❌ No se encontró pubspec.yaml. Verifica que estás en el directorio correcto" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Directorio correcto" -ForegroundColor Green
Write-Host ""

# Limpiar build anterior
Write-Host "🧹 Limpiando build anterior..." -ForegroundColor Yellow
if (Test-Path "build\web") {
    Remove-Item -Recurse -Force "build\web"
    Write-Host "✅ Build anterior eliminado" -ForegroundColor Green
} else {
    Write-Host "ℹ️  No hay build anterior" -ForegroundColor Gray
}

Write-Host ""

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias de Flutter..." -ForegroundColor Yellow
flutter pub get

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al obtener dependencias" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencias obtenidas" -ForegroundColor Green
Write-Host ""

# Build para web
Write-Host "🔨 Compilando Flutter Web..." -ForegroundColor Yellow
Write-Host "Esto puede tomar varios minutos..." -ForegroundColor Gray
flutter build web --release --web-renderer canvaskit --no-tree-shake-icons

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al compilar Flutter Web" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Compilación exitosa" -ForegroundColor Green
Write-Host ""

# Verificar que build/web existe
if (-not (Test-Path "build\web\index.html")) {
    Write-Host "❌ No se generó el build correctamente" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build generado en build/web" -ForegroundColor Green
Write-Host ""

# Preguntar tipo de deployment
Write-Host "🚀 Tipo de deployment:" -ForegroundColor Cyan
Write-Host "1. Production (--prod)" -ForegroundColor White
Write-Host "2. Preview (default)" -ForegroundColor White
Write-Host ""
$deployType = Read-Host "Selecciona una opción (1 o 2)"

$deployCommand = "vercel"
if ($deployType -eq "1") {
    $deployCommand = "vercel --prod"
    Write-Host ""
    Write-Host "⚠️  Vas a desplegar a PRODUCCIÓN" -ForegroundColor Yellow
    $confirm = Read-Host "¿Estás seguro? (s/n)"
    
    if ($confirm -ne "s" -and $confirm -ne "S") {
        Write-Host "❌ Deployment cancelado" -ForegroundColor Red
        exit 0
    }
}

Write-Host ""
Write-Host "🚀 Desplegando a Vercel..." -ForegroundColor Yellow
Write-Host "Comando: $deployCommand" -ForegroundColor Gray
Write-Host ""

# Ejecutar deployment
Invoke-Expression $deployCommand

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Error en el deployment" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Deployment completado exitosamente!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Próximos pasos:" -ForegroundColor Cyan
Write-Host "1. Verifica que el sitio carga correctamente" -ForegroundColor White
Write-Host "2. Prueba el login y funcionalidades principales" -ForegroundColor White
Write-Host "3. Verifica que la conexión con el backend funciona" -ForegroundColor White
Write-Host ""
Write-Host "🔗 Enlaces útiles:" -ForegroundColor Cyan
Write-Host "Dashboard Vercel: https://vercel.com/dashboard" -ForegroundColor White
Write-Host "Documentación: Ver VERCEL_DEPLOYMENT.md" -ForegroundColor White
Write-Host ""
Write-Host "✨ ¡Listo!" -ForegroundColor Green
