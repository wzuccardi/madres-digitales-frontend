# Integración de Módulos IPS, Médicos y Municipios

## Descripción
Esta integración permite al super_administrador gestionar de manera unificada los módulos de IPS, médicos y municipios, con funcionalidades para activar/desactivar municipios y ver estadísticas integradas.

## Archivos Implementados

### Modelos
- `lib/models/integrated_models.dart` - Modelos integrados con estadísticas
  - `MunicipioIntegrado` - Municipio con estadísticas de IPS, médicos y gestantes
  - `IPSIntegrada` - IPS con información del municipio y estadísticas
  - `MedicoIntegrado` - Médico con información de IPS y municipio
  - `ResumenIntegrado` - Resumen estadístico general

### Servicios
- `lib/services/integrated_admin_service.dart` - Servicio para operaciones integradas
  - Gestión de municipios con estadísticas
  - Operaciones CRUD para IPS y médicos
  - Operaciones masivas
  - Sincronización de datos
  - Generación de reportes

### Providers
- `lib/providers/integrated_admin_provider.dart` - Providers para estado integrado
  - `municipiosIntegradosProvider` - Estado de municipios con estadísticas
  - `resumenIntegradoProvider` - Resumen estadístico general
  - `ipsIntegradaProvider` - IPS por municipio
  - `medicosIntegradosProvider` - Médicos por municipio

### Pantallas
- `lib/screens/super_admin_screen.dart` - Pantalla principal del super administrador
  - Vista de municipios con estadísticas integradas
  - Filtros por estado y búsqueda
  - Activación/desactivación individual y masiva
  - Detalles de municipio con IPS y médicos
  - Operaciones masivas y sincronización

## Funcionalidades Implementadas

### Para Super Administrador
1. **Vista de Municipios Integrada**
   - Lista de municipios con estadísticas en tiempo real
   - Indicadores de gestantes, IPS, médicos y alertas
   - Estado visual de cada municipio

2. **Activación/Desactivación de Municipios**
   - Switch individual para cada municipio
   - Operaciones masivas para todos los municipios
   - Confirmación de acciones críticas

3. **Detalles de Municipio**
   - Información completa del municipio
   - Lista de IPS con estadísticas
   - Lista de médicos con carga de trabajo
   - Gestión de estado de IPS y médicos

4. **Filtros y Búsqueda**
   - Filtro por estado (activos/inactivos/todos)
   - Búsqueda por nombre o código de municipio
   - Actualización en tiempo real

5. **Operaciones Masivas**
   - Activar/desactivar todos los municipios
   - Sincronización de datos entre módulos
   - Indicadores de progreso

6. **Estadísticas Integradas**
   - Resumen general en la parte superior
   - Métricas por municipio
   - Indicadores de cobertura y riesgo

## Endpoints de API Requeridos

### Municipios
- `GET /api/municipios/integrados` - Obtener municipios con estadísticas
- `POST /api/municipios/{id}/activar` - Activar municipio
- `POST /api/municipios/{id}/desactivar` - Desactivar municipio
- `GET /api/municipios/{id}/detallado` - Detalles completos del municipio
- `POST /api/municipios/toggle-multiple` - Operaciones masivas

### IPS
- `GET /api/ips-crud/municipio/{id}/integradas` - IPS por municipio con estadísticas
- `GET /api/ips-crud/integradas` - Todas las IPS integradas
- `PUT /api/ips-crud/{id}` - Actualizar estado de IPS

### Médicos
- `GET /api/medicos-crud/municipio/{id}/integrados` - Médicos por municipio
- `GET /api/medicos-crud/ips/{id}/integrados` - Médicos por IPS
- `GET /api/medicos-crud/integrados` - Todos los médicos integrados
- `PUT /api/medicos-crud/{id}` - Actualizar estado de médico
- `POST /api/medicos-crud/{id}/asignar-ips` - Asignar médico a IPS

### Administración
- `GET /api/admin/resumen-integrado` - Resumen estadístico general
- `GET /api/admin/estadisticas/municipio/{id}` - Estadísticas por municipio
- `GET /api/admin/estadisticas/ips/{id}` - Estadísticas por IPS
- `GET /api/admin/estadisticas/medico/{id}` - Estadísticas por médico
- `GET /api/admin/buscar?q={query}` - Búsqueda integrada
- `POST /api/admin/sincronizar-datos` - Sincronización de datos
- `POST /api/admin/reporte-integrado` - Generar reporte integrado

## Estructura de Datos

### MunicipioIntegrado
```json
{
  "id": "string",
  "codigo": "string",
  "nombre": "string",
  "departamento": "string",
  "activo": boolean,
  "poblacion": number,
  "latitud": number,
  "longitud": number,
  "created_at": "datetime",
  "updated_at": "datetime",
  "estadisticas": {
    "gestantes": number,
    "medicos": number,
    "ips": number,
    "madrinas": number,
    "gestantes_activas": number,
    "gestantes_riesgo_alto": number,
    "alertas_activas": number
  },
  "ips": [IPSIntegrada],
  "medicos": [MedicoIntegrado]
}
```

### IPSIntegrada
```json
{
  "id": "string",
  "nombre": "string",
  "direccion": "string",
  "telefono": "string",
  "email": "string",
  "nivel_atencion": "string",
  "municipio_id": "string",
  "municipio_nombre": "string",
  "coordenadas": {
    "type": "Point",
    "coordinates": [longitude, latitude]
  },
  "activa": boolean,
  "created_at": "datetime",
  "updated_at": "datetime",
  "estadisticas": {
    "medicos": number,
    "gestantes_asignadas": number,
    "controles_realizados": number
  },
  "especialidades": ["string"],
  "medicos": [MedicoIntegrado]
}
```

### MedicoIntegrado
```json
{
  "id": "string",
  "nombre": "string",
  "documento": "string",
  "telefono": "string",
  "email": "string",
  "especialidad": "string",
  "registro_medico": "string",
  "ips_id": "string",
  "ips_nombre": "string",
  "municipio_id": "string",
  "municipio_nombre": "string",
  "activo": boolean,
  "created_at": "datetime",
  "updated_at": "datetime",
  "estadisticas": {
    "gestantes_asignadas": number,
    "controles_realizados": number,
    "controles_este_mes": number,
    "promedio_controles": number
  },
  "horarios_atencion": {}
}
```

## Uso

1. **Acceso**: Solo usuarios con rol `super_admin` pueden acceder
2. **Navegación**: Desde el menú principal → Super Administrador
3. **Operaciones**: 
   - Clic en municipio para ver detalles
   - Switch para activar/desactivar
   - Menú de opciones para operaciones masivas
4. **Filtros**: Usar la barra de búsqueda y selector de estado

## Consideraciones de Seguridad

- Todas las operaciones requieren autenticación
- Solo super_admin puede realizar operaciones masivas
- Confirmación requerida para acciones críticas
- Logs de auditoría para cambios de estado
- Validación de permisos en cada endpoint

## Próximas Mejoras

1. Gráficos y análisis avanzados
2. Exportación de reportes
3. Notificaciones en tiempo real
4. Historial de cambios
5. Métricas de rendimiento