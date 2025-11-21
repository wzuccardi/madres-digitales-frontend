## Objetivo
Dejar el proyecto Flutter libre de errores de análisis y con builds que compilen, corrigiendo issues de código y regeneraciones necesarias.

## Preparación del entorno
- Usar `C:\madrinas\aplicacionWZC\madres_digitales_flutter_new` (Terminal 2/4) para todas las acciones.
- Ejecutar `flutter pub get` para asegurar dependencias y `flutter clean` si es necesario.
- Confirmar `analysis_options.yaml` y sus exclusiones ya presentes.

## Análisis estático
- Ejecutar `flutter analyze` para obtener el estado actual real (no usar el `analyze_output.txt` histórico).
- Si el analizador reporta scripts de tooling (p.ej. `fix_*`, `consolidate_*`), verificar exclusiones y ajustar rutas para que queden fuera del análisis.

## Corrección de errores
- Priorizar errores en `lib/**`: imports rotos, tipos indefinidos, métodos faltantes.
- Reemplazar usos de `print` por el logger del proyecto (`lib/core/utils/app_logger.dart`), solo cuando aparezcan en código de app.
- Normalizar interfaces/implementaciones en `domain/**` vs `data/**` cuando el analizador marque inconsistencias.

## Regeneración de código
- Ejecutar `dart run build_runner build --delete-conflicting-outputs` para sincronizar `*.g.dart` y modelos Freezed/JsonSerializable.
- Revisar que los `part '...g.dart'` en `lib/**` coincidan con archivos generados (ya existen varios `*.g.dart`).

## Pruebas
- Ejecutar `flutter test` (hay tests en `test/**`) y corregir fallos de lógica o mocks.
- Asegurar que las pruebas clave pasen: `features/contenido/*`, servicios y utilidades.

## Compilación por plataformas
- Web: `flutter build web` para validar compilación rápida.
- Windows: `flutter build windows` (si habilitado) para detectar issues de plugin en desktop.
- Android: `flutter build apk` (debug/release según sea necesario); revisar `android/` y plugins (`file_picker`, `camera`, etc.).
- Ignorar warnings de plugins como el default package de `file_picker` si no bloquean la compilación.

## Verificación y entrega
- Repetir ciclo `analyze → fix → build → test` hasta cero errores.
- Documentar cambios de código realizados y comandos ejecutados.
- Entregar resumen con estado: análisis sin errores, pruebas pasando y build exitoso en al menos una plataforma (web y Android).