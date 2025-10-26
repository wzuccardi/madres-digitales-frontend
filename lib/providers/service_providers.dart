import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/auth_service.dart';
import 'package:madres_digitales_flutter_new/services/notification_service.dart';
import 'package:madres_digitales_flutter_new/services/permission_service.dart';
import 'package:madres_digitales_flutter_new/services/offline_service.dart';
import 'package:madres_digitales_flutter_new/services/contenido_service.dart';
import 'package:madres_digitales_flutter_new/services/dashboard_service.dart';
import 'package:madres_digitales_flutter_new/services/usuario_service.dart';
import 'package:madres_digitales_flutter_new/services/local_storage_service.dart';
import 'package:madres_digitales_flutter_new/services/contenido_sync_service.dart';
import 'package:madres_digitales_flutter_new/services/integrated_admin_service.dart';
import 'package:madres_digitales_flutter_new/services/alerta_service.dart';
import 'package:madres_digitales_flutter_new/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/models/dashboard_model.dart';
import 'package:madres_digitales_flutter_new/models/usuario_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';

/// Proveedor para SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Inicializando SharedPreferences');
  return await SharedPreferences.getInstance();
});

/// Proveedor para ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de ApiService');
  return ApiService();
});

/// Proveedor para AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de AuthService');
  return AuthService();
});

/// Proveedor para NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de NotificationService');
  return NotificationServiceStub();
});

/// Proveedor para PermissionService
final permissionServiceProvider = Provider<PermissionService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de PermissionService');
  final apiService = ref.read(apiServiceProvider);
  return PermissionServiceStub(apiService);
});

/// Proveedor para OfflineService
final offlineServiceProvider = FutureProvider<OfflineService>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de OfflineService');
  final prefs = await ref.read(sharedPreferencesProvider.future);
  return OfflineServiceStub(prefs: prefs);  // Corrección: Pasar prefs a OfflineService
});

/// Proveedor para ContenidoService
final contenidoServiceProvider = FutureProvider<ContenidoService>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de ContenidoService REAL');
  final apiService = ref.read(apiServiceProvider);
  final offlineService = await ref.read(offlineServiceProvider.future);
  
  // Crear el servicio real y inicializarlo
  final service = ContenidoService(apiService, offlineService);
  await service.initialize();
  
  appLogger.debug('🔧 [ServiceProvider] ContenidoService REAL inicializado exitosamente');
  return service;
});

/// Proveedor para DashboardService
final dashboardServiceProvider = FutureProvider<DashboardService>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de DashboardService');
  
  final prefs = await ref.read(sharedPreferencesProvider.future);  // Usar el provider de SharedPreferences
  final apiService = ref.read(apiServiceProvider);  // Obtener ApiService
  
  return DashboardService(prefs: prefs, apiService: apiService);
});

/// Proveedor para UsuarioService
final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de UsuarioService');
  final apiService = ref.read(apiServiceProvider);
  final offlineService = ref.read(offlineServiceProvider);
  final localStorageService = ref.read(localStorageServiceProvider);
  // Crear un stub temporal para offline service si no está disponible
  late final OfflineService offlineServiceInstance;
  try {
    offlineServiceInstance = offlineService.maybeWhen(
      data: (service) => service,
      orElse: () {
        // Crear un stub básico sin SharedPreferences
        return _createBasicOfflineStub();
      },
    );
  } catch (e) {
    offlineServiceInstance = _createBasicOfflineStub();
  }

  return UsuarioServiceStub(
    apiService: apiService,
    offlineService: offlineServiceInstance,
    localStorageService: localStorageService,
  );
});

// Helper para crear un stub básico de OfflineService
OfflineService _createBasicOfflineStub() {
  return _BasicOfflineServiceStub();
}

/// Proveedor para LocalStorageService
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de LocalStorageService');
  return LocalStorageServiceStub();
});

/// Proveedor para ContenidoSyncService
final contenidoSyncServiceProvider = FutureProvider<ContenidoSyncService>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de ContenidoSyncService');
  final contenidoService = await ref.read(contenidoServiceProvider.future);
  final localStorageService = ref.read(localStorageServiceProvider);
  final connectivityStream = ref.read(connectivityStateProvider);
  return ContenidoSyncServiceStub(
    contenidoService: contenidoService,
    localStorageService: localStorageService,
    connectivityStream: connectivityStream,
  );
});

/// Proveedor para IntegratedAdminService
final integratedAdminServiceProvider = FutureProvider<IntegratedAdminService>((ref) async {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de IntegratedAdminService');
  final apiService = ref.read(apiServiceProvider);
  final dashboardService = await ref.read(dashboardServiceProvider.future);
  final contenidoService = await ref.read(contenidoServiceProvider.future);
  return IntegratedAdminServiceStub(
    apiService: apiService,
    dashboardService: dashboardService,
    contenidoService: contenidoService,
  );
});

/// Proveedor para AlertaService
final alertaServiceProvider = Provider<AlertaService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de AlertaService');
  final apiService = ref.read(apiServiceProvider);
  return AlertaService(apiService);
});

/// Proveedor para datos simples (para screens que lo necesiten)
final simpleDataServiceProvider = Provider<SimpleDataService>((ref) {
  appLogger.debug('🔧 [ServiceProvider] Creando instancia de SimpleDataService');
  final apiService = ref.read(apiServiceProvider);
  return SimpleDataService(apiService: apiService);
});

/// Proveedor para el tema de la aplicación
final appThemeProvider = Provider<AppThemeData>((ref) {
  return AppThemeData(
    primaryColor: const Color(0xFF2E7D32), // Verde
    secondaryColor: const Color(0xFF81C784), // Verde claro
    backgroundColor: const Color(0xFFF5F5F5), // Gris muy claro
    surfaceColor: Colors.white,
    errorColor: const Color(0xFFD32F2F), // Rojo
    onPrimaryColor: Colors.white,
    onSecondaryColor: Colors.black,
    onBackgroundColor: Colors.black,
    onSurfaceColor: Colors.black,
    onErrorColor: Colors.white,
  );
});

/// Proveedor para el estado de conectividad
final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
  return ConnectivityNotifier();
});

/// Proveedor para el estado de conectividad (para uso en servicios)
final connectivityStateProvider = Provider<Stream<ConnectivityState>>((ref) {
  final notifier = ref.read(connectivityProvider.notifier);
  return notifier.stream;
});

/// Notificador para el estado de conectividad
class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  ConnectivityNotifier() : super(ConnectivityState.disconnected) {
    _checkConnectivity();
    // Verificar conectividad cada 30 segundos
    Timer.periodic(const Duration(seconds: 30), (_) => _checkConnectivity());
  }

  Future<void> _checkConnectivity() async {
    try {
      // En una implementación real, aquí se verificaría la conectividad
      // Por ahora, simulamos que siempre estamos conectados
      state = ConnectivityState.connected;
      appLogger.debug('Conectividad verificada: Conectado');
    } catch (e) {
      state = ConnectivityState.disconnected;
      appLogger.error('Error verificando conectividad: $e');
    }
  }

  void setConnectivity(bool isConnected) {
    state = isConnected ? ConnectivityState.connected : ConnectivityState.disconnected;
    appLogger.debug('Estado de conectividad actualizado: ${isConnected ? 'Conectado' : 'Desconectado'}');
  }
}

/// Estados de conectividad
enum ConnectivityState {
  connected,
  disconnected,
}

/// Datos del tema de la aplicación
class AppThemeData {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final Color onPrimaryColor;
  final Color onSecondaryColor;
  final Color onBackgroundColor;
  final Color onSurfaceColor;
  final Color onErrorColor;

  AppThemeData({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.onPrimaryColor,
    required this.onSecondaryColor,
    required this.onBackgroundColor,
    required this.onSurfaceColor,
    required this.onErrorColor,
  });

  /// Crear tema para Material App
  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: surfaceColor,
      ),
    );
  }
}

/// Proveedor para la configuración de la aplicación
final appConfigProvider = Provider<AppConfig>((ref) {
  return AppConfig(
    apiBaseUrl: 'http://localhost:54112/api',
    appName: 'Madres Digitales',
    appVersion: '1.0.0',
    enableLogging: true,
    enableCrashReporting: true,
    enableAnalytics: false,
    maxRetries: 3,
    timeout: const Duration(seconds: 30),
  );
});

/// Configuración de la aplicación
class AppConfig {
  final String apiBaseUrl;
  final String appName;
  final String appVersion;
  final bool enableLogging;
  final bool enableCrashReporting;
  final bool enableAnalytics;
  final int maxRetries;
  final Duration timeout;

  AppConfig({
    required this.apiBaseUrl,
    required this.appName,
    required this.appVersion,
    required this.enableLogging,
    required this.enableCrashReporting,
    required this.enableAnalytics,
    required this.maxRetries,
    required this.timeout,
  });
}

/// Proveedor para el estado de la aplicación
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

/// Notificador para el estado de la aplicación
class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState(
    isLoading: false,
    error: null,
    isConnected: true,
    isFirstLaunch: true,
  )) {
    _checkFirstLaunch();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void setConnected(bool connected) {
    state = state.copyWith(isConnected: connected);
  }

  void setFirstLaunch(bool isFirstLaunch) {
    state = state.copyWith(isFirstLaunch: isFirstLaunch);
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      
      state = state.copyWith(isFirstLaunch: isFirstLaunch);
      
      if (isFirstLaunch) {
        await prefs.setBool('is_first_launch', false);
        state = state.copyWith(isFirstLaunch: false);
      }
    } catch (e) {
      appLogger.error('Error verificando primer lanzamiento: $e');
    }
  }
}

/// Estado de la aplicación
class AppState {
  final bool isLoading;
  final String? error;
  final bool isConnected;
  final bool isFirstLaunch;

  AppState({
    required this.isLoading,
    this.error,
    required this.isConnected,
    required this.isFirstLaunch,
  });

  AppState copyWith({
    bool? isLoading,
    String? error,
    bool? isConnected,
    bool? isFirstLaunch,
  }) {
    return AppState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isConnected: isConnected ?? this.isConnected,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
    );
  }
}

/// Inicializador de servicios
class ServiceInitializer {
  static Future<void> initialize(ProviderContainer container) async {
    appLogger.info('Inicializando servicios...');
    
    try {
      // Inicializar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      // No se puede usar updateProvider en ProviderContainer
      // Se debe usar un Provider diferente o inicializar antes de crear el contenedor
      // Por ahora, lo dejamos comentado
      // container.updateProvider(sharedPreferencesProvider, (_) => prefs);
      
      // Configurar logger
      if (container.read(appConfigProvider).enableLogging) {
        appLogger.configure(
          minLevel: LogLevel.debug,
          enableConsole: true,
          enableFile: true,
        );
      }
      
      // Inicializar servicios que requieren inicialización explícita
      await _initializeNotificationService(container);
      await _initializePermissionService(container);
      
      appLogger.info('Servicios inicializados exitosamente');
    } catch (e) {
      appLogger.error('Error inicializando servicios: $e');
      rethrow;
    }
  }
  
  static Future<void> _initializeNotificationService(ProviderContainer container) async {
    try {
      final notificationService = container.read(notificationServiceProvider);
      await notificationService.initialize();
      appLogger.debug('NotificationService inicializado');
    } catch (e) {
      appLogger.error('Error inicializando NotificationService: $e');
    }
  }
  
  static Future<void> _initializePermissionService(ProviderContainer container) async {
    try {
      final permissionService = container.read(permissionServiceProvider);
      // PermissionService no tiene método initialize
      appLogger.debug('PermissionService inicializado');
    } catch (e) {
      appLogger.error('Error inicializando PermissionService: $e');
    }
  }
}

/// Stub para NotificationService
class NotificationServiceStub implements NotificationService {
  @override
  Future<void> initialize() async {
    appLogger.debug('NotificationServiceStub: initialize()');
  }
  
  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    appLogger.debug('NotificationServiceStub: showNotification($title, $body)');
  }
  
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.defaultPriority,
  }) async {
    appLogger.debug('NotificationServiceStub: scheduleNotification($title, $body)');
  }
  
  @override
  Future<void> showMedicalAlert({
    required String gestanteName,
    required String alertType,
    required String message,
    String? gestanteId,
  }) async {
    appLogger.debug('NotificationServiceStub: showMedicalAlert($gestanteName, $alertType)');
  }
  
  @override
  Future<void> scheduleControlReminder({
    required String gestanteName,
    required DateTime controlDate,
    required String gestanteId,
  }) async {
    appLogger.debug('NotificationServiceStub: scheduleControlReminder($gestanteName)');
  }
  
  @override
  Future<void> showSyncNotification({
    required bool success,
    required int syncedCount,
    int errorCount = 0,
  }) async {
    appLogger.debug('NotificationServiceStub: showSyncNotification($success, $syncedCount)');
  }
  
  @override
  Future<void> cancelNotification(int id) async {
    appLogger.debug('NotificationServiceStub: cancelNotification($id)');
  }
  
  @override
  Future<void> cancelAllNotifications() async {
    appLogger.debug('NotificationServiceStub: cancelAllNotifications()');
  }
  
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    appLogger.debug('NotificationServiceStub: getPendingNotifications()');
    return [];
  }
  
  @override
  Future<void> marcarComoLeido(String notificationId) async {
    appLogger.debug('NotificationServiceStub: marcarComoLeido($notificationId)');
  }
}

/// Stub para PermissionService
class PermissionServiceStub implements PermissionService {
  final ApiService _apiService;
  
  PermissionServiceStub(this._apiService);
  
  @override
  Future<bool> tienePermisoSobreGestante(String gestanteId, String accion) async {
    appLogger.debug('PermissionServiceStub: tienePermisoSobreGestante($gestanteId, $accion)');
    return true;
  }
  
  @override
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    appLogger.debug('PermissionServiceStub: invalidarPermisosGestante($gestanteId)');
  }
  
  @override
  Future<void> invalidarTodosLosPermisos() async {
    appLogger.debug('PermissionServiceStub: invalidarTodosLosPermisos()');
  }
  
  @override
  Future<void> limpiarCacheExpirado() async {
    appLogger.debug('PermissionServiceStub: limpiarCacheExpirado()');
  }
  
  @override
  Future<Map<String, dynamic>> obtenerEstadisticasCache() async {
    appLogger.debug('PermissionServiceStub: obtenerEstadisticasCache()');
    return {};
  }
  
  @override
  Future<bool> recargarPermisosDesdeAPI(String gestanteId) async {
    appLogger.debug('PermissionServiceStub: recargarPermisosDesdeAPI($gestanteId)');
    return true;
  }
  
  @override
  Future<Map<String, bool>> verificarMultiplesPermisos(String gestanteId, List<String> acciones) async {
    appLogger.debug('PermissionServiceStub: verificarMultiplesPermisos($gestanteId, $acciones)');
    return Map.fromEntries(acciones.map((a) => MapEntry(a, true)));
  }
  
  @override
  void dispose() {
    appLogger.debug('PermissionServiceStub: dispose()');
  }
}

/// Stub para OfflineService
class OfflineServiceStub implements OfflineService {
  final SharedPreferences _prefs;  // Corrección: Añadir prefs
  
  OfflineServiceStub({required SharedPreferences prefs}) : _prefs = prefs;  // Corrección: Constructor
  
  @override
  Future<void> saveEstadisticasCache(dynamic estadisticas) async {
    appLogger.debug('OfflineServiceStub: saveEstadisticasCache()');
  }
  
  @override
  Future<EstadisticasGeneralesModel?> getEstadisticasCache() async {
    appLogger.debug('OfflineServiceStub: getEstadisticasCache()');
    return null;
  }
  
  @override
  Future<void> clearEstadisticasCache() async {
    appLogger.debug('OfflineServiceStub: clearEstadisticasCache()');
  }
  
  @override
  Future<void> saveGestantesCache(List<Map<String, dynamic>> gestantes) async {
    appLogger.debug('OfflineServiceStub: saveGestantesCache()');
  }
  
  @override
  Future<List<Map<String, dynamic>>?> getGestantesCache() async {
    appLogger.debug('OfflineServiceStub: getGestantesCache()');
    return null;
  }
  
  @override
  Future<void> saveContenidosCache(List<Map<String, dynamic>> contenidos) async {
    appLogger.debug('OfflineServiceStub: saveContenidosCache()');
  }
  
  @override
  Future<List<Map<String, dynamic>>?> getContenidosCache() async {
    appLogger.debug('OfflineServiceStub: getContenidosCache()');
    return null;
  }
  
  @override
  Future<void> saveContenidosPorCategoriaCache(String categoria, List<Map<String, dynamic>> contenidos) async {
    appLogger.debug('OfflineServiceStub: saveContenidosPorCategoriaCache($categoria)');
  }
  
  @override
  Future<List<Map<String, dynamic>>?> getContenidosPorCategoriaCache(String categoria) async {
    appLogger.debug('OfflineServiceStub: getContenidosPorCategoriaCache($categoria)');
    return null;
  }
  
  @override
  Future<void> clearAllCache() async {
    appLogger.debug('OfflineServiceStub: clearAllCache()');
  }
  
  @override
  Future<bool> hasCachedData() async {
    appLogger.debug('OfflineServiceStub: hasCachedData()');
    return false;
  }
  
  @override
  Future<int> getCacheSize() async {
    appLogger.debug('OfflineServiceStub: getCacheSize()');
    return 0;
  }
  
  @override
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    appLogger.debug('OfflineServiceStub: saveOfflineData($key)');
  }
  
  @override
  Future<List<Map<String, dynamic>>> getOfflineData(String key) async {
    appLogger.debug('OfflineServiceStub: getOfflineData($key)');
    return [];
  }
  
  @override
  Future<void> syncPendingData() async {
    appLogger.debug('OfflineServiceStub: syncPendingData()');
  }
  
  @override
  Future<bool> reintentarOperacion(Future Function() operacion) async {
    appLogger.debug('OfflineServiceStub: reintentarOperacion()');
    return true;
  }
  
  @override
  Future<List<IpsModel>> getOfflineIps() async {
    appLogger.debug('OfflineServiceStub: getOfflineIps()');
    return [];
  }
  
  @override
  Future<List<MedicoModel>> getOfflineMedicos() async {
    appLogger.debug('OfflineServiceStub: getOfflineMedicos()');
    return [];
  }
  
  @override
  Future<void> saveOfflineIps(List<IpsModel> ipsList) async {
    appLogger.debug('OfflineServiceStub: saveOfflineIps(${ipsList.length})');
  }
  
  @override
  Future<void> saveOfflineMedicos(List<MedicoModel> medicosList) async {
    appLogger.debug('OfflineServiceStub: saveOfflineMedicos(${medicosList.length})');
  }
  
  @override
  Future<void> clearOfflineIps() async {
    appLogger.debug('OfflineServiceStub: clearOfflineIps()');
  }
  
  @override
  Future<void> clearOfflineMedicos() async {
    appLogger.debug('OfflineServiceStub: clearOfflineMedicos()');
  }
  
  @override
  Future<bool> hasOfflineIps() async {
    appLogger.debug('OfflineServiceStub: hasOfflineIps()');
    return false;
  }
  
  @override
  Future<bool> hasOfflineMedicos() async {
    appLogger.debug('OfflineServiceStub: hasOfflineMedicos()');
    return false;
  }
}

/// Stub básico para OfflineService sin dependencias
class _BasicOfflineServiceStub implements OfflineService {
  @override
  Future<void> saveEstadisticasCache(dynamic estadisticas) async {}
  
  @override
  Future<EstadisticasGeneralesModel?> getEstadisticasCache() async => null;
  
  @override
  Future<void> clearEstadisticasCache() async {}
  
  @override
  Future<void> saveGestantesCache(List<Map<String, dynamic>> gestantes) async {}
  
  @override
  Future<List<Map<String, dynamic>>?> getGestantesCache() async => null;
  
  @override
  Future<void> saveContenidosCache(List<Map<String, dynamic>> contenidos) async {}
  
  @override
  Future<List<Map<String, dynamic>>?> getContenidosCache() async => null;
  
  @override
  Future<void> saveContenidosPorCategoriaCache(String categoria, List<Map<String, dynamic>> contenidos) async {}
  
  @override
  Future<List<Map<String, dynamic>>?> getContenidosPorCategoriaCache(String categoria) async => null;
  
  @override
  Future<void> clearAllCache() async {}
  
  @override
  Future<bool> hasCachedData() async => false;
  
  @override
  Future<int> getCacheSize() async => 0;
  
  @override
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {}
  
  @override
  Future<List<Map<String, dynamic>>> getOfflineData(String key) async => [];
  
  @override
  Future<void> syncPendingData() async {}
  
  @override
  Future<bool> reintentarOperacion(Future Function() operacion) async => true;
  
  @override
  Future<List<IpsModel>> getOfflineIps() async => [];
  
  @override
  Future<List<MedicoModel>> getOfflineMedicos() async => [];
  
  @override
  Future<void> saveOfflineIps(List<IpsModel> ipsList) async {}
  
  @override
  Future<void> saveOfflineMedicos(List<MedicoModel> medicosList) async {}
  
  @override
  Future<void> clearOfflineIps() async {}
  
  @override
  Future<void> clearOfflineMedicos() async {}
  
  @override
  Future<bool> hasOfflineIps() async => false;
  
  @override
  Future<bool> hasOfflineMedicos() async => false;
}

// NOTA: ContenidoServiceStub eliminado - ahora usamos el ContenidoService real
// que hace llamadas reales al backend en lugar de devolver datos vacíos

/// Stub para UsuarioService
class UsuarioServiceStub implements UsuarioService {
  final ApiService _apiService;
  final OfflineService _offlineService;
  final LocalStorageService _localStorageService;
  
  UsuarioServiceStub({
    required ApiService apiService,
    required OfflineService offlineService,
    required LocalStorageService localStorageService,
  }) : _apiService = apiService,
       _offlineService = offlineService,
       _localStorageService = localStorageService;
  
  // Métodos de autenticación
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    appLogger.debug('UsuarioServiceStub: login($email)');
    return {'success': true, 'token': 'stub_token', 'user': {'id': '1', 'email': email}};
  }
  
  @override
  Future<void> logout() async {
    appLogger.debug('UsuarioServiceStub: logout()');
  }
  
  @override
  Future<Map<String, dynamic>?> getCurrentUser() async {
    appLogger.debug('UsuarioServiceStub: getCurrentUser()');
    return {'id': '1', 'email': 'user@example.com'};
  }
  
  @override
  Future<bool> isLoggedIn() async {
    appLogger.debug('UsuarioServiceStub: isLoggedIn()');
    return false;
  }
  
  @override
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    appLogger.debug('UsuarioServiceStub: register()');
    return {'success': true, 'user': userData};
  }
  
  @override
  Future<void> updateProfile(Map<String, dynamic> userData) async {
    appLogger.debug('UsuarioServiceStub: updateProfile()');
  }
  
  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    appLogger.debug('UsuarioServiceStub: changePassword()');
  }
  
  // Métodos de gestión de usuarios
  @override
  Future<List<UsuarioModel>> obtenerUsuarios({
    int? page,
    int? limit,
    String? search,
    RolUsuario? rol,
    String? departamento,
    String? municipio,
  }) async {
    appLogger.debug('UsuarioServiceStub: obtenerUsuarios()');
    
    try {
      final response = await _apiService.get('/usuarios');
      appLogger.debug('UsuarioServiceStub: Response received: ${response.data}');
      
      if (response.data is List) {
        final List<dynamic> usuariosData = response.data;
        return usuariosData.map((json) {
          // Convertir los datos del backend al modelo UsuarioModel
          return UsuarioModel(
            id: json['id'] ?? '',
            email: json['email'] ?? '',
            nombre: json['nombre'] ?? '',
            apellido: '', // El backend no tiene apellido separado
            documento: json['documento'] ?? '',
            telefono: json['telefono'],
            rol: json['rol'] ?? '',
            ipsId: json['municipio_id'],
            activo: json['activo'] ?? true,
            createdAt: DateTime.tryParse(json['fecha_creacion'] ?? '') ?? DateTime.now(),
            updatedAt: DateTime.tryParse(json['fecha_actualizacion'] ?? '') ?? DateTime.now(),
          );
        }).toList();
      }
      
      return [];
    } catch (e) {
      appLogger.error('UsuarioServiceStub: Error obteniendo usuarios', error: e);
      return [];
    }
  }
  
  @override
  Future<UsuarioModel> obtenerUsuarioPorId(String id) async {
    appLogger.debug('UsuarioServiceStub: obtenerUsuarioPorId($id)');
    // Devolver un usuario vacío con el ID proporcionado
    return UsuarioModel(
      id: id,
      email: 'user@example.com',
      nombre: 'Usuario',
      apellido: 'Test',
      documento: '123456789',
      telefono: '1234567890',
      rol: 'GESTANTE',
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<UsuarioModel> crearUsuario(UsuarioModel usuario) async {
    appLogger.debug('UsuarioServiceStub: crearUsuario()');
    return usuario;
  }
  
  @override
  Future<UsuarioModel> actualizarUsuario(String id, UsuarioModel usuario) async {
    appLogger.debug('UsuarioServiceStub: actualizarUsuario($id)');
    return usuario;
  }
  
  @override
  Future<bool> eliminarUsuario(String id) async {
    appLogger.debug('UsuarioServiceStub: eliminarUsuario($id)');
    return true;
  }
  
  @override
  Future<List<UsuarioModel>> buscarUsuariosPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    RolUsuario? rol,
  }) async {
    appLogger.debug('UsuarioServiceStub: buscarUsuariosPorUbicacion()');
    return [];
  }
  
  // Métodos de gestión de IPS
  @override
  Future<List<IpsModel>> obtenerIps({
    int? page,
    int? limit,
    String? search,
    NivelIps? nivel,
    String? departamento,
    String? municipio,
  }) async {
    appLogger.debug('UsuarioServiceStub: obtenerIps()');
    return [];
  }
  
  @override
  Future<IpsModel> obtenerIpsPorId(String id) async {
    appLogger.debug('UsuarioServiceStub: obtenerIpsPorId($id)');
    // Devolver una IPS vacía con el ID proporcionado
    return IpsModel(
      id: id,
      nombre: 'IPS Test',
      codigo: '12345',
      direccion: 'Dirección Test',
      telefono: '1234567890',
      nivel: 'PRIMARIO',
      ubicacionLatitud: 0.0,
      ubicacionLongitud: 0.0,
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<IpsModel> crearIps(IpsModel ips) async {
    appLogger.debug('UsuarioServiceStub: crearIps()');
    return ips;
  }
  
  @override
  Future<IpsModel> actualizarIps(String id, IpsModel ips) async {
    appLogger.debug('UsuarioServiceStub: actualizarIps($id)');
    return ips;
  }
  
  @override
  Future<List<IpsModel>> buscarIpsPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    NivelIps? nivel,
  }) async {
    appLogger.debug('UsuarioServiceStub: buscarIpsPorUbicacion()');
    return [];
  }
  
  // Métodos de gestión de médicos
  @override
  Future<List<MedicoModel>> obtenerMedicos({
    int? page,
    int? limit,
    String? search,
    String? especialidad,
    String? ipsId,
    String? departamento,
    String? municipio,
  }) async {
    appLogger.debug('UsuarioServiceStub: obtenerMedicos()');
    return [];
  }
  
  @override
  Future<MedicoModel> obtenerMedicoPorId(String id) async {
    appLogger.debug('UsuarioServiceStub: obtenerMedicoPorId($id)');
    // Devolver un médico vacío con el ID proporcionado
    return MedicoModel(
      id: id,
      usuarioId: id,
      registroMedico: '12345',
      especialidad: 'General',
      activo: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  @override
  Future<MedicoModel> crearMedico(MedicoModel medico) async {
    appLogger.debug('UsuarioServiceStub: crearMedico()');
    return medico;
  }
  
  @override
  Future<MedicoModel> actualizarMedico(String id, MedicoModel medico) async {
    appLogger.debug('UsuarioServiceStub: actualizarMedico($id)');
    return medico;
  }
  
  @override
  Future<List<MedicoModel>> buscarMedicosPorUbicacion({
    required double latitud,
    required double longitud,
    required double radioKm,
    String? especialidad,
  }) async {
    appLogger.debug('UsuarioServiceStub: buscarMedicosPorUbicacion()');
    return [];
  }
  
  @override
  Future<List<MedicoModel>> obtenerMedicosDisponibles({
    String? especialidad,
    DateTime? fecha,
    String? horario,
  }) async {
    appLogger.debug('UsuarioServiceStub: obtenerMedicosDisponibles()');
    return [];
  }
  
  @override
  Future<Map<String, dynamic>> obtenerEstadisticasUsuarios({
    String? departamento,
    String? municipio,
  }) async {
    appLogger.debug('UsuarioServiceStub: obtenerEstadisticasUsuarios()');
    return {'totalUsuarios': 0, 'usuariosActivos': 0};
  }
  
  @override
  Future<void> sincronizarDatosOffline() async {
    appLogger.debug('UsuarioServiceStub: sincronizarDatosOffline()');
  }
  
  @override
  Future<void> cerrarSesionRemota(String token) async {
    appLogger.debug('UsuarioServiceStub: cerrarSesionRemota()');
  }
  
  @override
  bool validarUsuario(UsuarioModel usuario) {
    appLogger.debug('UsuarioServiceStub: validarUsuario()');
    return true;
  }
  
  @override
  bool validarIps(IpsModel ips) {
    appLogger.debug('UsuarioServiceStub: validarIps()');
    return true;
  }
  
  @override
  bool validarMedico(MedicoModel medico) {
    appLogger.debug('UsuarioServiceStub: validarMedico()');
    return true;
  }
  

}

/// Stub para LocalStorageService
class LocalStorageServiceStub implements LocalStorageService {
  @override
  Future<void> saveString(String key, String value) async {
    appLogger.debug('LocalStorageServiceStub: saveString($key, $value)');
  }
  
  @override
  Future<String?> getString(String key) async {
    appLogger.debug('LocalStorageServiceStub: getString($key)');
    return null;
  }
  
  @override
  Future<void> saveInt(String key, int value) async {
    appLogger.debug('LocalStorageServiceStub: saveInt($key, $value)');
  }
  
  @override
  Future<int?> getInt(String key) async {
    appLogger.debug('LocalStorageServiceStub: getInt($key)');
    return null;
  }
  
  @override
  Future<void> saveBool(String key, bool value) async {
    appLogger.debug('LocalStorageServiceStub: saveBool($key, $value)');
  }
  
  @override
  Future<bool?> getBool(String key) async {
    appLogger.debug('LocalStorageServiceStub: getBool($key)');
    return null;
  }
  
  @override
  Future<void> saveObject(String key, dynamic value) async {
    appLogger.debug('LocalStorageServiceStub: saveObject($key)');
  }
  
  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    appLogger.debug('LocalStorageServiceStub: getObject($key)');
    return null;
  }
  
  @override
  Future<void> remove(String key) async {
    appLogger.debug('LocalStorageServiceStub: remove($key)');
  }
  
  @override
  Future<void> clear() async {
    appLogger.debug('LocalStorageServiceStub: clear()');
  }
  
  @override
  Future<void> saveContenido(ContenidoUnificado contenido) async {
    appLogger.debug('LocalStorageServiceStub: saveContenido(${contenido.id})');
  }
  
  @override
  Future<ContenidoUnificado?> getContenido(String id) async {
    appLogger.debug('LocalStorageServiceStub: getContenido($id)');
    return null;
  }
  
  @override
  Future<void> saveContenidos(List<ContenidoUnificado> contenidos) async {
    appLogger.debug('LocalStorageServiceStub: saveContenidos(${contenidos.length} contenidos)');
  }
  
  @override
  Future<List<ContenidoUnificado>?> getContenidos() async {
    appLogger.debug('LocalStorageServiceStub: getContenidos()');
    return [];
  }
  
  @override
  Future<void> clearAuthData() async {
    appLogger.debug('LocalStorageServiceStub: clearAuthData()');
  }
  
  @override
  Future<String?> getAuthToken() async {
    appLogger.debug('LocalStorageServiceStub: getAuthToken()');
    return null;
  }
  
  @override
  Future<String?> getRefreshToken() async {
    appLogger.debug('LocalStorageServiceStub: getRefreshToken()');
    return null;
  }
  
  @override
  Future<void> saveAuthToken(String token) async {
    appLogger.debug('LocalStorageServiceStub: saveAuthToken()');
  }
  
  @override
  Future<void> saveRefreshToken(String token) async {
    appLogger.debug('LocalStorageServiceStub: saveRefreshToken()');
  }
}

/// Stub para ContenidoSyncService
class ContenidoSyncServiceStub implements ContenidoSyncService {
  final ContenidoService _contenidoService;
  final LocalStorageService _localStorageService;
  final Stream<ConnectivityState> _connectivityStream;
  
  ContenidoSyncServiceStub({
    required ContenidoService contenidoService,
    required LocalStorageService localStorageService,
    required Stream<ConnectivityState> connectivityStream,
  }) : _contenidoService = contenidoService,
       _localStorageService = localStorageService,
       _connectivityStream = connectivityStream;
  
  @override
  Future<void> initialize() async {
    appLogger.debug('ContenidoSyncServiceStub: initialize()');
    
    // Escuchar cambios de conectividad
    _connectivityStream.listen((state) {
      appLogger.debug('ContenidoSyncServiceStub: Conectividad cambió a $state');
      if (state == ConnectivityState.connected) {
        syncContenidos();
      }
    });
  }
  
  @override
  Future<void> syncContenidos() async {
    appLogger.debug('ContenidoSyncServiceStub: syncContenidos()');
    try {
      // En una implementación real, aquí se sincronizarían los contenidos
      await Future.delayed(const Duration(milliseconds: 500));
      appLogger.debug('ContenidoSyncServiceStub: Sincronización completada');
    } catch (e) {
      appLogger.error('ContenidoSyncServiceStub: Error en sincronización', error: e);
    }
  }
  
  @override
  Stream<double> get syncProgress {
    appLogger.debug('ContenidoSyncServiceStub: syncProgress');
    return Stream.value(1.0);
  }
  
  @override
  bool get isSyncing {
    appLogger.debug('ContenidoSyncServiceStub: isSyncing');
    return false;
  }
  
  @override
  String? get syncError {
    appLogger.debug('ContenidoSyncServiceStub: syncError');
    return null;
  }
  
  @override
  Future<void> syncContenidosPorCategoria(String categoria) async {
    appLogger.debug('ContenidoSyncServiceStub: syncContenidosPorCategoria($categoria)');
    try {
      // En una implementación real, aquí se sincronizarían los contenidos por categoría
      await Future.delayed(const Duration(milliseconds: 500));
      appLogger.debug('ContenidoSyncServiceStub: Sincronización por categoría completada');
    } catch (e) {
      appLogger.error('ContenidoSyncServiceStub: Error en sincronización por categoría', error: e);
    }
  }
  
  @override
  void dispose() {
    appLogger.debug('ContenidoSyncServiceStub: dispose()');
  }
}

/// Stub para IntegratedAdminService
class IntegratedAdminServiceStub implements IntegratedAdminService {
  final ApiService _apiService;
  final DashboardService _dashboardService;
  final ContenidoService _contenidoService;
  
  // Getter para baseUrl
  @override
  String get baseUrl => 'http://localhost:54112/api';
  
  IntegratedAdminServiceStub({
    required ApiService apiService,
    required DashboardService dashboardService,
    required ContenidoService contenidoService,
  }) : _apiService = apiService,
       _dashboardService = dashboardService,
       _contenidoService = contenidoService;
  
  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    appLogger.debug('IntegratedAdminServiceStub: getDashboardStats()');
    return {};
  }
  
  @override
  Future<List<dynamic>> getAllContenidos() async {
    appLogger.debug('IntegratedAdminServiceStub: getAllContenidos()');
    return [];
  }
  
  @override
  Future<bool> createContenido(Map<String, dynamic> contenido) async {
    appLogger.debug('IntegratedAdminServiceStub: createContenido()');
    return true;
  }
  
  @override
  Future<bool> updateContenido(String id, Map<String, dynamic> contenido) async {
    appLogger.debug('IntegratedAdminServiceStub: updateContenido($id)');
    return true;
  }
  
  @override
  Future<bool> deleteContenido(String id) async {
    appLogger.debug('IntegratedAdminServiceStub: deleteContenido($id)');
    return true;
  }
  
  // Métodos de municipios
  @override
  Future<List<MunicipioIntegrado>> getMunicipiosIntegrados() async {
    appLogger.debug('IntegratedAdminServiceStub: getMunicipiosIntegrados()');
    return [];
  }
  
  @override
  Future<void> toggleMunicipioEstado(String municipioId, bool nuevoEstado) async {
    appLogger.debug('IntegratedAdminServiceStub: toggleMunicipioEstado($municipioId, $nuevoEstado)');
  }
  
  @override
  Future<MunicipioIntegrado> getMunicipioDetallado(String municipioId) async {
    appLogger.debug('IntegratedAdminServiceStub: getMunicipioDetallado($municipioId)');
    // Devolver un municipio vacío con el ID proporcionado
    return MunicipioIntegrado(
      id: municipioId,
      codigo: '123',
      nombre: 'Municipio Test',
      departamento: 'Departamento Test',
      activo: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }
  
  // Métodos de IPS
  @override
  Future<List<IPSIntegrada>> getIPSByMunicipio(String municipioId) async {
    appLogger.debug('IntegratedAdminServiceStub: getIPSByMunicipio($municipioId)');
    return [];
  }
  
  @override
  Future<List<IPSIntegrada>> getAllIPSIntegradas() async {
    appLogger.debug('IntegratedAdminServiceStub: getAllIPSIntegradas()');
    return [];
  }
  
  @override
  Future<void> toggleIPSEstado(String ipsId, bool nuevoEstado) async {
    appLogger.debug('IntegratedAdminServiceStub: toggleIPSEstado($ipsId, $nuevoEstado)');
  }
  
  @override
  Future<IPSIntegrada> createIPS(Map<String, dynamic> ipsData) async {
    appLogger.debug('IntegratedAdminServiceStub: createIPS()');
    // Devolver una IPSIntegrada vacía
    return IPSIntegrada(
      id: 'new_id',
      nombre: ipsData['nombre'] ?? 'IPS Test',
      direccion: ipsData['direccion'] ?? 'Dirección Test',
      telefono: ipsData['telefono'] ?? '1234567890',
      nivelAtencion: ipsData['nivelAtencion'] ?? 'primario',
      municipioId: ipsData['municipioId'] ?? 'municipio_test',
      activa: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }
  
  @override
  Future<IPSIntegrada> updateIPS(String ipsId, Map<String, dynamic> ipsData) async {
    appLogger.debug('IntegratedAdminServiceStub: updateIPS($ipsId)');
    // Devolver una IPSIntegrada vacía
    return IPSIntegrada(
      id: ipsId,
      nombre: ipsData['nombre'] ?? 'IPS Test',
      direccion: ipsData['direccion'] ?? 'Dirección Test',
      telefono: ipsData['telefono'] ?? '1234567890',
      nivelAtencion: ipsData['nivelAtencion'] ?? 'primario',
      municipioId: ipsData['municipioId'] ?? 'municipio_test',
      activa: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }
  
  // Métodos de médicos
  @override
  Future<List<MedicoIntegrado>> getMedicosByMunicipio(String municipioId) async {
    appLogger.debug('IntegratedAdminServiceStub: getMedicosByMunicipio($municipioId)');
    return [];
  }
  
  @override
  Future<List<MedicoIntegrado>> getMedicosByIPS(String ipsId) async {
    appLogger.debug('IntegratedAdminServiceStub: getMedicosByIPS($ipsId)');
    return [];
  }
  
  @override
  Future<List<MedicoIntegrado>> getAllMedicosIntegrados() async {
    appLogger.debug('IntegratedAdminServiceStub: getAllMedicosIntegrados()');
    return [];
  }
  
  @override
  Future<void> toggleMedicoEstado(String medicoId, bool nuevoEstado) async {
    appLogger.debug('IntegratedAdminServiceStub: toggleMedicoEstado($medicoId, $nuevoEstado)');
  }
  
  @override
  Future<MedicoIntegrado> createMedico(Map<String, dynamic> medicoData) async {
    appLogger.debug('IntegratedAdminServiceStub: createMedico()');
    // Devolver un MedicoIntegrado vacío
    return MedicoIntegrado(
      id: 'new_id',
      nombre: medicoData['nombre'] ?? 'Médico Test',
      documento: medicoData['documento'] ?? '123456789',
      especialidad: medicoData['especialidad'] ?? 'General',
      registroMedico: medicoData['registroMedico'] ?? '12345',
      ipsId: medicoData['ipsId'] ?? 'ips_test',
      activo: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }
  
  @override
  Future<MedicoIntegrado> updateMedico(String medicoId, Map<String, dynamic> medicoData) async {
    appLogger.debug('IntegratedAdminServiceStub: updateMedico($medicoId)');
    // Devolver un MedicoIntegrado vacío
    return MedicoIntegrado(
      id: medicoId,
      nombre: medicoData['nombre'] ?? 'Médico Test',
      documento: medicoData['documento'] ?? '123456789',
      especialidad: medicoData['especialidad'] ?? 'General',
      registroMedico: medicoData['registroMedico'] ?? '12345',
      ipsId: medicoData['ipsId'] ?? 'ips_test',
      activo: true,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    );
  }
  
  @override
  Future<void> asignarMedicoAIPS(String medicoId, String ipsId) async {
    appLogger.debug('IntegratedAdminServiceStub: asignarMedicoAIPS($medicoId, $ipsId)');
  }
  
  // Métodos de resumen y estadísticas
  @override
  Future<ResumenIntegrado> getResumenIntegrado() async {
    appLogger.debug('IntegratedAdminServiceStub: getResumenIntegrado()');
    // Devolver un ResumenIntegrado vacío
    return ResumenIntegrado(
      totalMunicipios: 0,
      municipiosActivos: 0,
      totalIPS: 0,
      ipsActivas: 0,
      totalMedicos: 0,
      medicosActivos: 0,
      totalGestantes: 0,
      gestantesActivas: 0,
      alertasActivas: 0,
      controlesEsteMes: 0,
    );
  }
  
  @override
  Future<Map<String, dynamic>> getEstadisticasMunicipio(String municipioId) async {
    appLogger.debug('IntegratedAdminServiceStub: getEstadisticasMunicipio($municipioId)');
    return {};
  }
  
  @override
  Future<Map<String, dynamic>> getEstadisticasIPS(String ipsId) async {
    appLogger.debug('IntegratedAdminServiceStub: getEstadisticasIPS($ipsId)');
    return {};
  }
  
  @override
  Future<Map<String, dynamic>> getEstadisticasMedico(String medicoId) async {
    appLogger.debug('IntegratedAdminServiceStub: getEstadisticasMedico($medicoId)');
    return {};
  }
  
  // Métodos de búsqueda y filtros
  @override
  Future<Map<String, dynamic>> buscarIntegrado(String query) async {
    appLogger.debug('IntegratedAdminServiceStub: buscarIntegrado($query)');
    return {
      'municipios': [],
      'ips': [],
      'medicos': [],
    };
  }
  
  @override
  Future<List<MunicipioIntegrado>> getMunicipiosConFiltros({
    bool? activo,
    String? departamento,
    int? minGestantes,
    int? maxGestantes,
    bool? tieneIPS,
    bool? tieneMedicos,
  }) async {
    appLogger.debug('IntegratedAdminServiceStub: getMunicipiosConFiltros()');
    return [];
  }
  
  // Métodos de operaciones masivas
  @override
  Future<void> toggleMultiplesMunicipios(List<String> municipioIds, bool nuevoEstado) async {
    appLogger.debug('IntegratedAdminServiceStub: toggleMultiplesMunicipios(${municipioIds.length}, $nuevoEstado)');
  }
  
  @override
  Future<void> sincronizarDatos() async {
    appLogger.debug('IntegratedAdminServiceStub: sincronizarDatos()');
  }
  
  @override
  Future<Map<String, dynamic>> generarReporteIntegrado({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    List<String>? municipioIds,
  }) async {
    appLogger.debug('IntegratedAdminServiceStub: generarReporteIntegrado()');
    return {};
  }
}

/// Stub para SimpleDataService
class SimpleDataService {
  final ApiService _apiService;
  
  SimpleDataService({required ApiService apiService}) : _apiService = apiService;
  
  Future<List<Map<String, dynamic>>> obtenerGestantes() async {
    appLogger.debug('SimpleDataService: getGestantes()');
    return [];
  }
  
  Future<List<Map<String, dynamic>>> getControles() async {
    appLogger.debug('SimpleDataService: getControles()');
    return [];
  }
  
  Future<List<Map<String, dynamic>>> getAlertas() async {
    appLogger.debug('SimpleDataService: getAlertas()');
    return [];
  }
  
  Future<List<Map<String, dynamic>>> getContenidos() async {
    appLogger.debug('SimpleDataService: getContenidos()');
    return [];
  }
  
  Future<List<Map<String, dynamic>>> getIPSCercanas() async {
    appLogger.debug('SimpleDataService: getIPSCercanas()');
    return [];
  }
  
  List<Map<String, dynamic>> filtrarControlesPorEstado(List<Map<String, dynamic>> controles, String estado) {
    appLogger.debug('SimpleDataService: filtrarControlesPorEstado($estado)');
    return controles.where((control) => control['estado'] == estado).toList();
  }
}