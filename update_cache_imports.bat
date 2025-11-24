@echo off
echo 🔄 Actualizando imports de cache_service a CacheManager...

REM Crear directorio de backup si no existe
if not exist "lib\redundancia" mkdir lib\redundancia

REM Hacer backup de archivos cache_service
for /r "lib\*cache_service*.dart" do (
    echo 📁 Backing up: %%f
    copy "%%f" "lib\redundancia\" >nul
)

REM Buscar y reemplazar imports
for /r "lib\*.dart" do (
    findstr /i "import '../services/cache_service.dart'" "%%f" >nul
    if !errorlevel 1 (
        echo 📝 Reemplazando en: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../services/cache_service.dart', 'import '../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../core/providers/cache_provider.dart'" "%%f" >nul
        if !errorlevel 1 (
            echo ✅ Reemplazo exitoso en: %%f
        ) else (
            echo ❌ Error en reemplazo en: %%f
        )
    )
    
    findstr /i "import '../../services/cache_service.dart'" "%%f" >nul
    if !errorlevel 1 (
        echo 📝 Reemplazando en: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../../services/cache_service.dart', 'import '../../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../../core/providers/cache_provider.dart'" "%%f" >nul
        if !errorlevel 1 (
            echo ✅ Reemplazo exitoso en: %%f
        ) else (
            echo ❌ Error en reemplazo en: %%f
        )
    )
    
    findstr /i "import '../../../services/cache_service.dart'" "%%f" >nul
    if !errorlevel 1 (
        echo 📝 Reemplazando en: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../../../services/cache_service.dart', 'import '../../../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../../../core/providers/cache_provider.dart'" "%%f" >nul
        if !errorlevel 1 (
            echo ✅ Reemplazo exitoso en: %%f
        ) else (
            echo ❌ Error en reemplazo en: %%f
        )
    )
    
    REM Reemplazar instancias de CacheService
    findstr /i "CacheService(" "%%f" >nul
    if !errorlevel 1 (
        echo 📝 Reemplazando instancias en: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'CacheService(', 'CacheManager(' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "CacheManager(" "%%f" >nul
        if !errorlevel 1 (
            echo ✅ Reemplazo de instancias exitoso en: %%f
        ) else (
            echo ❌ Error en reemplazo de instancias en: %%f
        )
    )
)

echo.
echo 📊 Resumen:
echo    🔄 Migración de cache_service completada
echo    📁 Archivos cache_service respaldados en lib\redundancia
echo    📝 Imports actualizados a CacheManager
pause