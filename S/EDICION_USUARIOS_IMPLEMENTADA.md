# ✅ Edición de Usuarios Implementada

## 🎯 Objetivo

Permitir que los usuarios existentes puedan completar sus datos faltantes:
- Municipio
- Número de documento
- Teléfono
- Dirección

## ✅ Funcionalidad Existente

El sistema YA tiene implementada la funcionalidad de edición de usuarios:

### 📝 Formulario de Edición
**Ubicación:** `lib/presentation/pages/admin/usuario_form_screen.dart`

**Campos Disponibles:**
1. ✅ Email
2. ✅ Nombres
3. ✅ Apellidos
4. ✅ Rol
5. ✅ Documento
6. ✅ Teléfono
7. ✅ Dirección
8. ✅ Municipio (dropdown con nombres)

### 🔧 Backend
**Endpoint:** `PUT /api/usuarios/:id`
**Controlador:** `src/controllers/usuario.controller.ts`
**Método:** `updateUsuario`

## 📋 Cómo Acceder a la Edición

### Opción 1: Desde el Panel de Administración

1. **Login como Admin/Coordinador**
2. **Ir a "Usuarios"** en el menú
3. **Buscar el usuario** a editar
4. **Click en "Editar"** (ícono de lápiz)
5. **Completar campos faltantes:**
   - Documento
   - Teléfono
   - Municipio
6. **Guardar cambios**

### Opción 2: Desde el Perfil del Usuario

Si el usuario quiere editar su propio perfil:

1. **Login con su cuenta**
2. **Ir a "Perfil"** o "Mi Cuenta"
3. **Click en "Editar Perfil"**
4. **Completar datos faltantes**
5. **Guardar**

## 🔐 Permisos

### Quién Puede Editar Usuarios:

| Rol | Puede Editar |
|-----|--------------|
| **Super Admin** | ✅ Todos los usuarios |
| **Admin** | ✅ Todos excepto Super Admin |
| **Coordinador** | ✅ Madrinas asignadas |
| **Madrina** | ✅ Solo su propio perfil |
| **Médico** | ✅ Solo su propio perfil |
| **Gestante** | ✅ Solo su propio perfil |

## 📊 Usuarios con Datos Faltantes

### Consulta SQL para Identificarlos

```sql
-- Usuarios sin municipio
SELECT 
    id,
    nombre,
    email,
    rol,
    municipio_id,
    documento,
    telefono
FROM usuarios
WHERE activo = true
AND (
    municipio_id IS NULL 
    OR documento IS NULL 
    OR telefono IS NULL
)
ORDER BY fecha_creacion DESC;
```

### Estadísticas Actuales

```sql
-- Contar usuarios con datos faltantes
SELECT 
    COUNT(*) as total_usuarios,
    COUNT(municipio_id) as con_municipio,
    COUNT(documento) as con_documento,
    COUNT(telefono) as con_telefono,
    COUNT(*) - COUNT(municipio_id) as sin_municipio,
    COUNT(*) - COUNT(documento) as sin_documento,
    COUNT(*) - COUNT(telefono) as sin_telefono
FROM usuarios
WHERE activo = true;
```

## 🚀 Proceso de Actualización Masiva

### Opción A: Actualización Manual (Recomendado)

1. **Notificar a los usuarios** vía email/WhatsApp
2. **Solicitar que completen sus datos**
3. **Proporcionar instrucciones** de cómo editar su perfil
4. **Establecer fecha límite** para completar datos

### Opción B: Actualización por Admin

1. **Exportar lista de usuarios** con datos faltantes
2. **Contactar a cada usuario** para obtener datos
3. **Admin actualiza** los perfiles manualmente
4. **Verificar** que los datos sean correctos

### Opción C: Actualización por SQL (Solo si es necesario)

```sql
-- EJEMPLO: Actualizar municipio de un usuario específico
UPDATE usuarios
SET 
    municipio_id = '13433',  -- ID del municipio
    documento = '1234567890',
    telefono = '3001234567',
    fecha_actualizacion = NOW()
WHERE id = 'usuario_id_aqui';

-- EJEMPLO: Actualizar múltiples usuarios del mismo municipio
UPDATE usuarios
SET 
    municipio_id = '13433',
    fecha_actualizacion = NOW()
WHERE id IN (
    'usuario_id_1',
    'usuario_id_2',
    'usuario_id_3'
);
```

## 📧 Plantilla de Notificación

### Email/WhatsApp para Usuarios

```
Hola [Nombre],

Para mejorar nuestro sistema de Madres Digitales, necesitamos que completes tu información de perfil.

Por favor ingresa a la aplicación y actualiza:
- Número de documento
- Teléfono
- Municipio donde trabajas

Pasos:
1. Inicia sesión en https://madres-digitales-frontend.vercel.app
2. Ve a tu perfil (ícono de usuario)
3. Click en "Editar Perfil"
4. Completa los campos faltantes
5. Guarda los cambios

Fecha límite: [Fecha]

Gracias por tu colaboración.
```

## 🔍 Verificación Post-Actualización

### Consulta para Verificar Completitud

```sql
-- Verificar que todos los usuarios tengan datos completos
SELECT 
    rol,
    COUNT(*) as total,
    COUNT(municipio_id) as con_municipio,
    COUNT(documento) as con_documento,
    COUNT(telefono) as con_telefono
FROM usuarios
WHERE activo = true
GROUP BY rol
ORDER BY rol;
```

### Dashboard de Completitud

Crear un reporte en Power BI que muestre:
- Total de usuarios por rol
- % de usuarios con municipio
- % de usuarios con documento
- % de usuarios con teléfono
- Lista de usuarios con datos faltantes

## 🎨 Mejoras Sugeridas (Opcional)

### 1. Banner de Datos Incompletos

Mostrar un banner en el dashboard si el usuario tiene datos faltantes:

```dart
if (user.municipioId == null || user.documento == null || user.telefono == null) {
  return Card(
    color: Colors.orange.shade50,
    child: ListTile(
      leading: Icon(Icons.warning, color: Colors.orange),
      title: Text('Completa tu perfil'),
      subtitle: Text('Algunos datos de tu perfil están incompletos'),
      trailing: ElevatedButton(
        child: Text('Completar'),
        onPressed: () => Navigator.push(...),
      ),
    ),
  );
}
```

### 2. Validación Obligatoria

Hacer que ciertos campos sean obligatorios para ciertos roles:

```dart
// Para madrinas, el municipio es obligatorio
if (user.rol == 'madrina' && user.municipioId == null) {
  // Redirigir a edición de perfil
  // No permitir acceso completo hasta completar datos
}
```

### 3. Recordatorios Automáticos

Enviar recordatorios automáticos cada X días si los datos están incompletos.

## 📱 Flujo de Usuario

### Usuario con Datos Incompletos

```
1. Login → Dashboard
2. Ve banner: "Completa tu perfil"
3. Click en "Completar"
4. Formulario de edición
5. Completa: Documento, Teléfono, Municipio
6. Guarda cambios
7. Confirmación: "Perfil actualizado"
8. Regresa al dashboard (sin banner)
```

### Admin Editando Usuario

```
1. Login como Admin
2. Menú → Usuarios
3. Lista de usuarios
4. Click en "Editar" (usuario específico)
5. Formulario pre-llenado con datos actuales
6. Actualiza campos faltantes
7. Guarda cambios
8. Confirmación: "Usuario actualizado"
9. Regresa a lista de usuarios
```

## ✅ Checklist de Implementación

- [x] Formulario de edición existe
- [x] Backend acepta actualizaciones
- [x] Dropdown de municipios funciona
- [x] Validaciones implementadas
- [x] Permisos configurados
- [ ] Notificar a usuarios con datos faltantes
- [ ] Establecer fecha límite
- [ ] Verificar completitud de datos
- [ ] Generar reporte en Power BI

## 🎯 Próximos Pasos

### Inmediato (Esta Semana)

1. **Identificar usuarios** con datos faltantes
   ```sql
   SELECT email, nombre, rol 
   FROM usuarios 
   WHERE activo = true 
   AND (municipio_id IS NULL OR documento IS NULL OR telefono IS NULL);
   ```

2. **Notificar a usuarios** vía email/WhatsApp

3. **Establecer fecha límite** (ej: 1 semana)

### Corto Plazo (Próximas 2 Semanas)

4. **Seguimiento** de usuarios que completaron datos

5. **Actualización manual** por admin de usuarios que no respondieron

6. **Verificación final** de completitud

### Mediano Plazo (Próximo Mes)

7. **Implementar banner** de datos incompletos

8. **Crear dashboard** de completitud en Power BI

9. **Establecer política** de datos obligatorios para nuevos usuarios

## 📊 Métricas de Éxito

- ✅ 100% de usuarios con municipio asignado
- ✅ 90%+ de usuarios con documento registrado
- ✅ 90%+ de usuarios con teléfono registrado
- ✅ Datos disponibles para análisis en Power BI

## 🔗 Referencias

- Formulario: `lib/presentation/pages/admin/usuario_form_screen.dart`
- Controlador: `src/controllers/usuario.controller.ts`
- Endpoint: `PUT /api/usuarios/:id`
- Tabla: `usuarios` en PostgreSQL

---

**La funcionalidad de edición ya está implementada y lista para usar.** Los usuarios pueden completar sus datos faltantes desde el formulario de edición. 🎉
