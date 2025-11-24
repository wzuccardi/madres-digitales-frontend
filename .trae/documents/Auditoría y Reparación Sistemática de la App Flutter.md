## Objetivo
Revisar toda la aplicación, identificar problemas funcionales/compilación y corregirlos de manera sistemática sin modificar la lógica de negocio.

## Hallazgos Clave (con rutas y líneas)
- Uso de `Color.withValues` no estándar en múltiples archivos → puede fallar en Flutter >=3.10 si no está disponible:
  - Ejemplos: `lib/presentation/pages/dashboard/dashboard_page.dart:533, 629`, `lib/presentation/widgets/layout/main_layout.dart:175-180`, `lib/features/contenido/presentation/widgets/*`, `lib/features/gestante/presentation/pages/*`, `lib/presentation/pages/home/*`.
- Página de Conflictos de Sync usa métodos inexistentes en `OfflineService`:
  - `lib/presentation/pages/settings/sync_conflicts_page.dart` llama `offline.getConflicts()`, `resolveConflictLocal()`, `resolveConflictRemote()` que no existen en `lib/data/services/offline_service.dart`.
- Redirect global en GoRouter podría leer providers demasiado pronto:
  - `lib/core/router/app_router.dart:31-53` usa `ProviderScope.containerOf(context)` dentro de `redirect`; riesgo si el container no está listo.
- Mensajería con lógica incorrecta para mensajes propios y TODO sin resolver:
  - `lib/presentation/pages/home/mensajes_screen.dart:385` usa `remitenteId == destinatarioId` para identificar mensaje propio (debería comparar con usuario actual).
  - TODOs: `lib/presentation/pages/home/mensajes_screen.dart:179`, `lib/presentation/pages/home/sos_screen.dart:116`.
- Placeholder restante:
  - `lib/core/router/app_router.dart:353` “Acerca de Screen - Pendiente de implementar”.
- Búsqueda avanzada presente pero sin filtros completos:
  - `lib/presentation/pages/contenido/contenido_advanced_search_page.dart` solo busca por texto.
- Integración de Firebase Messaging parcial (falta background handler y configuración web si aplica):
  - `pubspec.yaml:34` habilitado; `NotificationService` integra `onMessage` pero no `onBackgroundMessage`.

## Plan de Reparación
1. Compatibilidad de colores
- Reemplazar `Color.withValues(alpha: x)` por `Color.withOpacity(x)` y variantes seguras en todos los archivos afectados.
- Verificar gradientes y bordes para mantener UI.

2. OfflineService: Conflictos de sync
- Añadir API mínima: `getConflicts()`, `resolveConflictLocal(conflict)`, `resolveConflictRemote(conflict)` y almacenamiento en `SharedPreferences`.
- Ajustar `SyncConflictsPage` para manejar lista vacía y errores.

3. GoRouter redirect
- Sustituir lectura directa con `containerOf` por una función segura que tolera ausencia y usa rutas públicas; fallback a login solo si container disponible; o mover redirect a un `redirect` por ruta crítica con `RouteGuard` ya implementado.

4. Mensajería
- Integrar `authProvider` para obtener `currentUserId` y comparar remitente con el usuario actual.
- Implementar badge de no leídos (resolviendo TODO) con `obtenerEstadisticas()` y actualización en stream.
- Resolver TODO en `sos_screen.dart` leyendo `gestanteId` desde sesión.

5. Placeholder de Acerca de
- Implementar `AboutPage` simple enlazada a la ruta en router.

6. Búsqueda avanzada
- Extender `ContenidoAdvancedSearchPage` con filtros de categoría/tipo/nivel usando `ContenidoController`.
- Agregar paginación y favoritos.

7. Firebase Messaging
- Añadir `onBackgroundMessage` handler seguro y gating por plataforma; documentar claves y configuración web si se requiere push web.

## Validación
- Ejecutar `flutter analyze` y corregir warnings.
- Smoke de navegación por rol (RouteGuard), login/logout, notificaciones locales, mensajes en tiempo real, búsqueda avanzada y resolución de conflictos offline.

## Entregables
- Lista de fixes aplicados, archivos y líneas cambiadas.
- Resultados de análisis sin errores y pruebas de smoke exitosas.

¿Procedo a aplicar las correcciones descritas?