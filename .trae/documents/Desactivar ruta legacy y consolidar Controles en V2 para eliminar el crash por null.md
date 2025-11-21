## Objetivo
- Eliminar el residuo de rutas que siguen montando el formulario legacy/mejorado y consolidar el flujo de Controles en V2, que ya es tolerante a null.

## Acciones
- Router
  - Cambiar `AppConstants.controlsRoute` para que apunte a `ControlesListV2Page` (ruta `'/controles-v2'`).
  - Quitar la importación y el uso de `ControlPrenatalMejoradoScreen` del router.
  - Buscar y actualizar todas las navegaciones `context.go(AppConstants.controlsRoute)` para que apunten a `'/controles-v2'`.
- Pantallas
  - Dejar `control_prenatal_mejorado_screen.dart` accesible solo desde V2 si se necesita como subform, o desregistrarla temporalmente del router para evitar montaje indirecto.
  - En caso de reuso, revisar y eliminar cualquier uso restante de `!` (null check) y validar estados con `?.`.
- Reinicio
  - Parar y levantar Flutter web en modo release (sin DDS) para limpiar caché y reflejar el router actualizado.

## Verificación
- Navegar desde dashboard al card “Controles V2 (beta)” y también usando cualquier botón “Controles” previamente existente; ambas rutas deben llevar al listado V2 sin crash.
- Abrir detalle y crear un control desde V2; confirmar que no aparece “Null check operator used on a null value”.

## Migración definitiva
- Una vez validado, retirar rutas legacy de controles del router y referencias en el dashboard/menús, dejando V2 como flujo único.