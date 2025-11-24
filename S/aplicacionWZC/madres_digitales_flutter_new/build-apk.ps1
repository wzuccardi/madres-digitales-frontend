# Script para generar APK - Madres Digitales
# Uso: .\build-apk.ps1 [-Type release|debug] [-Split $true|$false]

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('release', 'debug')]
    [string]$Type = 'release',
    
    [Parameter(Mandatory=$false)]
    [bool]$Split = $false
)

Write-Host "📱 Generando APK de Madres Digitales..." -ForegroundColor Cyan
Write-Host ""

# Verificar que Flutter está instalado
$flutterInstalled = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterInstalled) {
    Write-Host "❌ Error: Flutter no está instalado o no está en el PATH" -ForegroundColor Red
    exit 1
}

# Mostrar versión de Flutter
Write-Host "🔍 Versión de Flutter:" -ForegroundColor Yellow
flutter --version
Write-Host ""

# Limpiar build anterior
Write-Host "🧹 Limpiando build anterior..." -ForegroundColor Cyan
flutter clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Advertencia: Error al limpiar" -ForegroundColor Yellow
}

# Obtener dependencias
Write-Host "📦 Obteniendo dependencias..." -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al obtener dependencias" -ForegroundColor Red
    exit 1
}

# Construir comando de build
$buildCmd = "flutter build apk"

if ($Type -eq 'debug') {
    $buildCmd += " --debug"
    Write-Host "🔧 Generando APK de DEBUG..." -ForegroundColor Yellow
} else {
    $buildCmd += " --release"
    Write-Host "🚀 Generando APK de RELEASE..." -ForegroundColor Green
}

if ($Split) {
    $buildCmd += " --split-per-abi"
    Write-Host "📊 Generando APKs separados por arquitectura..." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "⚙️  Ejecutando: $buildCmd" -ForegroundColor Cyan
Write-Host ""

# Ejecutar build
Invoke-Expression $buildCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ APK generado exitosamente!" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar ubicación del APK
    $apkPath = "build\app\outputs\flutter-apk"
    Write-Host "📂 Ubicación del APK:" -ForegroundColor Cyan
    Write-Host "   $apkPath" -ForegroundColor White
    Write-Host ""
    
    # Listar APKs generados
    if (Test-Path $apkPath) {
        Write-Host "📱 APKs generados:" -ForegroundColor Cyan
        Get-ChildItem -Path $apkPath -Filter "*.apk" | ForEach-Object {
            $sizeMB = [math]::Round($_.Length / 1MB, 2)
            Write-Host "   - $($_.Name) ($sizeMB MB)" -ForegroundColor White
        }
        Write-Host ""
    }
    
    # Mostrar siguiente paso
    Write-Host "📤 Próximos pasos:" -ForegroundColor Yellow
    Write-Host "   1. Probar APK en dispositivo:" -ForegroundColor White
    Write-Host "      adb install $apkPath\app-release.apk" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Compartir APK:" -ForegroundColor White
    Write-Host "      - Subir a Google Drive" -ForegroundColor Gray
    Write-Host "      - Enviar por email" -ForegroundColor Gray
    Write-Host "      - Publicar en Play Store" -ForegroundColor Gray
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "❌ Error al generar APK" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Soluciones comunes:" -ForegroundColor Yellow
    Write-Host "   1. Ejecutar: flutter doctor" -ForegroundColor White
    Write-Host "   2. Verificar Android SDK instalado" -ForegroundColor White
    Write-Host "   3. Verificar Java JDK instalado" -ForegroundColor White
    Write-Host "   4. Limpiar caché: flutter clean" -ForegroundColor White
    Write-Host ""
    exit 1
}
