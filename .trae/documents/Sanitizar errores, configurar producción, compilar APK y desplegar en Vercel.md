## Alcance
- Backend en `madres-digitales-backend` (Node/Express + Prisma) desplegado en Vercel Functions según `vercel.json` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\vercel.json:2-13) y export de `api/index.js` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\api\index.js:3529-3530).
- App Flutter en `madres_digitales_flutter_new` con URLs controladas por `ENVIRONMENT` (c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\lib\config\app_config.dart:5-15). Confirmación adicional de `BACKEND_URL` en `c:\Madrinas\S\genio\.env.configuracionVercel:23`.

## Garantía de Datos
- No se perderán datos: solo conectamos con la BD existente vía `DATABASE_URL` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\prisma\schema.prisma:5-8).
- Evitamos comandos destructivos (`migrate reset`) y no ejecutamos seeds en producción.
- Antes de cualquier migración, haremos backup (`pg_dump`) y validaremos que no existan operaciones destructivas.

## Backend Producción
- Variables en Vercel: `DATABASE_URL`, `JWT_SECRET`, `JWT_REFRESH_SECRET`, `JWT_EXPIRES_IN`, `JWT_REFRESH_EXPIRES_IN`, `CORS_ORIGINS`, `LOG_LEVEL`, `RATE_LIMIT_*` tomando como guía `.env.production.example` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\.env.production.example:7-33).
- Sanitización de JWT: eliminar fallback `'dev-secret'` en producción y fallar si falta secreto (usos detectados en c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\api\index.js:49,599,849,2732,2834).
- CORS: parametrizar por `CORS_ORIGINS` y validar con `test-cors.js` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\test-cors.js:4-11,16-29).
- Build/Deploy: usar `vercel-build` y `postinstall` para `prisma generate` (c:\Madrinas\S\aplicacionWZC\madres-digitales-backend\package.json:7-11), luego `vercel --prod`.

## Flutter APK
- Preparación: `flutter clean && flutter pub get`.
- Compilación producción: `flutter build apk --release --dart-define=ENVIRONMENT=production` para apuntar a `https://madres-digitales-backend.vercel.app/api` (c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\lib\config\app_config.dart:8-15).
- Artefacto: `android/app/build/outputs/flutter-apk/app-release.apk`.
- Firma: actualmente `debug` (c:\Madrinas\S\aplicacionWZC\madres_digitales_flutter_new\android\app\build.gradle.kts:33-36); si se requiere firma release, generar keystore y actualizar `signingConfig`.

## Validaciones
- Backend: `GET /api/health` y `/api/dashboard/estadisticas` en Vercel; pruebas CORS desde frontend `https://madres-digitales-frontend.vercel.app`.
- Flutter: pruebas de login y flujos principales con la API de producción.

## Comandos a Ejecutar
- Backup BD: `pg_dump --file backup.sql "$Env:DATABASE_URL"`.
- Prisma: `npm install && npx prisma generate` y, si hay migraciones, `DATABASE_URL="<prod>" npx prisma migrate deploy`.
- Vercel vars: `vercel env add <VAR> production` para cada variable clave.
- Deploy: `vercel --prod`.
- Flutter: `flutter clean && flutter pub get && flutter build apk --release --dart-define=ENVIRONMENT=production`.

## Entregables
- Backend funcionando en Vercel con CORS correcto y BD intacta.
- APK `app-release.apk` compilada en modo producción.
- Registro de pasos y URLs finales.

¿Confirmas que proceda con estos pasos ahora mismo?