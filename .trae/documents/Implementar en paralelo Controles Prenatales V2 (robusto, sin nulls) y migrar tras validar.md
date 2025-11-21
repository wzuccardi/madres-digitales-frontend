## Objetivo
- Crear una versión V2 del flujo de Controles Prenatales que consuma el JSON actual directamente, con mapeo tolerante a null y sin operadores de null peligrosos.
- Integrarla en rutas paralelas para validación sin afectar producción.
- Una vez verificada end-to-end, reemplazar las pantallas y servicios legacy por la nueva implementación.

## Alcance
- Listado V2 de controles prenatales
- Detalle V2 sincrónico con tolerancia a campos faltantes
- Formulario V2 de creación/edición con snake_case y selector de gestante
- Servicio/Mapper dedicados V2 (DTO + mapper robusto)
- Vista de depuración para inspección del JSON crudo

## Implementación
1. Servicio y Mapper V2
- Crear `lib/features/controles_v2/data/control_api_v2.dart` con métodos:
  - `fetchControles(): Future<List<ControlDto>>`
  - `fetchControl(id): Future<ControlDto>`
- Crear `lib/features/controles_v2/data/control_mapper_v2.dart`:
  - Función `mapJsonToDto(Map json)` usando claves snake_case del backend (`gestante_id`, `fecha_control`, `semanas_gestacion`...), aplicando `?.toString()`/`tryParse` y defaults seguros.
- Crear `lib/features/controles_v2/domain/control_dto.dart` (campos opcionales por defecto, sin `!`).

2. UI V2 (List/Detail)
- Crear `lib/features/controles_v2/presentation/controles_list_v2_page.dart`:
  - Carga con `ControlApiV2.fetchControles()`.
  - Render en `ListView.builder` con fechas (`fecha_control`), observaciones y resumen clínico; sin usar `!`.
  - Botón “Ver JSON” (abre un `Dialog` con pretty-print del objeto para depurar datos reales).
- Crear `lib/features/controles_v2/presentation/control_detail_v2_page.dart`:
  - Recibe `ControlDto` y muestra datos tolerantes a nulos.

3. Formulario V2
- Crear `lib/features/controles_v2/presentation/control_form_v2_page.dart`:
  - Selector de gestante (carga con `getGestantesUseCaseProvider`).
  - Campos en snake_case: `fecha_control`, `semanas_gestacion`, `peso`, `presion_sistolica`, `presion_diastolica`, etc.
  - Envío POST a `/controles` y `/controles/con-evaluacion` (toggle evaluación) con payload snake_case.
  - Validaciones de rango clínico y `FormState?.validate()` sin `!`.

4. Router paralelo
- Registrar ruta: `'/controles-v2'` → `ControlesListV2Page`.
- Registrar ruta: `'/controles-v2/nuevo'` → `ControlFormV2Page`.
- Añadir card “Controles V2 (beta)” visible para admin/super_admin en dashboard.

5. Instrumentación de errores
- Envolver `ControlesListV2Page` con `ErrorBoundary` (ya existente) para capturar trace si ocurre error.
- Loggear cada excepción con el JSON del ítem que la causó para corrección rápida.

6. Verificación end-to-end
- Navegar a `#/controles-v2`, confirmar listado; abrir detalles.
- Crear nuevo control en `#/controles-v2/nuevo`, verificar que aparece en listado y en backend.
- Validar que “Null check operator used on a null value” no aparece bajo ninguna acción.

7. Migración definitiva
- Cuando V2 esté estable:
  - Redirigir `AppConstants.controlsRoute` a `'/controles-v2'`.
  - Eliminar o archivar `controles_screen.dart` y `control_form_screen.dart` legacy.
  - Mantener `control_prenatal_mejorado_screen.dart` solo si añade valor exclusivo; si V2 lo reemplaza, consolidar en V2.

## Entregables
- Servicio V2, Mapper y DTO con tolerancia a null.
- Lista/Detalle/Formulario V2 en rutas paralelas.
- Botón de acceso en dashboard para pruebas.
- Plan de migración y checklist de retirada de legacy.

¿Autorizas que implemente esta versión paralela V2, la integre al router y dashboard para validación, y tras confirmar funcionamiento, reemplace el flujo actual? 