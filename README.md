# Madres Digitales - Frontend

Aplicación web Flutter para el sistema de seguimiento de gestantes "Madres Digitales".

## 🚀 Características

- **Dashboard interactivo** para seguimiento de gestantes
- **Sistema de alertas** en tiempo real
- **Gestión de controles prenatales**
- **Reportes y estadísticas**
- **Interfaz responsive** para web y móvil
- **Autenticación segura** con roles de usuario

## 🛠️ Tecnologías

- **Flutter 3.x** - Framework de desarrollo
- **Dart** - Lenguaje de programación
- **Riverpod** - Gestión de estado
- **Go Router** - Navegación
- **Dio** - Cliente HTTP
- **Material Design 3** - Sistema de diseño

## 📦 Instalación

### Prerrequisitos

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Chrome (para desarrollo web)

### Configuración

1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/madres-digitales-frontend.git
cd madres-digitales-frontend
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run -d chrome
```

## 🌐 Despliegue

### Vercel (Recomendado)

1. Conecta tu repositorio con Vercel
2. Configura las variables de entorno si es necesario
3. Vercel detectará automáticamente que es un proyecto Flutter
4. El build se ejecutará automáticamente

### Build manual

```bash
flutter build web --release
```

Los archivos se generarán en `build/web/`

## 🔧 Configuración

### Variables de entorno

La configuración principal se encuentra en `lib/config/app_config.dart`:

- `backendBaseUrl`: URL del backend en producción
- `backendBaseUrlDev`: URL del backend en desarrollo

### Roles de usuario

- **Super Admin**: Acceso completo al sistema
- **Admin**: Gestión de usuarios y configuración
- **Coordinador**: Supervisión de madrinas y gestantes
- **Médico**: Gestión de controles prenatales
- **Madrina**: Seguimiento de gestantes asignadas

## 📱 Funcionalidades

### Dashboard
- Resumen de estadísticas generales
- Alertas pendientes
- Controles próximos
- Gráficos y métricas

### Gestión de Gestantes
- Registro y edición de gestantes
- Asignación de madrinas
- Seguimiento de embarazo
- Historial médico

### Sistema de Alertas
- Alertas automáticas por riesgo
- Alertas SOS de emergencia
- Notificaciones en tiempo real
- Seguimiento de resolución

### Reportes
- Estadísticas por municipio
- Reportes de controles
- Análisis de riesgo
- Exportación de datos

## 🏗️ Arquitectura

```
lib/
├── config/          # Configuración de la app
├── features/        # Funcionalidades por módulos
├── providers/       # Providers de Riverpod
├── screens/         # Pantallas principales
├── services/        # Servicios y APIs
├── shared/          # Componentes compartidos
├── utils/           # Utilidades y helpers
└── widgets/         # Widgets reutilizables
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Desarrollo**: Wilson Zuccardi
- **Diseño UX/UI**: Equipo Madres Digitales
- **Backend**: Node.js + PostgreSQL

## 📞 Soporte

Para soporte técnico o preguntas:
- Email: soporte@madresdigitales.com
- Issues: [GitHub Issues](https://github.com/tu-usuario/madres-digitales-frontend/issues)

---

Desarrollado con ❤️ para mejorar la atención materno-infantil en Colombia.