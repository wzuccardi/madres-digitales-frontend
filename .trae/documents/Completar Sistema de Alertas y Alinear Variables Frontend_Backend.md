## Objetivo
- Completar la implementación de alertas manuales y automáticas, generadas en tiempo real y “semaforizadas” según valores críticos de síntomas y signos.
- Alinear nombres de variables entre frontend y backend para evitar 400/422.

## Estado Actual
- Backend `POST /alertas` exige: `gestante_id`, `tipo_alerta`, `nivel_prioridad`, `mensaje` (+ opcionales `sintomas`, `coordenadas_alerta`).
- Frontend `AlertaService.crearAlerta()` envía claves camelCase: `gestanteId`, `tipo`, `prioridad`, `mensaje`, etc. (desalineado).
- Existe flujo de “alertas automáticas” en backend (`alertas-automaticas.controller.ts` / `smart-alerts.service.ts`) y enums de `TipoAlerta` / `NivelPrioridad` en Prisma.
- Documento `newgeneration.md` define tabla `alertas` con `tiempo_respuesta` y geolocalización (`coordenadas_alerta`).

## Alineación de Variables
- Frontend → Backend:
  - `gestanteId` → `gestante_id`
  - `tipoAlerta`/`tipo` → `tipo_alerta` (valores: `riesgo_alto`, `control_vencido`, `sintoma_alarma`, `emergencia_obstetrica`, `trabajo_parto` o los soportados por Prisma)
  - `nivelPrioridad`/`prioridad` → `nivel_prioridad` (`baja|media|alta|critica`)
  - `mensaje` → `mensaje`
  - `sintomas` → `sintomas` (array de strings)
  - `coordenadas` (`lat`,`lng`) → `coordenadas_alerta` como `[lng,lat]`

## Backend (validación y auto-clasificación)
1. Añadir Zod/Joi schemas:
   - `crearAlertaSchema` para `POST /alertas` (snake_case requerido, enum válido, opcionales).
   - `crearAlertaConEvaluacionSchema` para `POST /alertas/con-evaluacion` (recibe signos y síntomas crudos, coords).
2. Reutilizar/ajustar reglas de `smart-alerts.service.ts`/`alertas-automaticas.controller.ts`:
   - Mapear umbrales críticos (ej.: TA≥160/110, Temp≥38.5, FC≥120, sangrado, dolor severo) → `nivel_prioridad = 'critica'` y `tipo_alerta` específico.
   - Umbrales moderados → `alta`/`media`; leves → `baja`.
3. Normalizar `coordenadas_alerta`:
   - Aceptar `[lng,lat]` (preferido) y traducir a GeoJSON Point antes de persistir.
4. Calcular `tiempo_respuesta` al primer evento de atención (cuando se setea `fechaAtencion` en el backend), almacenando minutos.

## Frontend (formularios y tiempo real)
1. Servicio de alertas:
   - Corregir `AlertaService.crearAlerta()` para enviar snake_case exacto.
   - Añadir `crearAlertaConEvaluacion({gestante_id, signos, sintomas, coordenadas_alerta})` que consuma `POST /alertas/con-evaluacion`.
2. Formulario manual (`AlertaFormScreen`):
   - Usar valores de enums del backend en los dropdowns.
   - Mantener campo opcional de `sintomas` y permitir adjuntar coordenadas.
3. Evaluación en tiempo real:
   - Crear `AlertEvaluatorProvider` que escuche signos/síntomas (desde control prenatal o sensores) y, al cruzar umbrales, dispare `crearAlertaConEvaluacion` automáticamente.
   - Mostrar semáforo en UI: color/ícono según `nivel_prioridad` (`critica`=rojo, `alta`=naranja, `media`=amarillo, `baja`=verde).
4. Geolocalización:
   - Si hay GPS disponible, enviar `coordenadas_alerta: [lng,lat]`.

## Pruebas y Verificación
- Backend: pruebas con Supertest para `POST /alertas` y `/alertas/con-evaluacion` (casos: crítica, alta, media, baja; validación de enums; coords válidas).
- Frontend: pruebas de integración para `AlertaService` y `AlertEvaluatorProvider` (simulación de signos que generen alertas críticas y altas). 
- E2E manual: crear alerta desde UI y verificar coincidencia de claves, recepción de WebSocket y visualización semaforizada.

## Entregables
- Schemas de validación backend.
- Servicio frontend corregido y nuevo método automático.
- Provider de evaluación tiempo real + semáforo UI.
- Pruebas automatizadas básicas (backend y frontend).

¿Confirmo este plan para proceder con la implementación?