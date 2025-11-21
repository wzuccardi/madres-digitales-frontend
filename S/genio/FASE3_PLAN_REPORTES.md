# 📊 FASE 3.1 - SISTEMA DE REPORTES Y ESTADÍSTICAS

## 🎯 OBJETIVO
Implementar un sistema completo de reportes y estadísticas con dashboard avanzado, gráficas interactivas y exportación de datos.

**Duración**: 40 horas  
**Prioridad**: ALTA  
**Estado**: 🚀 INICIANDO

---

## 📋 TAREAS DETALLADAS

### BACKEND (20 horas)

#### 1. Endpoints de Estadísticas (8 horas)
- [ ] `GET /api/reportes/resumen-general` - Resumen con totales
- [ ] `GET /api/reportes/estadisticas-gestantes` - Stats por municipio/IPS
- [ ] `GET /api/reportes/estadisticas-controles` - Controles por período
- [ ] `GET /api/reportes/estadisticas-alertas` - Alertas por tipo/prioridad
- [ ] `GET /api/reportes/estadisticas-riesgo` - Distribución de riesgo
- [ ] `GET /api/reportes/tendencias` - Tendencias temporales

#### 2. Queries Optimizadas (6 horas)
- [ ] Query para totales agregados (gestantes, controles, alertas)
- [ ] Query para distribución geográfica (por municipio)
- [ ] Query para distribución por IPS
- [ ] Query para evolución temporal (últimos 6 meses)
- [ ] Query para indicadores de salud materna
- [ ] Query para ranking de madrinas (más activas)

#### 3. Exportación de Datos (6 horas)
- [ ] Instalar librerías: `exceljs`, `pdfkit`
- [ ] Endpoint `POST /api/reportes/exportar-excel`
- [ ] Endpoint `POST /api/reportes/exportar-pdf`
- [ ] Generación de Excel con múltiples hojas
- [ ] Generación de PDF con gráficas
- [ ] Descarga de archivos con headers correctos

---

### FRONTEND (20 horas)

#### 4. Pantalla de Dashboard Avanzado (8 horas)
- [ ] Crear `reportes_dashboard_screen.dart`
- [ ] Layout con grid de tarjetas de estadísticas
- [ ] Tarjeta: Total gestantes (con icono y color)
- [ ] Tarjeta: Total controles (con icono y color)
- [ ] Tarjeta: Alertas activas (con icono y color)
- [ ] Tarjeta: Gestantes de alto riesgo (con icono y color)
- [ ] Selector de período (última semana, mes, 3 meses, 6 meses, año)
- [ ] Botón de refrescar datos

#### 5. Gráficas Interactivas (8 horas)
- [ ] Instalar librería: `fl_chart` o `charts_flutter`
- [ ] Gráfica de barras: Gestantes por municipio
- [ ] Gráfica de líneas: Evolución de controles (últimos 6 meses)
- [ ] Gráfica de pie: Distribución de alertas por tipo
- [ ] Gráfica de barras: Alertas por prioridad
- [ ] Gráfica de líneas: Tendencia de gestantes de alto riesgo
- [ ] Interactividad: tooltips al hacer hover
- [ ] Leyendas y etiquetas claras

#### 6. Exportación desde Frontend (4 horas)
- [ ] Botón "Exportar a Excel" en dashboard
- [ ] Botón "Exportar a PDF" en dashboard
- [ ] Diálogo de confirmación antes de exportar
- [ ] Descarga automática del archivo
- [ ] Indicador de progreso durante exportación
- [ ] Mensaje de éxito/error

---

## 📊 ESTRUCTURA DE DATOS

### Resumen General:
```typescript
{
  total_gestantes: number,
  total_controles: number,
  total_alertas_activas: number,
  gestantes_alto_riesgo: number,
  controles_este_mes: number,
  alertas_criticas: number,
  promedio_controles_por_gestante: number,
  tasa_cumplimiento_controles: number
}
```

### Estadísticas por Municipio:
```typescript
{
  municipio: string,
  total_gestantes: number,
  gestantes_alto_riesgo: number,
  total_controles: number,
  alertas_activas: number
}[]
```

### Evolución Temporal:
```typescript
{
  fecha: string,
  total_gestantes: number,
  nuevos_controles: number,
  nuevas_alertas: number
}[]
```

### Distribución de Alertas:
```typescript
{
  tipo: string,
  cantidad: number,
  porcentaje: number
}[]
```

---

## 🎨 DISEÑO UI

### Dashboard Layout:
```
┌─────────────────────────────────────────────────────┐
│  📊 Dashboard de Reportes y Estadísticas            │
├─────────────────────────────────────────────────────┤
│  [Última semana ▼]  [Refrescar 🔄]  [Exportar ⬇️]  │
├─────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────┐│
│  │👥 Gestantes│ │📋 Controles│ │🚨 Alertas │ │⚠️ Riesgo││
│  │    150    │  │    420    │  │    19    │  │   45  ││
│  └──────────┘  └──────────┘  └──────────┘  └─────┘│
├─────────────────────────────────────────────────────┤
│  📈 Evolución de Controles (Últimos 6 meses)        │
│  ┌─────────────────────────────────────────────┐   │
│  │         [Gráfica de líneas]                 │   │
│  └─────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────┤
│  📊 Gestantes por Municipio  │  🥧 Alertas por Tipo │
│  ┌──────────────────────┐   │  ┌─────────────────┐│
│  │ [Gráfica de barras]  │   │  │ [Gráfica de pie]││
│  └──────────────────────┘   │  └─────────────────┘│
└─────────────────────────────────────────────────────┘
```

---

## 🔧 TECNOLOGÍAS

### Backend:
- **ExcelJS**: Generación de archivos Excel
- **PDFKit**: Generación de archivos PDF
- **Prisma**: Queries optimizadas con agregaciones

### Frontend:
- **fl_chart**: Gráficas interactivas en Flutter
- **http**: Llamadas a API
- **path_provider**: Guardar archivos descargados

---

## ✅ CRITERIOS DE ACEPTACIÓN

### Backend:
1. ✅ Todos los endpoints responden en < 2 segundos
2. ✅ Queries optimizadas con índices
3. ✅ Exportación genera archivos válidos
4. ✅ Datos agregados correctamente
5. ✅ Filtros por período funcionan

### Frontend:
1. ✅ Dashboard carga en < 3 segundos
2. ✅ Gráficas son interactivas y responsivas
3. ✅ Exportación descarga archivos correctamente
4. ✅ UI es intuitiva y clara
5. ✅ Selector de período actualiza datos

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Queries Optimizadas:
```typescript
// Resumen general con agregaciones
const resumen = await prisma.$queryRaw`
  SELECT 
    COUNT(DISTINCT g.id) as total_gestantes,
    COUNT(DISTINCT c.id) as total_controles,
    COUNT(DISTINCT a.id) FILTER (WHERE a.resuelta = false) as alertas_activas,
    COUNT(DISTINCT g.id) FILTER (WHERE g.riesgo_alto = true) as gestantes_alto_riesgo
  FROM gestante g
  LEFT JOIN control_prenatal c ON c.gestante_id = g.id
  LEFT JOIN alerta a ON a.gestante_id = g.id
`;
```

### Gráfica con fl_chart:
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      LineChartBarData(
        spots: data.map((d) => FlSpot(d.x, d.y)).toList(),
        isCurved: true,
        colors: [Colors.blue],
        barWidth: 3,
      ),
    ],
  ),
)
```

---

## 🎯 PRÓXIMOS PASOS

1. Implementar endpoints de backend
2. Crear queries optimizadas
3. Implementar exportación
4. Crear pantalla de dashboard
5. Implementar gráficas
6. Agregar exportación desde frontend
7. Testing completo
8. Actualizar documentación

---

**Inicio**: 03/10/2025  
**Estimado de Completitud**: 05/10/2025  
**Responsable**: Equipo de Desarrollo

