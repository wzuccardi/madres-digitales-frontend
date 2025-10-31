# 🔧 INSTRUCCIONES DE CORRECCIÓN - FRONTEND FLUTTER

## 📋 Problemas a Corregir

### 1. Categorías de Contenido
**Archivo**: `lib/services/simple_data_service.dart`

**Problema**: El frontend envía categorías que no existen en el backend

**Categorías Válidas en Backend**:
```
NUTRICION
EJERCICIO
CUIDADO_PERSONAL
PREPARACION_PARTO
LACTANCIA
SALUD_MENTAL
DESARROLLO_FETAL
```

**Mapeo Necesario**:
```dart
// Cambiar de:
'embarazo' → 'NUTRICION'
'saludMental' → 'SALUD_MENTAL'
'cuidadoBebe' → 'CUIDADO_PERSONAL'
'planificacionFamiliar' → 'NUTRICION' (no existe en backend)
'emergencias' → 'NUTRICION' (no existe en backend)

// A:
'NUTRICION'
'SALUD_MENTAL'
'CUIDADO_PERSONAL'
'PREPARACION_PARTO'
'LACTANCIA'
'DESARROLLO_FETAL'
'EJERCICIO'
```

**Ubicación en el código**:
- Buscar: `embarazo`, `saludMental`, `cuidadoBebe`, `planificacionFamiliar`, `emergencias`
- Reemplazar con valores válidos del backend

### 2. Rutas de Reportes
**Archivo**: `lib/screens/reportes_detalle_screen.dart`

**Problema**: Intenta acceder a `/api/reportes/descargar/resumen-general` sin extensión

**Rutas Correctas**:
```
GET /api/reportes/descargar/resumen-general/pdf
GET /api/reportes/descargar/resumen-general/excel
GET /api/reportes/descargar/estadisticas-gestantes/pdf
GET /api/reportes/descargar/estadisticas-gestantes/excel
GET /api/reportes/descargar/estadisticas-controles/excel
GET /api/reportes/descargar/estadisticas-alertas/excel
GET /api/reportes/descargar/estadisticas-riesgo/excel
GET /api/reportes/descargar/tendencias/excel
```

**Cambios Necesarios**:
```dart
// Cambiar de:
'/api/reportes/descargar/resumen-general'

// A:
'/api/reportes/descargar/resumen-general/pdf'
// o
'/api/reportes/descargar/resumen-general/excel'
```

**Ubicación en el código**:
- Buscar: `/api/reportes/descargar/`
- Agregar `/pdf` o `/excel` al final de la URL

## 🔍 Búsqueda y Reemplazo

### Paso 1: Categorías de Contenido
```
Buscar: 'embarazo'
Reemplazar: 'NUTRICION'

Buscar: 'saludMental'
Reemplazar: 'SALUD_MENTAL'

Buscar: 'cuidadoBebe'
Reemplazar: 'CUIDADO_PERSONAL'

Buscar: 'planificacionFamiliar'
Reemplazar: 'NUTRICION'

Buscar: 'emergencias'
Reemplazar: 'NUTRICION'
```

### Paso 2: Rutas de Reportes
```
Buscar: '/api/reportes/descargar/resumen-general'
Reemplazar: '/api/reportes/descargar/resumen-general/pdf'

Buscar: '/api/reportes/descargar/estadisticas-gestantes'
Reemplazar: '/api/reportes/descargar/estadisticas-gestantes/pdf'

Buscar: '/api/reportes/descargar/estadisticas-controles'
Reemplazar: '/api/reportes/descargar/estadisticas-controles/excel'

Buscar: '/api/reportes/descargar/estadisticas-alertas'
Reemplazar: '/api/reportes/descargar/estadisticas-alertas/excel'

Buscar: '/api/reportes/descargar/estadisticas-riesgo'
Reemplazar: '/api/reportes/descargar/estadisticas-riesgo/excel'

Buscar: '/api/reportes/descargar/tendencias'
Reemplazar: '/api/reportes/descargar/tendencias/excel'
```

## 🧪 Pruebas Después de Corregir

1. **Verificar Categorías**:
   ```bash
   curl "http://localhost:54112/api/contenido?categoria=NUTRICION"
   ```

2. **Verificar Reportes**:
   ```bash
   curl "http://localhost:54112/api/reportes/descargar/resumen-general/pdf" -o resumen.pdf
   ```

3. **Probar en Frontend**:
   - Cargar pantalla de contenido
   - Cargar pantalla de reportes
   - Descargar reportes

## 📝 Archivos a Revisar

- `lib/services/simple_data_service.dart` - Categorías
- `lib/screens/reportes_detalle_screen.dart` - Rutas de reportes
- `lib/screens/reportes_screen.dart` - Rutas de reportes
- `lib/screens/centro_notificaciones_screen.dart` - Posibles referencias

## ✅ Checklist

- [ ] Actualizar categorías en simple_data_service.dart
- [ ] Actualizar rutas de reportes en reportes_detalle_screen.dart
- [ ] Actualizar rutas de reportes en reportes_screen.dart
- [ ] Ejecutar `flutter analyze` para verificar errores
- [ ] Probar endpoints en Postman o curl
- [ ] Probar en el frontend
- [ ] Hacer commit y push a Git
- [ ] Desplegar a Vercel

## 🚀 Desplegar a Vercel

```bash
git add .
git commit -m "Fix: Actualizar categorías y rutas de reportes"
git push origin main
```

Vercel desplegará automáticamente.

