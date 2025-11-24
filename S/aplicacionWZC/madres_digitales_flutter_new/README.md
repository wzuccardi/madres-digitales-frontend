# 🤰 Madres Digitales - Frontend Flutter

Aplicación móvil y web para el monitoreo de salud materna en Bolívar, Colombia.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Tecnologías](#tecnologías)
- [Requisitos Previos](#requisitos-previos)
- [Instalación](#instalación)
- [Configuración](#configuración)
- [Ejecución](#ejecución)
- [Build](#build)
- [Arquitectura](#arquitectura)
- [Deployment](#deployment)

## ✨ Características

- 📱 **Multiplataforma**: Android, iOS y Web
- 🎨 **Material Design 3** con tema personalizado
- 🔐 **Autenticación segura** con JWT
- 📊 **Dashboard interactivo** con estadísticas
- 🗺️ **Mapas integrados** con geolocalización
- 📝 **Formularios dinámicos** para controles prenatales
- 🔔 **Sistema de alertas** en tiempo real
- 📤 **Sincronización offline** (próximamente)
- 🌐 **Internacionalización** (ES/EN)

## 🛠️ Tecnologías

- **Framework**: Flutter 3.19.6
- **Lenguaje**: Dart 3.3+
- **State Management**: Provider
- **HTTP Client**: Dio
- **Storage**: SharedPreferences
- **Maps**: Google Maps Flutter
- **Charts**: FL Chart
- **Icons**: Material Icons + Custom

## 📦 Requisitos Previos

- Flutter SDK >= 3.19.6
- Dart SDK >= 3.3.0
- Android Studio / Xcode (para desarrollo móvil)
- Chrome (para desarrollo web)

## 🚀 Instalación

```bash
# Clonar el repositorio
git clone https://github.com/wzuccardi/madres-digitales-frontend-CleanArchitecture.git
cd madres_digitales_flutter_new

# Instalar dependencias
flutter pub get

# Verificar instalación
flutter doctor
```

## ⚙️ Configuración

### Variables de Entorno

Crear archivo `lib/config/environment.dart`:

```dart
class Environment {
  static const String apiUrl = 'http://localhost:3000/api';
  static const String environment = 'development';
  
  // Producción
  // static const String apiUrl = 'https://api.tudominio.com/api';
  // static const String environment = 'production';
}
```

### API Configuration

Editar `lib/application/providers/auth_provider.dart` para configurar la URL del backend:

```dart
final dio = Dio(BaseOptions(
  baseUrl: Environment.apiUrl,
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));
```

## 🏃 Ejecución

### Desarrollo

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios

# Modo debug con hot reload
flutter run --debug
```

### Seleccionar Dispositivo

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device-id>
```

## 🔨 Build

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs por ABI (recomendado)
flutter build apk --split-per-abi --release

# Ubicación: build/app/outputs/flutter-apk/
```

### Android App Bundle (Google Play)

```bash
# Release AAB
flutter build appbundle --release

# Ubicación: build/app/outputs/bundle/release/
```

### iOS

```bash
# Release IPA
flutter build ios --release

# Abrir en Xcode para firmar y distribuir
open ios/Runner.xcworkspace
```

### Web

```bash
# Build para producción
flutter build web --release --web-renderer canvaskit

# Build con optimizaciones
flutter build web --release \
  --web-renderer canvaskit \
  --no-tree-shake-icons \
  --csp

# Ubicación: build/web/
```

## 🏗️ Arquitectura

### Clean Architecture

```
lib/
├── application/              # Capa de aplicación
│   ├── providers/           # State management (Provider)
│   ├── use_cases/           # Casos de uso
│   └── services/            # Servicios de aplicación
├── domain/                   # Capa de dominio
│   ├── entities/            # Entidades de negocio
│   ├── repositories/        # Interfaces de repositorios
│   └── errors/              # Errores de dominio
├── infrastructure/           # Capa de infraestructura
│   ├── repositories/        # Implementaciones de repositorios
│   ├── datasources/         # Fuentes de datos (API, Local)
│   └── models/              # Modelos de datos
├── presentation/             # Capa de presentación
│   ├── screens/             # Pantallas
│   ├── widgets/             # Widgets reutilizables
│   └── theme/               # Tema y estilos
└── config/                   # Configuración
    ├── routes/              # Rutas de navegación
    └── constants/           # Constantes
```

### Capas

1. **Domain Layer**: Lógica de negocio pura
2. **Application Layer**: Casos de uso y providers
3. **Infrastructure Layer**: Implementaciones técnicas
4. **Presentation Layer**: UI y widgets

## 📱 Pantallas Principales

### Autenticación
- Login
- Recuperar contraseña

### Dashboard
- Estadísticas generales
- Alertas recientes
- Accesos rápidos

### Gestantes
- Lista de gestantes
- Detalle de gestante
- Crear/Editar gestante
- Historial de controles

### Controles Prenatales
- Lista de controles
- Crear control
- Detalle de control
- Gráficas de evolución

### Alertas
- Lista de alertas
- Detalle de alerta
- Gestión de alertas

### Perfil
- Información del usuario
- Configuración
- Cerrar sesión

## 🎨 Tema y Estilos

### Colores Principales

```dart
// Primary
Color(0xFF2196F3) // Blue

// Secondary
Color(0xFFFF4081) // Pink

// Success
Color(0xFF4CAF50) // Green

// Warning
Color(0xFFFFC107) // Amber

// Error
Color(0xFFF44336) // Red
```

### Tipografía

- **Familia**: Roboto
- **Tamaños**: 12, 14, 16, 18, 20, 24, 32

## 🔐 Autenticación

### Flow

1. Usuario ingresa credenciales
2. App envía request a `/api/auth/login`
3. Backend valida y retorna JWT + Refresh Token
4. App guarda tokens en SharedPreferences
5. Todas las requests incluyen JWT en header
6. Si JWT expira, usa Refresh Token para renovar

### Implementación

```dart
// Login
final response = await authProvider.login(email, password);

// Verificar autenticación
final isAuthenticated = authProvider.isAuthenticated;

// Obtener usuario actual
final user = authProvider.currentUser;

// Logout
await authProvider.logout();
```

## 📊 State Management

### Provider Pattern

```dart
// Definir Provider
class GestantesProvider extends ChangeNotifier {
  List<Gestante> _gestantes = [];
  
  Future<void> fetchGestantes() async {
    _gestantes = await repository.getGestantes();
    notifyListeners();
  }
}

// Usar en Widget
Consumer<GestantesProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.gestantes.length,
      itemBuilder: (context, index) {
        return GestanteCard(provider.gestantes[index]);
      },
    );
  },
)
```

## 🚢 Deployment

### Web (Vercel/Netlify)

```bash
# Build
flutter build web --release

# Deploy a Vercel
vercel --prod

# Deploy a Netlify
netlify deploy --prod --dir=build/web
```

### Android (Google Play)

1. **Configurar Signing**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. **Configurar key.properties**
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. **Build AAB**
   ```bash
   flutter build appbundle --release
   ```

4. **Subir a Google Play Console**

### iOS (App Store)

1. **Configurar en Xcode**
   - Signing & Capabilities
   - Bundle Identifier
   - Version & Build Number

2. **Build**
   ```bash
   flutter build ios --release
   ```

3. **Archive y Upload**
   - Product > Archive en Xcode
   - Upload to App Store Connect

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Tests con cobertura
flutter test --coverage

# Tests de integración
flutter test integration_test/
```

## 📝 Convenciones de Código

### Naming

- **Archivos**: snake_case (gestante_card.dart)
- **Clases**: PascalCase (GestanteCard)
- **Variables**: camelCase (gestantesList)
- **Constantes**: UPPER_SNAKE_CASE (API_URL)

### Estructura de Archivos

```dart
// Imports
import 'package:flutter/material.dart';

// Widget
class MyWidget extends StatelessWidget {
  // Constructor
  const MyWidget({super.key});
  
  // Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

## 🔧 Troubleshooting

### Error: Gradle build failed

```bash
# Limpiar build
flutter clean
flutter pub get
flutter build apk
```

### Error: CocoaPods not installed

```bash
# Instalar CocoaPods
sudo gem install cocoapods
pod setup
```

### Error: Web renderer issues

```bash
# Usar CanvasKit
flutter run -d chrome --web-renderer canvaskit

# O HTML
flutter run -d chrome --web-renderer html
```

## 📞 Soporte

- **Email**: wzuccardi@gmail.com
- **GitHub**: https://github.com/wzuccardi/madres-digitales-frontend-CleanArchitecture

## 📄 Licencia

Privado - Todos los derechos reservados

## 👨‍💻 Equipo

- **Desarrollador Principal**: Wilson Zuccardi
- **Email**: wzuccardi@gmail.com
