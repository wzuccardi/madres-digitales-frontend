@echo off
echo Actualizando imports de cache_service a CacheManager...

REM Crear directorio de backup si no existe
if not exist "lib\redundancia" mkdir lib\redundancia

REM Hacer backup de archivos cache_service
for /r "lib\*cache_service*.dart" do (
    echo Backing up: %%f
    copy "%%f" "lib\redundancia\" >nul
)

REM Buscar y reemplazar imports
for /r "lib\*.dart" do (
    findstr /i "import '../services/cache_service.dart'" "%%f" >nul
    if not errorlevel 1 (
        echo Replacing in: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../services/cache_service.dart', 'import '../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../core/providers/cache_provider.dart'" "%%f" >nul
        if not errorlevel 1 (
            echo Replacement successful in: %%f
        ) else (
            echo Error in replacement: %%f
        )
    )
    
    findstr /i "import '../../services/cache_service.dart'" "%%f" >nul
    if not errorlevel 1 (
        echo Replacing in: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../../services/cache_service.dart', 'import '../../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../../core/providers/cache_provider.dart'" "%%f" >nul
        if not errorlevel 1 (
            echo Replacement successful in: %%f
        ) else (
            echo Error in replacement: %%f
        )
    )
    
    findstr /i "import '../../../services/cache_service.dart'" "%%f" >nul
    if not errorlevel 1 (
        echo Replacing in: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'import '../../../services/cache_service.dart', 'import '../../../core/providers/cache_provider.dart' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "import '../../../core/providers/cache_provider.dart'" "%%f" >nul
        if not errorlevel 1 (
            echo Replacement successful in: %%f
        ) else (
            echo Error in replacement: %%f
        )
    )
    
    REM Reemplazar instancias de CacheService
    findstr /i "CacheService(" "%%f" >nul
    if not errorlevel 1 (
        echo Replacing instances in: %%f
        powershell -Command "(Get-Content '%%f') -Replace 'CacheService(', 'CacheManager(' -Force)" >nul
        
        REM Verificar si el reemplazo fue exitoso
        findstr /i "CacheManager(" "%%f" >nul
        if not errorlevel 1 (
            echo Instance replacement successful in: %%f
        ) else (
            echo Error in instance replacement: %%f
        )
    )
)

echo.
echo Resumen:
echo    Files backed up: cache_service
echo    Imports updated to CacheManager
pause