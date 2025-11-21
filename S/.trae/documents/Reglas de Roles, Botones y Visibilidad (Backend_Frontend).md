## Objetivo
Aplicar reglas de negocio de roles y visibilidad en toda la app (frontend y backend), garantizar filtrado de datos por rol, restringir acciones y exponer módulos según permisos. Asegurar flujos de SOS y reportes.

## Modelo de Roles y Permisos
- Roles: super_admin, admin, coordinador, madrina, medico.
- Visibilidad y acciones:
  - Madrina: crea sus gestantes, ve sólo gestantes con `madrina_id == user.id`; botón SOS; no ve gestantes de otras madrinas.
  - Admin/Coordinador: asigna gestantes a madrinas (botón Asignar gestantes); ve jerarquía hacia abajo (sin ver super_admin ni sus datos); acceso terminal SOS.
  - Super Admin: gestiona municipios (botón Gestión de municipios); gestiona usuarios (crear/editar), gestiona contenidos; acceso terminal SOS; ve todos.
  - Médico: ve sólo gestantes con `medico_tratante_id == user.id` (si aplica); sin gestión.

## Backend (Enforcement)
- Autenticación: decodificar token y resolver rol/ID reales desde BD (usuarios) en middleware utilitario.
- Filtros de datos:
  - `GET /api/gestantes`: exigir token; madrina → `where.madrina_id = user.id`; médico → `where.medico_tratante_id = user.id`; admin/coordinador/super → sin filtro adicional.
  - `POST /api/gestantes`: asignar automáticamente `madrina_id` si rol madrina.
- Asignación:
  - Endpoint `POST /api/gestantes/:id/asignar` con `{madrina_id}`: permitido para admin/coordinador (403 para otros).
- SOS:
  - Endpoint `POST /api/sos` que emite/broadcast a sesiones con rol admin, super_admin, coordinador (canal WebSocket); madrina invoca; terminal escucha.
- Municipios:
  - `GET /api/municipios` devuelve activos.
  - Admin de municipios (super_admin): `GET /api/municipios/admin`, `POST /api/municipios`, `PUT /api/municipios/:id`, `PATCH /api/municipios/:id/estado` (403 si no super_admin).
- Usuarios/roles:
  - `POST /api/usuarios`: admin/super; no permitir crear rol `super_admin` salvo super_admin.
  - `DELETE /api/usuarios/:id`: prohibir eliminar al super administrador principal (`wzuccardi@gmail.com`), y en general restringir por jerarquía.
  - Listado: super_admin ve todos; admin no ve super_admin ni fuera de su jerarquía.
- Contenidos:
  - Endpoints protegidos para creación/gestión sólo admin y super_admin.
- Reportes:
  - Endpoints `GET /api/reportes?formato=pdf|excel|csv|txt` generando con servicios actuales; restricción por rol (admin, super_admin; coordinador opcional).

## Frontend (Gating y UX)
- Visibilidad de botones por rol (desde estado de sesión):
  - Gestión de municipios: sólo super_admin.
  - Asignar gestantes: admin y coordinador.
  - SOS: sólo madrina.
  - Gestión de usuarios: super_admin y admin; ocultar rol `super_admin` en combos para admin.
  - Gestión de contenidos: admin y super_admin.
- Combos de municipios: poblar desde `GET /api/municipios` (activos) en todos los formularios; refrescar al activar/desactivar.
- Listados: usar endpoints filtrados; tras login adjuntar `Authorization` (token guardado en secure storage y SharedPreferences en web).
- Terminal SOS: visible sólo en admin/super_admin/coordinador; suscripción WS.
- Mensajes de error claros (403/401/404/500) con acciones sugeridas.

## Seguridad y Reglas Especiales
- Prohibir eliminación del super admin principal `wzuccardi@gmail.com` y evitar downgrade de ese rol.
- Prohibir creación de `super_admin` por roles distintos de `super_admin`.
- En endpoints admin: aplicar 403 a roles no permitidos.

## Reportes (PDF/Excel/CSV/TXT)
- Consolidar servicios de generación: PDF (`pdf_generator_service`), Excel (`excel_generator_service`), CSV (`csv_generator_service`), TXT (`txt_generator_service`).
- `GET /api/reportes` parametrizable por tipo de reporte y formato; retorna archivo o URL temporal.
- UI: módulo de reportes con selector de formato; acceso para admin/super_admin (coordinador opcional).

## Pruebas
- Casos por rol: madrina (crear/visualizar sólo propias; SOS visible), admin (asignar, gestión usuarios, contenidos, ver jerarquía), super_admin (todo; municipios).
- Endpoints 401/403: verificar acceso restringido.
- Reportes: generar cada formato con datos de prueba.
- Terminal SOS: emitir evento desde madrina y ver llegada en sesiones admin/coordinador/super.

## Despliegue y Verificación
- Reiniciar backend tras cambios de rutas/guards; hard reload del frontend (unregister SW) para tomar gating.
- Validar con usuario `wzuccardi@gmail.com` (super_admin) y `crepu@gmail.com` (madrina) los flujos descritos.

## Observaciones
- Fuentes: añadir Noto o similar en `pubspec.yaml` y `ThemeData` para cubrir caracteres.
- Documentar en código los guards y roles; evitar logs sensibles (passwords/tokens).
