/// Constantes básicas de la aplicación
library;
import '../../config/app_config.dart';

class AppConstants {
  // Privado para evitar instanciación
  AppConstants._();
  
  // URLs de API
  static String get apiBaseUrl => AppConfig.apiBaseUrl;
  static const String apiVersion = 'v1';
  static String get apiFullUrl => '$apiBaseUrl/$apiVersion';
  
  // Endpoints específicos
  static const String authEndpoint = '/auth';
  static const String gestantesEndpoint = '/gestantes';
  static const String medicosEndpoint = '/medicos';
  static const String ipsEndpoint = '/ips';
  static const String sosEndpoint = '/sos';
  static const String contenidoEndpoint = '/contenido';
  
  // Rutas de la aplicación
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String dashboardRoute = '/dashboard';
  static const String gestantesRoute = '/gestantes';
  static const String controlsRoute = '/controls';
  static const String alertsRoute = '/alerts';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String reportsRoute = '/reports';
  static const String notificationsRoute = '/notifications';
  static const String helpRoute = '/help';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute = '/reset-password';
  static const String aboutRoute = '/about';
  static const String contenidoListRoute = '/contenido/list';
  static const String contenidoDetailRoute = '/contenido/detail/:id';
  
  // Roles de usuario
  static const String adminRole = 'admin';
  static const String superAdminRole = 'super_admin';
  static const String madrinaRole = 'madrina';
  static const String medicoRole = 'medico';
  static const String gestanteRole = 'gestante';
  static const String coordinatorRole = 'coordinador';
  
  // Nombre de la aplicación
  static const String appName = 'Madres Digitales';
  
  // Claves de almacenamiento local
  static const String tokenKey = 'auth_token';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String themeKey = 'theme_mode';
  
  // Configuración de timeouts
  static const int defaultTimeout = 30000; // 30 segundos
  static const int longTimeout = 60000; // 60 segundos
  static const int shortTimeout = 10000; // 10 segundos
  static int get apiTimeout => AppConfig.connectionTimeout.inMilliseconds;
  
  // Límites de paginación
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Configuración de cache
  static const int cacheExpirationMinutes = 30;
  static const int maxCacheSize = 100; // MB
  static int get maxFileSize => AppConfig.maxFileSize;
  
  // Nombres de preferencias
  static const String prefFirstLaunch = 'first_launch';
  static const String prefNotificationsEnabled = 'notifications_enabled';
  static const String prefLocationEnabled = 'location_enabled';
  
  // Códigos de error comunes
  static const int errorCodeNetwork = 1001;
  static const int errorCodeAuth = 1002;
  static const int errorCodeNotFound = 1003;
  static const int errorCodeServer = 1004;
  static const int errorCodeTimeout = 1005;
  static const int errorCodeSessionExpired = 1006;
  static const int errorCodeInvalidToken = 1007;
  static const int errorCodeAuthentication = 1008;
  static const int errorCodeUnknown = 1009;
  
  // Formatos de fecha
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  
  // Expresiones regulares
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[0-9]{10,15}$';
  
  // Mensajes de error genéricos
  static const String genericErrorMessage = 'Ha ocurrido un error inesperado';
  static const String networkErrorMessage = 'Error de conexión. Verifica tu internet';
  static const String authErrorMessage = 'Error de autenticación';
  static const String unauthorizedMessage = 'No autorizado';
  static const String serverErrorMessage = 'Error en el servidor. Intenta más tarde';
  static const int maxLoginAttempts = 5;
}
