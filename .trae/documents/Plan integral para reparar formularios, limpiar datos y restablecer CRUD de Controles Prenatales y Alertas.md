## Diagnóstico
- Formularios desalineados con backend:
  - Control simplificado usa `fecha`/`descripcion` en `lib/features/controles/presentation/pages/control_form_page.dart:25-39`; backend exige `gestante_id` y `fecha_control` (`src/controllers/control.controller.ts:54-73`).
  - Alerta simplificada usa `titulo`/`descripcion` en `lib/features/alertas/presentation/pages/alerta_form_page.dart:25-35`; backend exige `gestante_id`, `tipo_alerta`, `nivel_prioridad`, `mensaje` (`src/controllers/alerta.controller.ts:156-173`).
  - `AlertaServiceSimple` envía camelCase (`gestanteId`, `tipoAlerta`) (`lib/data/services/alerta_service_simple.dart:72-83`), no coincide con snake_case del backend.
- Reportes: control de permisos actual solo permite ADMIN/SUPER_ADMIN/COORDINADOR (`src/controllers/reporte.controller.ts:21-26`), bloquea MADRINA.
- CRUD backend operativo en rutas: controles (`src/routes/controles.routes.ts:102-146`), alertas (`src/routes/alertas.routes.ts:26-39`).

## Limpieza de datos (SQL)
- Control prenatal:
  - `DELETE FROM public.control_prenatal WHERE gestante_id IS NULL OR fecha_control IS NULL;`
  - `UPDATE public.control_prenatal SET semanas_gestacion = COALESCE(semanas_gestacion, 0), peso = COALESCE(peso, 0), altura_uterina = COALESCE(altura_uterina, 0), presion_sistolica = COALESCE(presion_sistolica, 0), presion_diastolica = COALESCE(presion_diastolica, 0), frecuencia_cardiaca = COALESCE(frecuencia_cardiaca, 0), frecuencia_respiratoria = COALESCE(frecuencia_respiratoria, 0), temperatura = COALESCE(temperatura, 0), movimientos_fetales = COALESCE(movimientos_fetales, ''), edemas = COALESCE(edemas, ''), proteinuria = COALESCE(proteinuria, ''), glucosuria = COALESCE(glucosuria, ''), recomendaciones = COALESCE(recomendaciones, ''), observaciones = COALESCE(observaciones, ''), examenes_solicitados = COALESCE(examenes_solicitados, '[]'::jsonb), resultados_examenes = COALESCE(resultados_examenes, '[]'::jsonb), proximo_control = COALESCE(proximo_control, CURRENT_TIMESTAMP), fecha_actualizacion = COALESCE(fecha_actualizacion, CURRENT_TIMESTAMP);`
- Alertas:
  - `DELETE FROM public.alertas WHERE gestante_id IS NULL OR tipo_alerta IS NULL OR nivel_prioridad IS NULL OR mensaje IS NULL;`
  - `UPDATE public.alertas SET sintomas = COALESCE(sintomas, '[]'::jsonb), coordenadas_alerta = COALESCE(coordenadas_alerta, '{}'::jsonb), estado = COALESCE(estado, 'pendiente'), created_at = COALESCE(created_at, CURRENT_TIMESTAMP), fecha_actualizacion = COALESCE(fecha_actualizacion, CURRENT_TIMESTAMP), nombre_madrina = COALESCE(nombre_madrina, ''), telefono_madrina = COALESCE(telefono_madrina, ''), nombre_gestante = COALESCE(nombre_gestante, ''), telefono_gestante = COALESCE(telefono_gestante, ''), direccion_gestante = COALESCE(direccion_gestante, ''), municipio = COALESCE(municipio, ''), ubicacion_lat = COALESCE(ubicacion_lat, 0), ubicacion_lng = COALESCE(ubicacion_lng, 0), ubicacion_precision = COALESCE(ubicacion_precision, 0), score_riesgo = COALESCE(score_riesgo, 0);`

## Ajustes de permisos y filtros de Reportes
- Backend:
  - Incluir `MADRINA` en `validarPermisosReportes` (`src/controllers/reporte.controller.ts:21-26`) y filtrar resultados:
    - SUPER_ADMIN/ADMIN: ven todo.
    - COORDINADOR: datos de madrinas asignadas.
    - MADRINA: solo sus gestantes y alertas/controles asociados.
  - Aprovechar filtros existentes del repositorio (`madrina_id` ya soportado en `src/infrastructure/repositories/reporte.repository.impl.ts:28-35`).
- Frontend:
  - Habilitar acceso al módulo de reportes para todos los roles; mostrar datasets según rol.

## Formularios Flutter (alineación y validación)
- Control Prenatal:
  - Unificar el formulario simplificado con el mejorado:
    - Usar `gestante_id`, `fecha_control` y campos clínicos en `lib/presentation/pages/control/control_form_screen.dart:149-191`.
    - Eliminar/actualizar `lib/features/controles/presentation/pages/control_form_page.dart:25-39` para usar snake_case.
  - Validaciones UI alineadas con backend.
- Alertas:
  - Actualizar `lib/features/alertas/presentation/pages/alerta_form_page.dart:25-35` para solicitar `gestante_id`, `tipo_alerta`, `nivel_prioridad`, `mensaje`.
  - Adaptar `AlertaServiceSimple` para mapear camelCase→snake_case antes de POST/PUT (`lib/data/services/alerta_service_simple.dart:72-83`).
  - Mostrar selectores (gestante, tipo de alerta, prioridad) y validar requeridos.

## Asignación Madrinas↔Coordinadores (nuevo)
- Backend:
  - Crear tabla de relación `coordinadores_madrinas (coordinador_id, madrina_id, fecha_asignacion)` con FKs a `usuarios`.
  - Endpoints:
    - `GET /api/asignaciones/madrinas` (listar por coordinador/admin).
    - `POST /api/asignaciones/madrinas` (asignar/desasignar), protegido con `requireAdmin()` (`src/middlewares/role.middleware.ts:149-151`).
  - Servicios/Repositorio: implementar consultas y validaciones.
- Frontend:
  - Nueva pantalla de administración: `Asignar Madrinas a Coordinador`.
  - Solo visible para SUPER_ADMIN/ADMIN; botón en dashboard de administración.
  - Selección de coordinador y listado de madrinas (multiselección), persistencia vía endpoints anteriores.

## Inserción de registros completos de prueba
- Resolver IDs:
  - Madrina: `SELECT id FROM public.usuarios WHERE email = 'crepu@gmail.com';`
  - Gestante: `SELECT id FROM public.gestantes WHERE nombre ILIKE 'Marylin monroe';`
- Insertar `control_prenatal` y `alertas` con todos los campos válidos, vinculando a esos IDs.

## Verificación CRUD end-to-end
- Backend: probar `POST/GET/PUT/DELETE` en controles y alertas; validar reportes para cada rol.
- Frontend: crear/editar/eliminar desde formularios; verificar listas y reportes; autenticar como cada rol para confirmar filtros.

¿Autorizas ejecutar este plan para corregir formularios, limpiar datos, ajustar permisos de reportes y crear la asignación Madrinas↔Coordinadores con visibilidad restringida a administración?