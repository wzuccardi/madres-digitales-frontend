# Script para reemplazar todos los iconos de iOS con el logo de la aplicación
$logoPath = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\assets\images\logo.png"
$iconsPath = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\ios\Runner\Assets.xcassets\AppIcon.appiconset"

# Obtener todos los archivos PNG en la carpeta de iconos
$pngFiles = Get-ChildItem -Path $iconsPath -Filter "*.png"

Write-Host "Reemplazando $($pngFiles.Count) iconos de iOS con el logo de la aplicación..."

foreach ($file in $pngFiles) {
    Copy-Item -Path $logoPath -Destination $file.FullName -Force
    Write-Host "Reemplazado: $($file.Name)"
}

Write-Host "¡Todos los iconos de iOS han sido reemplazados exitosamente!"