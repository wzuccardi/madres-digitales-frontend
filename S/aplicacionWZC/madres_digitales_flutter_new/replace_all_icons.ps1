# Script para reemplazar todos los iconos con el logo correcto
$correctLogoPath = "c:\Madrinas\S\genio\1763690386.png"

Write-Host "Reemplazando todos los iconos con el logo correcto..."

# 1. Favicon web
$webFavicon = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\web\favicon.png"
if (Test-Path $webFavicon) {
    Copy-Item -Path $correctLogoPath -Destination $webFavicon -Force
    Write-Host "✓ Favicon web reemplazado"
}

# 2. Iconos web
$webIcons = @(
    "Icon-192.png",
    "Icon-512.png", 
    "Icon-maskable-192.png",
    "Icon-maskable-512.png"
)

foreach ($icon in $webIcons) {
    $iconPath = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\web\icons\$icon"
    if (Test-Path $iconPath) {
        Copy-Item -Path $correctLogoPath -Destination $iconPath -Force
        Write-Host "✓ Icono web $icon reemplazado"
    }
}

# 3. Iconos Android
$androidDensities = @("hdpi", "mdpi", "xhdpi", "xxhdpi", "xxxhdpi")
foreach ($density in $androidDensities) {
    $androidIconPath = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\android\app\src\main\res\mipmap-$density\ic_launcher.png"
    if (Test-Path $androidIconPath) {
        Copy-Item -Path $correctLogoPath -Destination $androidIconPath -Force
        Write-Host "✓ Icono Android $density reemplazado"
    }
}

# 4. Iconos iOS
$iosIconsPath = "c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\ios\Runner\Assets.xcassets\AppIcon.appiconset"
if (Test-Path $iosIconsPath) {
    $iosPngFiles = Get-ChildItem -Path $iosIconsPath -Filter "*.png"
    foreach ($file in $iosPngFiles) {
        Copy-Item -Path $correctLogoPath -Destination $file.FullName -Force
        Write-Host "✓ Icono iOS $($file.Name) reemplazado"
    }
}

Write-Host "¡Todos los iconos han sido reemplazados con el logo correcto!"
Write-Host "Logo utilizado: $correctLogoPath"