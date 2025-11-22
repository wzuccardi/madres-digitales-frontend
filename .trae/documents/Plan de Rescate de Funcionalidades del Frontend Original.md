## Objetivo
Tomar el frontend original como referencia para complementar y mejorar los módulos existentes en la app Flutter con arquitectura limpia, sin migrar código; incorporar en tiempo real alertas por creación de controles y ampliar el dashboard.

## Puntos de Integración Clave (con referencias)
- WebSockets para tiempo real: `lib/core/network/websocket_service.dart` (suscripción y emisión de eventos)
- Rutas/UI pendientes: `lib/core/router/app_router.dart:269-339` (perfil, notificaciones, ayuda, reset/forgot)
- Autenticación y permisos: `lib/presentation/providers/auth_provider.dart` (login/refresh/roles/permisos)
- Datos y servicios de negocio: `lib/data/services/*` y `lib/domain/usecases/*`
- Config de API/entornos: `lib/config/app_config.dart:9-19`, `lib/core/constants/app_constants.dart:10-13`

## Módulos a Complementar
1. Alertas en Tiempo Real por Control
- Backend: emitir evento socket `control:created` y/o `alertas:new` al crear un control.
- Cliente: conectar WebSocket derivado de `AppConfig.apiBaseUrl` (quita `/api` y usa `ws/wss`), suscribir a `control:created`.
- Actualizar estado (provider/bloc de alertas): insertar alerta y disparar notificación in-app.
- Fallback: polling con `ApiService.get('/alertas')` si `WebSocketService.isConnected` es falso.

2. Dashboard Ampliado por Rol
- KPIs: gestantes, controles recientes, alertas activas, actividad por municipio/IPS.
- Widgets por rol (madrina/médico/coordinador/admin/super_admin), usando `AuthProvider` y `AppConfig.roles`.
- Datos: integrar `data/services/dashboard_service.dart` y modelos `lib/data/models/dashboard_model.dart`.
- Activación gradual: `AppConfig.enableNewDashboard`.

3. Contenido (Búsqueda/Progreso/Favoritos)
- Búsqueda avanzada y filtros (categorías, texto, tipo); `features/contenido/domain/usecases/*`.
- Favoritos y progreso persistente; reproductores audio/video con cache.
- Modo offline y sincronización: `contenido_sync_service.dart`, `web_cache_service.dart`.

4. Controles v2
- Formularios completos, validaciones, listas por gestante; `features/controles_v2/*`.
- Emisión de eventos hacia alertas en tiempo real.

5. Alertas/SOS
- Dashboard de alertas (completo), filtros por prioridad/estado.
- Notificaciones in-app y push (ver módulo de notificaciones). Integrar con `sos_compatibility_service`.

6. Notificaciones
- In-app: banners/toasts para eventos socket.
- Push: `core/firebase/*` para web/móvil, `notification_service.dart`.
- Preferencias de usuario y canal `AppConfig.notification*`.

7. Mensajería
- Suscripción socket a canales de conversación y actualización en `MensajesScreen`.
- Estadísticas de mensajería del dominio.

8. Administración (Usuarios/Municipios/IPS/Médicos)
- Completar CRUD y rutas (`/usuarios*`, `/municipios-admin`, `/ips*`, `/medicos*`).
- Guardas y permisos por rol.

9. Reportes
- Filtros avanzados y exportación CSV/PDF/Excel usando `core/services/*_generator_service.dart`.

## Infraestructura y Navegación
- Rehabilitar redirects por sesión (`app_router.dart:341`) tras estabilizar login.
- Añadir pantallas reales para placeholders (perfil, notificaciones, ayuda, about, forgot/reset) y enlazar a rutas `AppConstants.*Route`.

## Seguridad/Permisos
- Aplicar `AuthProvider.tienePermisoGeneral` y `tienePermisoSobreGestante` en UI y acciones.
- Validar servidor y cache de permisos con expiración (5 min).

## Observabilidad y Rendimiento
- Instrumentar logs/times con `core/monitoring/*` y `AppLogger`.
- Métricas en dashboard y procesos de sync.

## Entornos/Config
- Unificar `API_URL` y `.env BACKEND_URL` (usar `/api`), asegurar `AppConstants.apiBaseUrl` apunta correcto.
- Activación por flags: `enableNewDashboard`, `enableAdvancedSearch`, `enableOfflineMode`.

## Validación
- Pruebas unitarias de casos de uso y repos.
- Integración: GoRouter (navegación), Riverpod/Bloc (estado), WebSocket (tiempo real).
- Smoke por rol y pruebas de regresión de funcionalidades añadidas.

## Entregables
- Funcionalidad de alertas en tiempo real al crear controles.
- Dashboard ampliado y role-aware.
- Mejoras en contenido, controles, alertas, notificaciones, mensajería y administración, con pruebas y observabilidad mínimas.
