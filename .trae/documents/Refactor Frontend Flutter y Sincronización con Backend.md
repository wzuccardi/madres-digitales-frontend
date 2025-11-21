## Objetivo
Alinear el frontend Flutter (Riverpod) con el backend Node/TypeScript, eliminando duplicaciones legacy y corrigiendo login/CRUD para una sincronización estable y verificable.

## Principios
- Mantener backend actual y contratos: `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/profile`.
- Centralizar HTTP en Dio y `ApiService`; respuesta uniforme con `ApiResponse`.
- Tokens solo en `SecureStorage`; nada sensible en `SharedPreferences`.
- Arquitectura por features: `lib/features/*` con `data/domain/presentation`.

## Fase 1: Autenticación y Cliente HTTP
- Corregir endpoints de auth en frontend:
  - Reemplazar `/auth/me` por `/auth/profile` en `lib/data/repositories/auth_repository_impl.dart:132`.
  - Eliminar `/auth/refresh-token` y `/auth/validate-token` en `lib/data/services/auth_service.dart:142-151`, `lib/data/services/auth_service.dart:108-115`.
- Fix almacenamiento de tokens:
  - `clearTokens()` debe borrar también `SharedPreferences` y retirar fallback de tokens en interceptor (`lib/core/network/api_service.dart:137-145`, `lib/core/network/api_service.dart:543-551`).
- Unificar cliente HTTP:
  - Retirar `authenticatedRequest` (http.Client) y migrar llamadas a `dio.request` (`lib/core/network/api_service.dart:591-651`).
- Verificación:
  - Flujo completo login/refresh/logout/profile contra backend; asegurar que no quedan tokens en `SharedPreferences`.

## Fase 2: Consolidación por Features
- Migrar pantallas legacy `lib/presentation/pages/*` a `lib/features/*/presentation/*`.
- Consolidar repos/datasources en `lib/features/*/data/*` e interfaces en `lib/features/*/domain/*`.
- Unificar modelos en `lib/features/*/data/models` y entidades en `lib/features/*/domain/entities`; retirar duplicados en `lib/models` y `lib/data/models`.
- Normalizar providers Riverpod:
  - DI de servicios/repos/usecases en `lib/core/providers/*`.
  - Providers por feature en `lib/features/*/presentation/providers/*`.

## Fase 3: CRUD alineado
- Mapear endpoints y formatos (`success/data/error/meta`) por módulo: Contenido, Gestantes, Alertas, Controles, Municipios, Usuarios, IPS, Médicos.
- Estandarizar paginación, filtros y manejo de errores con `ApiResponse.fromDioResponse`.
- Ajustar modelos/mappers por feature para reflejar el contrato del backend.

## Fase 4: Estado, Cache y Offline
- Reforzar `NetworkInfo` y política de cache por feature (cachear lista/detalle, invalidar por TTL).
- Implementar colas de sincronización diferida en datasources locales (ej.: favoritos/progreso en Contenido), siguiendo patrón ya presente en `ContenidoRepositoryImpl` (`lib/features/contenido/data/repositories/contenido_repository_impl.dart:233-327`).
- Eliminar providers duplicados (SOS/Report) manteniendo uno por feature.

## Fase 5: Observabilidad y Endurecimiento
- Logging sólo en local (`AppConfig.shouldEnableLogging()`), tiempos de espera y reintentos (`retryRequest`) en `ApiService`.
- Métricas básicas por endpoint (conteo de errores y latencias en logs) y pruebas de integración de frontend para auth y CRUD críticos.

## Entregables
- Auth estable y alineada con backend.
- Estructura por features sin dependencias legacy (`lib/data/*`, `lib/presentation/*` retirados).
- CRUD funcionando con paginación/filtros y manejo de errores uniforme.
- Cache/Offline con sincronización diferida.
- Suite mínima de pruebas y métricas locales.

## Estimación
- Fase 1: 1–2 días
- Fase 2: 3–5 días
- Fase 3: 2–4 días
- Fase 4: 2–3 días
- Fase 5: 1–2 días

## Riesgos & Mitigación
- Roturas por retiro de legacy → migración gradual por feature con toggles y pruebas.
- Formatos heterogéneos → parseo uniforme en `ApiResponse` y validación por módulo.
- Estados incoherentes → providers únicos por feature y DI consistente.

Confirma para iniciar ejecución y preparar el backlog detallado por tareas por feature con criterios de aceptación y verificación.