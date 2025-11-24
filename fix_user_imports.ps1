# Script para corregir imports de User a la ubicación correcta
Write-Host "=== CORRECTOR DE IMPORTS DE USER ===" -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | Where-Object {
    $_.FullName -notlike "*build*" -and 
    $_.FullName -notlike "*.dart_tool*" -and
    $_.FullName -notlike "*backup*"
}

$changesCount = 0

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    
    # Corregir import incorrecto de User
    if ($content -match "import\s+['""]package:madres_digitales_flutter_new/features/auth/domain/entities/user\.dart['""]") {
        $content = $content -replace "import\s+['""]package:madres_digitales_flutter_new/features/auth/domain/entities/user\.dart['""]", "import 'package:madres_digitales_flutter_new/domain/entities/user.dart'"
        $changesCount++
    }
    
    # Corregir imports relativos de User
    if ($content -match "import\s+['""].*domain/entities/user\.dart['""]" -and $content -notmatch "package:madres_digitales_flutter_new/domain/entities/user\.dart") {
        $content = $content -replace "import\s+['""].*domain/entities/user\.dart['""]", "import 'package:madres_digitales_flutter_new/domain/entities/user.dart'"
        $changesCount++
    }
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        Write-Host "[OK] $($file.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Cambios realizados: $changesCount" -ForegroundColor Green
