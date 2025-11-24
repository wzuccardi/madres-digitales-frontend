# Script para corregir imports rotos
# Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "=== CORRECTOR DE IMPORTS ROTOS ===" -ForegroundColor Cyan
Write-Host ""

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notlike "*build*" -and 
    $_.FullName -notlike "*.dart_tool*" -and
    $_.FullName -notlike "*backup*"
}

Write-Host "Encontrados $($dartFiles.Count) archivos .dart" -ForegroundColor White
Write-Host ""

$changesCount = 0
$filesModified = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Corrección 1: providers/service_providers.dart -> presentation/providers/service_providers.dart
    if ($content -match "import\s+['""].*providers/service_providers\.dart['""]") {
        $content = $content -replace "import\s+(['""])(.*)providers/service_providers\.dart", "import `$1`$2presentation/providers/service_providers.dart"
        $changesCount++
    }
    
    # Corrección 2: services/api_service.dart -> core/network/api_service.dart
    if ($content -match "import\s+['""].*services/api_service\.dart['""]") {
        $content = $content -replace "import\s+(['""])(.*)services/api_service\.dart", "import `$1`$2core/network/api_service.dart"
        $changesCount++
    }
    
    # Corrección 3: ../../core/usecase.dart -> ../../core/usecases/usecase.dart
    if ($content -match "import\s+['""].*core/usecase\.dart['""]") {
        $content = $content -replace "(['""])(.*)core/usecase\.dart", "`$1`$2core/usecases/usecase.dart"
        $changesCount++
    }
    
    # Corrección 4: ../../core/errors/failures.dart -> ../../core/errors/app_error.dart
    if ($content -match "import\s+['""].*core/errors/failures\.dart['""]") {
        $content = $content -replace "(['""])(.*)core/errors/failures\.dart", "`$1`$2core/errors/app_error.dart"
        $changesCount++
    }
    
    # Corrección 5: ../entities/gestante.dart -> Verificar si existe o usar package import
    if ($content -match "import\s+['""]\.\.\/entities\/gestante\.dart['""]") {
        # Cambiar a package import absoluto
        $content = $content -replace "import\s+['""]\.\.\/entities\/gestante\.dart['""]", "import 'package:madres_digitales_flutter_new/features/gestante/domain/entities/gestante.dart'"
        $changesCount++
    }
    
    # Corrección 6: ../repositories/gestante_repository.dart -> package import
    if ($content -match "import\s+['""]\.\.\/repositories\/gestante_repository\.dart['""]") {
        $content = $content -replace "import\s+['""]\.\.\/repositories\/gestante_repository\.dart['""]", "import 'package:madres_digitales_flutter_new/features/gestante/domain/repositories/gestante_repository.dart'"
        $changesCount++
    }
    
    # Corrección 7: ../../domain/entities/user.dart -> Verificar ubicación correcta
    if ($content -match "import\s+['""].*domain/entities/user\.dart['""]") {
        $content = $content -replace "import\s+['""].*domain/entities/user\.dart['""]", "import 'package:madres_digitales_flutter_new/features/auth/domain/entities/user.dart'"
        $changesCount++
    }
    
    # Corrección 8: ../repositories/user_repository.dart
    if ($content -match "import\s+['""]\.\.\/repositories\/user_repository\.dart['""]") {
        $content = $content -replace "import\s+['""]\.\.\/repositories\/user_repository\.dart['""]", "import 'package:madres_digitales_flutter_new/features/auth/domain/repositories/user_repository.dart'"
        $changesCount++
    }
    
    # Si hubo cambios, guardar el archivo
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $filesModified++
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== RESUMEN ===" -ForegroundColor Cyan
Write-Host "Archivos procesados: $($dartFiles.Count)" -ForegroundColor White
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total de cambios: $changesCount" -ForegroundColor Green
Write-Host ""
Write-Host "Ejecutando flutter analyze..." -ForegroundColor Yellow

# Contar errores antes y después
$errorsBefore = (flutter analyze 2>&1 | Select-String "^\s+error" | Where-Object { $_ -notmatch "backup" }).Count

Write-Host ""
Write-Host "Errores restantes (sin backups): $errorsBefore" -ForegroundColor $(if ($errorsBefore -lt 2500) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Proceso completado!" -ForegroundColor Cyan
