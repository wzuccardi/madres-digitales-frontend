# Deploy Manual del Backend - Pasos

## ✅ Cambios Listos para Deploy

### Archivos Modificados
1. ✅ `prisma/schema.prisma` - Campos adicionales agregados
2. ✅ `src/controllers/gestante.controller.ts` - Manejo de campos JSON corregido
3. ✅ `src/services/gestante.service.ts` - Campo FUM agregado a actualización
4. ✅ Cliente de Prisma regenerado
5. ✅ Backend compilado exitosamente

### Cambios Incluidos
- ✅ Campo FUM en formulario de edición de gestantes
- ✅ Cálculo automático de FPP desde FUM
- ✅ Campos adicionales: grupo_sanguineo, barrio, foto_url, factores_riesgo, email, apellido
- ✅ Corrección de error 400 al crear gestantes
- ✅ Límite de gestantes aumentado a 40

## 🚀 Opción 1: Deploy con Vercel CLI (Recomendado)

### Paso 1: Abrir Terminal en el Backend
```bash
cd S\aplicacionWZC\madres-digitales-backend
```

### Paso 2: Ejecutar Deploy
```bash
vercel --prod
```

### Paso 3: Responder las Preguntas
Si pregunta "Set up and deploy?":
- Responder: `Y` (Yes)

Si pregunta por el nombre del proyecto:
- Usar: `madres-digitales-backend`

Si pregunta por el directorio:
- Dejar por defecto (presionar Enter)

### Paso 4: Esperar
El deploy puede tomar 2-5 minutos. Verás:
```
✓ Deployment ready
https://madres-digitales-backend.vercel.app
```

## 🚀 Opción 2: Deploy con Git Push (Más Fácil)

Si tienes auto-deploy configurado en Vercel:

### Paso 1: Commit los Cambios
```bash
cd S\aplicacionWZC\madres-digitales-backend
git add .
git commit -m "fix: agregar campos adicionales y corregir error 400 en creación de gestantes"
```

### Paso 2: Push a GitHub
```bash
git push origin main
```

### Paso 3: Verificar en Vercel
1. Ir a https://vercel.com/dashboard
2. Buscar el proyecto `madres-digitales-backend`
3. Ver que el deploy se está ejecutando
4. Esperar a que termine (2-5 minutos)

## 🚀 Opción 3: Deploy desde Vercel Dashboard

### Paso 1: Ir a Vercel Dashboard
https://vercel.com/dashboard

### Paso 2: Seleccionar el Proyecto
Buscar y hacer clic en `madres-digitales-backend`

### Paso 3: Ir a Deployments
Hacer clic en la pestaña "Deployments"

### Paso 4: Redeploy
1. Hacer clic en el último deployment
2. Hacer clic en el botón "..." (tres puntos)
3. Seleccionar "Redeploy"
4. Confirmar

**NOTA:** Esta opción NO incluirá los cambios nuevos. Necesitas hacer commit primero.

## ✅ Verificar que el Deploy Funcionó

### Paso 1: Esperar a que Termine
Vercel mostrará "Deployment Ready" cuando termine.

### Paso 2: Probar el Endpoint
```bash
curl https://madres-digitales-backend.vercel.app/api/gestantes
```

Debería responder con datos o un error de autenticación (normal).

### Paso 3: Probar Crear Gestante desde la App
1. Abrir la app
2. Ir a "Nueva Gestante"
3. Llenar los campos
4. Guardar
5. ✅ NO debería aparecer error 400

## 🐛 Si el Deploy Falla

### Error: "Project not found"
**Solución:** Necesitas reconectar el proyecto con Vercel
```bash
vercel link
```

### Error: "Build failed"
**Solución:** Verificar logs en Vercel Dashboard
1. Ir a Vercel Dashboard
2. Ver el deployment fallido
3. Hacer clic para ver logs
4. Buscar el error específico

### Error: "Environment variables missing"
**Solución:** Verificar que las variables de entorno estén configuradas en Vercel:
- `DATABASE_URL`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `RESEND_API_KEY`
- `CORS_ORIGINS`
- `FRONTEND_URL`
- `BACKEND_URL`

## 📊 Verificar Variables de Entorno

### En Vercel Dashboard:
1. Ir al proyecto
2. Settings → Environment Variables
3. Verificar que todas estén configuradas
4. Si falta alguna, agregarla

### Variables Requeridas:
```
DATABASE_URL=postgres://...
JWT_SECRET=M4dr3sD1g1t4l3sS3cur3JWTk3y2025R4nd0m32ch4rs
JWT_REFRESH_SECRET=M4dr3sD1g1t4l3sS3cur3R3fr3shk3y2025R4nd0m32ch4rs
RESEND_API_KEY=re_b71cxjFw_586ycZSBV6bHjSLD8m19qYLB
CORS_ORIGINS=https://madres-digitales-frontend.vercel.app
FRONTEND_URL=https://madres-digitales-frontend.vercel.app
BACKEND_URL=https://madres-digitales-backend.vercel.app
NODE_ENV=production
```

## 🎯 Después del Deploy

### 1. Probar Crear Gestante
- Abrir la app
- Crear una nueva gestante
- Verificar que NO aparezca error 400

### 2. Probar Editar Gestante
- Seleccionar una gestante
- Hacer clic en editar
- Verificar que aparezca el campo FUM
- Agregar FUM
- Guardar
- Verificar que se guarde correctamente

### 3. Verificar Logs
En Vercel Dashboard:
- Ver logs en tiempo real
- Buscar mensajes de éxito:
  - "✅ Controller: Gestante created successfully"
  - "💾 Datos a guardar"
  - "📅 Fechas recibidas"

## 📝 Comandos Útiles

### Ver logs en tiempo real
```bash
vercel logs madres-digitales-backend --follow
```

### Ver último deployment
```bash
vercel ls
```

### Ver información del proyecto
```bash
vercel inspect
```

## ✨ Resumen

**Estado Actual:**
- ✅ Código corregido y compilado
- ✅ Listo para deploy
- ⏳ Esperando deploy manual

**Después del Deploy:**
- ✅ Error 400 solucionado
- ✅ Crear gestantes funcionará
- ✅ Editar gestantes con FUM funcionará
- ✅ Todos los campos adicionales funcionarán

**Tiempo Estimado:**
- Deploy: 2-5 minutos
- Verificación: 2-3 minutos
- **Total: ~5-8 minutos**
