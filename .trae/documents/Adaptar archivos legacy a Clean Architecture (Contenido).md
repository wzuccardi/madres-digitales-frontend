## Alcance
- Depurar los 3 archivos legacy de BLoC de Contenido, eliminando simulaciones y actualizaciones locales, conservando contratos útiles.
- Mantener y visibilizar los signos/síntomas de alarma y validaciones en Controles, ya presentes en `ControlPrenatalMejoradoScreen`.
- Actualizar el Dashboard para reflejar alertas por prioridad y próximos controles, sin modificar configuraciones ni rutas.

## Cambios
1) Contenido (legacy BLoC):
- Eliminar `getCategorias()` simulado y los mapeos de `Update/Delete` locales; dejar solo eventos que llaman casos de uso reales.
- No tocar `contenido_provider.dart` ni `application/providers/contenido_notifier.dart` (ya integran Clean Architecture).

2) Dashboard:
- Consumir providers existentes de alertas para mostrar conteos por prioridad y badge de críticas.
- Mostrar resumen de próximos controles y urgencia basada en días, alineado con FASE2.

## Validación
- Navegación y carga de datos en Contenido usando Riverpod.
- Flujo de Control Prenatal con síntomas/umbrales y evaluación automática.
- Dashboard con conteos de alertas y próximos controles actualizándose.

## Sin Cambios de Configuración
- Mantener `RouteNames`, `AppRouter`, seguridad por rol y endpoints actuales.