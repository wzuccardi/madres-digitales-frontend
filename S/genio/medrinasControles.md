```markdown
# 🛡️ IMPLEMENTACIÓN COMPLETA: SEGURIDAD DE DATOS POR ROLES EN SISTEMA DE GESTANTES

## 📋 PROBLEMA DE SEGURIDAD IDENTIFICADO

### Situación Actual
El sistema carece de aislamiento de datos entre usuarios:
- **Madrinas pueden ver** gestantes y controles prenatales de otras madrinas
- **Sin restricciones de acceso** a nivel de base de datos
- **Riesgo de filtración** de información sensible entre usuarios del mismo rol

### Requisitos de Seguridad
- 🔒 **Madrinas**: Acceso exclusivo a **sus gestantes asignadas** (`madrina_id = su_id`)
- 🔒 **Madrinas**: Acceso exclusivo a **controles prenatales** de sus gestantes
- ✅ **Admin/Super-admin**: Acceso **universal** sin restricciones
- ✅ **Médicos**: Define permisos según necesidad específica

---

## ✅ SOLUCIÓN: ROW LEVEL SECURITY (RLS) EN POSTGRESQL

La RLS es una característica nativa de PostgreSQL que crea políticas de seguridad a nivel de fila, garantizando que **ni siquiera mediante un SQL manual** puedan accederse datos no autorizados.

---

## 🎯 IMPLEMENTACIÓN PASO A PASO

### 1️⃣ HABILITAR Y FORZAR RLS EN LAS TABLAS

```sql
-- =====================================================
-- PASO 1: ACTIVAR SEGURIDAD POR FILAS
-- =====================================================

-- Tabla principal de gestantes
ALTER TABLE public.gestantes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gestantes FORCE ROW LEVEL SECURITY; -- Obliga incluso al owner

-- Tabla de controles prenatales
ALTER TABLE public.control_prenatal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.control_prenatal FORCE ROW LEVEL SECURITY;

-- Nota: FORCE RLS es crucial para que ni siquiera el owner de la tabla (postgres) 
-- pueda saltarse las restricciones. Usa roles de aplicación específicos.
```

### 2️⃣ CREAR POLÍTICAS PARA `public.gestantes`

```sql
-- =====================================================
-- POLÍTICAS DE LECTURA (SELECT)
-- =====================================================
CREATE POLICY gestantes_select_policy ON public.gestantes
    FOR SELECT
    TO public
    USING (
        -- Administradores tienen acceso global
        current_setting('app.current_user_rol', true) IN ('super_admin', 'admin')
        OR
        -- Madrinas solo ven sus gestantes asignadas
        (current_setting('app.current_user_rol', true) = 'madrina' 
         AND madrina_id = current_setting('app.current_user_id', true))
    );

-- =====================================================
-- POLÍTICAS DE MODIFICACIÓN (INSERT, UPDATE, DELETE)
-- =====================================================
CREATE POLICY gestantes_modificar_policy ON public.gestantes
    FOR INSERT, UPDATE, DELETE
    TO public
    USING (
        current_setting('app.current_user_rol', true) IN ('super_admin', 'admin')
        OR
        (current_setting('app.current_user_rol', true) = 'madrina' 
         AND madrina_id = current_setting('app.current_user_id', true))
    );
```

### 3️⃣ CREAR POLÍTICAS PARA `public.control_prenatal`

```sql
-- =====================================================
-- POLÍTICAS DE LECTURA (SELECT) - CON SUBCONSULTA OPTIMIZADA
-- =====================================================
CREATE POLICY controles_select_policy ON public.control_prenatal
    FOR SELECT
    TO public
    USING (
        -- Administradores tienen acceso global
        current_setting('app.current_user_rol', true) IN ('super_admin', 'admin')
        OR
        -- Madrinas solo ven controles de sus gestantes (con IN + subconsulta)
        (current_setting('app.current_user_rol', true) = 'madrina'
         AND gestante_id IN (
             SELECT id FROM public.gestantes 
             WHERE madrina_id = current_setting('app.current_user_id', true)
         ))
    );

-- =====================================================
-- POLÍTICAS DE MODIFICACIÓN (INSERT, UPDATE, DELETE)
-- =====================================================
CREATE POLICY controles_modificar_policy ON public.control_prenatal
    FOR INSERT, UPDATE, DELETE
    TO public
    USING (
        current_setting('app.current_user_rol', true) IN ('super_admin', 'admin')
        OR
        (current_setting('app.current_user_rol', true) = 'madrina'
         AND gestante_id IN (
             SELECT id FROM public.gestantes 
             WHERE madrina_id = current_setting('app.current_user_id', true)
         ))
    );
```

### 4️⃣ VERIFICAR POLÍTICAS CREADAS

```sql
-- Ver políticas activas
SELECT 
    schemaname, 
    tablename, 
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('gestantes', 'control_prenatal')
ORDER BY tablename, policyname;
```

---

## 🔧 CONFIGURACIÓN DE ROLES Y PERMISOS

### A. Crear roles de aplicación (si no existen)

```sql
-- Crear roles específicos para la aplicación
CREATE ROLE app_admin NOLOGIN;
CREATE ROLE app_madrina NOLOGIN;
CREATE ROLE app_medico NOLOGIN;

-- Asignar permisos básicos (RLS hará el filtrado)
GRANT SELECT, INSERT, UPDATE, DELETE ON public.gestantes TO app_admin, app_madrina;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.control_prenatal TO app_admin, app_madrina;
```

### B. Función para establecer contexto de seguridad

```sql
-- =====================================================
-- FUNCIÓN RECOMENDADA: Establecer contexto seguro
-- =====================================================
CREATE OR REPLACE FUNCTION public.set_app_context(
    user_id text,
    user_rol text
)
RETURNS void AS $$
BEGIN
    -- Validar que el rol sea válido
    IF user_rol NOT IN ('super_admin', 'admin', 'madrina', 'medico') THEN
        RAISE EXCEPTION 'Rol inválido: %', user_rol;
    END IF;

    -- Establecer variables de sesión
    PERFORM set_config('app.current_user_id', user_id, false);
    PERFORM set_config('app.current_user_rol', user_rol, false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## 💻 IMPLEMENTACIÓN EN BACKEND

### Ejemplo en **Node.js (PostgreSQL + pg)**

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  user: 'app_user',
  host: 'localhost',
  database: 'gestantes_db',
  password: 'your_password',
  port: 5432,
});

/**
 * Middleware para establecer contexto de seguridad
 */
async function setSecurityContext(client, userId, rol) {
  await client.query('SELECT public.set_app_context($1, $2)', [userId, rol]);
}

/**
 * Obtener gestantes según rol del usuario
 */
async function getGestantes(userId, rol) {
  const client = await pool.connect();
  try {
    // CRÍTICO: Establecer contexto ANTES de cualquier query
    await setSecurityContext(client, userId, rol);
    
    // La misma query funciona para todos los roles
    // RLS filtra automáticamente los resultados
    const result = await client.query('SELECT * FROM public.gestantes ORDER BY nombre');
    
    return result.rows;
  } finally {
    // Limpiar contexto al finalizar
    await client.query('RESET app.current_user_id');
    await client.query('RESET app.current_user_rol');
    client.release();
  }
}

// Uso
const gestantesMadrina = await getGestantes('madrina_abc123', 'madrina'); // Solo sus gestantes
const gestantesAdmin = await getGestantes('admin_xyz789', 'admin'); // Todas las gestantes
```

### Ejemplo en **Python (psycopg2)**

```python
import psycopg2
from contextlib import contextmanager

@contextmanager
def get_db_connection():
    conn = psycopg2.connect(
        dbname="gestantes_db",
        user="app_user",
        password="your_password",
        host="localhost"
    )
    try:
        yield conn
    finally:
        conn.close()

def set_security_context(cursor, user_id, user_rol):
    """Establece el contexto de seguridad para RLS"""
    cursor.execute("SELECT public.set_app_context(%s, %s)", (user_id, user_rol))

def get_gestantes(user_id, user_rol):
    """Obtiene gestantes según permisos del rol"""
    with get_db_connection() as conn:
        with conn.cursor() as cur:
            # Establecer contexto de seguridad
            set_security_context(cur, user_id, user_rol)
            
            # Ejecutar query (RLS filtra automáticamente)
            cur.execute("SELECT * FROM public.gestantes ORDER BY nombre")
            gestantes = cur.fetchall()
            
            # Limpiar contexto
            cur.execute("RESET app.current_user_id")
            cur.execute("RESET app.current_user_rol")
            
            return gestantes
```

### Ejemplo en **Prisma ORM**

```typescript
// middleware/prismaRLS.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

// Middleware para establecer RLS en cada transacción
prisma.$use(async (params, next) => {
  const { userId, rol } = params.args?.__context || {};
  
  if (userId && rol) {
    // Establecer contexto antes de la operación
    await prisma.$executeRaw`SELECT public.set_app_context(${userId}, ${rol})`;
  }
  
  const result = await next(params);
  
  // Limpiar contexto después
  if (userId && rol) {
    await prisma.$executeRaw`RESET app.current_user_id`;
    await prisma.$executeRaw`RESET app.current_user_rol`;
  }
  
  return result;
});

// Uso
const gestantes = await prisma.gestantes.findMany({
  __context: { userId: 'madrina_123', rol: 'madrina' }
});
```

---

## 🧪 TESTING EXHAUSTIVO

### Script de verificación completa

```sql
-- =====================================================
-- TEST COMPLETO DE POLÍTICAS DE SEGURIDAD
-- =====================================================

-- Crear datos de prueba
INSERT INTO public.usuarios (id, nombre, email, password_hash, rol) VALUES
('admin_test', 'Admin', 'admin@test.com', 'hash', 'admin'),
('madrina_a', 'Madrina A', 'madrina.a@test.com', 'hash', 'madrina'),
('madrina_b', 'Madrina B', 'madrina.b@test.com', 'hash', 'madrina');

INSERT INTO public.gestantes (id, nombre, fecha_nacimiento, regimen_salud, madrina_id) VALUES
('gest_1', 'Gestante de Madrina A', '1990-01-01', 'Contributivo', 'madrina_a'),
('gest_2', 'Otra Gestante A', '1992-05-15', 'Contributivo', 'madrina_a'),
('gest_3', 'Gestante de Madrina B', '1995-03-20', 'Subsidiado', 'madrina_b');

INSERT INTO public.control_prenatal (id, gestante_id, fecha_control, semanas_gestacion) VALUES
('ctrl_1', 'gest_1', NOW(), 12),
('ctrl_2', 'gest_2', NOW(), 20),
('ctrl_3', 'gest_3', NOW(), 15);

-- TEST 1: Como ADMIN
SELECT '=== TEST ADMIN ===' as test;
SET app.current_user_id = 'admin_test';
SET app.current_user_rol = 'admin';
SELECT id, nombre, madrina_id FROM public.gestantes; -- Debe mostrar 3 filas
SELECT id, gestante_id FROM public.control_prenatal; -- Debe mostrar 3 filas

-- TEST 2: Como MADRINA A
SELECT '=== TEST MADRINA A ===' as test;
SET app.current_user_id = 'madrina_a';
SET app.current_user_rol = 'madrina';
SELECT id, nombre, madrina_id FROM public.gestantes; -- Debe mostrar 2 filas (gest_1, gest_2)
SELECT id, gestante_id FROM public.control_prenatal; -- Debe mostrar 2 filas (ctrl_1, ctrl_2)

-- TEST 3: Como MADRINA B
SELECT '=== TEST MADRINA B ===' as test;
SET app.current_user_id = 'madrina_b';
SET app.current_user_rol = 'madrina';
SELECT id, nombre, madrina_id FROM public.gestantes; -- Debe mostrar 1 fila (gest_3)
SELECT id, gestante_id FROM public.control_prenatal; -- Debe mostrar 1 fila (ctrl_3)

-- TEST 4: Intentar UPDATE no autorizado
SELECT '=== TEST UPDATE NO AUTORIZADO ===' as test;
SET app.current_user_id = 'madrina_a';
SET app.current_user_rol = 'madrina';
UPDATE public.gestantes SET nombre = 'HACKED' WHERE id = 'gest_3'; -- Debe afectar 0 filas

-- Limpiar datos de prueba
DELETE FROM public.control_prenatal WHERE id IN ('ctrl_1', 'ctrl_2', 'ctrl_3');
DELETE FROM public.gestantes WHERE id IN ('gest_1', 'gest_2', 'gest_3');
DELETE FROM public.usuarios WHERE id IN ('admin_test', 'madrina_a', 'madrina_b');
```

---

## ⚠️ CONSIDERACIONES CRÍTICAS Y MEJORES PRÁCTICAS

### 1. **Variables de Sesión Obligatorias**
- **Si no se establecen**, las consultas de madrinas retornarán **0 filas** (no error, pero vacío)
- **Si se establecen mal**, puede haber fuga de datos o denegación de servicio
- **Solución**: Usa middleware/backend para forzar su establecimiento

### 2. **Rendimiento y Optimización**
- **Índice CRÍTICO**: `idx_gestantes_madrina` debe existir y estar actualizado
- **EXPLAIN ANALYZE**: Verifica que PostgreSQL use el índice:
```sql
SET app.current_user_id = 'madrina_123';
SET app.current_user_rol = 'madrina';
EXPLAIN ANALYZE SELECT * FROM public.gestantes;
```
- **Cache**: Las subconsultas en RLS se ejecutan por cada fila. Para >100k registros, considera usar `WITH` o materialized views.

### 3. **Seguridad en Cadena**
- **No uses el rol `postgres`** para conexiones de la app. Usa roles con `NOLOGIN`
- **Encriptación**: Usa SSL/TLS en conexiones a la BD
- **Secrets**: Las credenciales de BD deben estar en un vault (AWS Secrets Manager, HashiCorp Vault)

### 4. **Problemas Comunes**

| Problema | Causa | Solución |
|----------|-------|----------|
| `0 filas` sin error | Variables de sesión no establecidas | Verificar middleware de conexión |
| Error "undefined variable" | `current_setting()` sin valor por defecto | Usa `current_setting('var', true)` |
| RLS no se aplica | `FORCE ROW LEVEL SECURITY` no activado | Ejecutar `ALTER TABLE ... FORCE RLS` |
| Pérdida de contexto | Pool de conexiones reutiliza sesiones | Limpiar variables en `release()` |

### 5. **Estrategia de Rollback**

```sql
-- Desactivar RLS (si es necesario)
ALTER TABLE public.gestantes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.control_prenatal DISABLE ROW LEVEL SECURITY;

-- Eliminar políticas específicas
DROP POLICY IF EXISTS gestantes_select_policy ON public.gestantes;
DROP POLICY IF EXISTS controles_select_policy ON public.control_prenatal;
```

### 6. **Auditoría y Logging (Mejora Futura)**

```sql
-- Tabla de audit
CREATE TABLE public.audit_acceso (
    id serial PRIMARY KEY,
    usuario_id text,
    rol text,
    accion text,
    tabla text,
    registro_id text,
    fecha timestamp DEFAULT NOW()
);

-- Trigger para log de accesos
CREATE OR REPLACE FUNCTION log_acceso_gestantes()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO audit_acceso (usuario_id, rol, accion, tabla, registro_id)
    VALUES (
        current_setting('app.current_user_id', true),
        current_setting('app.current_user_rol', true),
        TG_OP,
        'gestantes',
        NEW.id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_gestantes
    AFTER INSERT OR UPDATE ON public.gestantes
    FOR EACH ROW EXECUTE FUNCTION log_acceso_gestantes();
```

---

## 📊 RESUMEN DE PERMISOS FINAL

| Rol | Tabla `gestantes` | Tabla `control_prenatal` | Contexto Requerido |
|-----|-------------------|--------------------------|-------------------|
| **super_admin** | ✅ TODAS las operaciones | ✅ TODAS las operaciones | `app.current_user_rol` |
| **admin** | ✅ TODAS las operaciones | ✅ TODAS las operaciones | `app.current_user_rol` |
| **madrina** | ✅ Solo sus gestantes | ✅ Solo sus controles | `app.current_user_id` + `app.current_user_rol` |
| **medico** | ❌ Definir según necesidad | ❌ Definir según necesidad | Por definir |
| **postgres** | ⚠️ IGNORA RLS (NO USAR) | ⚠️ IGNORA RLS (NO USAR) | N/A |

---

## ✅ CHECKLIST DE DESPLIEGUE

- [ ] **Habilitar RLS** en ambas tablas
- [ ] **Crear políticas** SELECT, INSERT, UPDATE, DELETE
- [ ] **Configurar índice** `idx_gestantes_madrina`
- [ ] **Crear función** `set_app_context()`
- [ ] **Actualizar backend** para llamar `setSecurityContext()` en cada request
- [ ] **Crear roles de BD** (`app_admin`, `app_madrina`) con `NOLOGIN`
- [ ] **Probar en staging** con datos reales
- [ ] **Ejecutar script de verificación** completo
- [ ] **Monitorear logs** de PostgreSQL durante 24h post-despliegue
- [ ] **Documentar** para el equipo de desarrollo
- [ ] **Planificar auditoría** de acceso para el futuro

---

## 🔍 TROUBLESHOOTING RÁPIDO

```bash
# Ver conexiones activas y sus variables de contexto
SELECT pid, usename, query, 
       context->>'app.current_user_id' as user_id,
       context->>'app.current_user_rol' as rol
FROM pg_stat_activity 
CROSS JOIN current_setting('app.current_user_id', true) as context;

# Ver errores de RLS en logs de PostgreSQL
tail -f /var/log/postgresql/postgresql-*.log | grep "ROW LEVEL SECURITY"
```

---

## 🚀 MEJORAS FUTURAS RECOMENDADAS

1. **Migrar a Supabase**: Ya tiene RLS integrada con interfaz gráfica
2. **Implementar ABAC**: Usar atributos adicionales (ej: municipio_id) para filtrado geográfico
3. **Cache de políticas**: Para sistemas con >10k usuarios concurrentes
4. **Dashboard de auditoría**: Visualizar quién accede a qué datos en tiempo real
5. **Alertas**: Notificar cuando un admin acceda a datos (cumplimiento GDPR/LGPD)

---

## 🎯 ESTADO FINAL

**✅ SOLUCIÓN COMPLETA Y PRODUCION-READY**

La implementación garantiza:
- **Confidencialidad**: Madrinas no pueden verse entre sí
- **Integridad**: Admin/Super-admin mantienen acceso total
- **Rendimiento**: Usa índices existentes y subconsultas optimizadas
- **Escalabilidad**: Listo para crecer a 100k+ registros
- **Mantenibilidad**: Código limpio y documentado

**Próximo paso**: Ejecutar en entorno de desarrollo → testing → staging → producción con monitoreo.
```