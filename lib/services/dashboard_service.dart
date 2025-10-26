import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/models/dashboard_models.dart';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/config/app_config.dart';

/// Servicio para obtener datos del dashboard
class DashboardService {
  static const String _statsCacheKey = 'dashboard_stats_cache';
  static const String _lastUpdateKey = 'dashboard_last_update';
  static const Duration _cacheExpiration = Duration(minutes: 30);
  
  final SharedPreferences _prefs;
  final String _baseUrl;
  final Duration _timeout;
  final ApiService _apiService;

  DashboardService({
    required SharedPreferences prefs,
    required ApiService apiService,
    String? baseUrl,
    Duration timeout = const Duration(seconds: 30),
  }) : _prefs = prefs,
       _baseUrl = baseUrl ?? AppConfig.backendBaseUrl,
       _timeout = timeout,
       _apiService = apiService;

  /// Obtener estadísticas generales del dashboard
  Future<DashboardStats> obtenerEstadisticasGenerales() async {
    try {
      appLogger.info('Obteniendo estadísticas generales del dashboard...');
      
      // Intentar obtener datos frescos de la API primero
      appLogger.info('Intentando obtener datos frescos de la API...');
      final stats = await _fetchStatsFromApi();
      
      // Guardar en cache
      await _cacheStats(stats);
      
      appLogger.info('Estadísticas generales obtenidas exitosamente desde la API');
      return stats;
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas desde la API: $e');
      
      // En caso de error, intentar obtener datos del cache
      appLogger.info('Intentando obtener datos del cache...');
      final cachedStats = await _getCachedStats(ignoreExpiration: true);
      if (cachedStats != null) {
        appLogger.warn('Usando datos del cache debido a error en la API');
        return cachedStats;
      }
      
      // Si no hay datos en cache, retornar datos vacíos
      appLogger.warn('No hay datos disponibles ni en API ni en cache, retornando estadísticas vacías');
      return DashboardStats.empty();
    }
  }

  /// Obtener estadísticas por municipio
  Future<DashboardStats> obtenerEstadisticasPorMunicipio(String municipioId) async {
    try {
      appLogger.info('Obteniendo estadísticas del municipio: $municipioId');
      
      // Verificar si hay datos en cache válidos
      final cacheKey = '${_statsCacheKey}_municipio_$municipioId';
      final cachedStats = await _getCachedStats(cacheKey: cacheKey);
      if (cachedStats != null) {
        appLogger.info('Estadísticas de municipio obtenidas desde cache');
        return cachedStats;
      }
      
      // Simular llamada a la API (en una implementación real, aquí se haría la llamada HTTP)
      final stats = await _fetchStatsFromApi(municipioId: municipioId);
      
      // Guardar en cache
      await _cacheStats(stats, cacheKey: cacheKey);
      
      appLogger.info('Estadísticas de municipio obtenidas exitosamente');
      return stats;
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas del municipio: $e');
      
      // En caso de error, intentar obtener datos del cache aunque estén expirados
      final cacheKey = '${_statsCacheKey}_municipio_$municipioId';
      final cachedStats = await _getCachedStats(cacheKey: cacheKey, ignoreExpiration: true);
      if (cachedStats != null) {
        appLogger.warn('Usando datos expirados del cache debido a error');
        return cachedStats;
      }
      
      // Si no hay datos en cache, retornar datos vacíos
      appLogger.warn('No hay datos disponibles, retornando estadísticas vacías');
      return DashboardStats.empty();
    }
  }

  /// Obtener estadísticas por período
  Future<DashboardStats> obtenerEstadisticasPorPeriodo({
    required DateTime startDate,
    required DateTime endDate,
    String? municipioId,
  }) async {
    try {
      appLogger.info('Obteniendo estadísticas por período: ${startDate.toIso8601String()} - ${endDate.toIso8601String()}');
      
      // Crear clave de cache basada en el período
      final periodKey = '${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';
      final cacheKey = municipioId != null 
          ? '${_statsCacheKey}_period_${periodKey}_municipio_$municipioId'
          : '${_statsCacheKey}_period_$periodKey';
      
      // Verificar si hay datos en cache válidos
      final cachedStats = await _getCachedStats(cacheKey: cacheKey);
      if (cachedStats != null) {
        appLogger.info('Estadísticas de período obtenidas desde cache');
        return cachedStats;
      }
      
      // Simular llamada a la API (en una implementación real, aquí se haría la llamada HTTP)
      final stats = await _fetchStatsFromApi(
        startDate: startDate,
        endDate: endDate,
        municipioId: municipioId,
      );
      
      // Guardar en cache
      await _cacheStats(stats, cacheKey: cacheKey);
      
      appLogger.info('Estadísticas de período obtenidas exitosamente');
      return stats;
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas por período: $e');
      
      // En caso de error, intentar obtener datos del cache aunque estén expirados
      final periodKey = '${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';
      final cacheKey = municipioId != null 
          ? '${_statsCacheKey}_period_${periodKey}_municipio_$municipioId'
          : '${_statsCacheKey}_period_$periodKey';
      
      final cachedStats = await _getCachedStats(cacheKey: cacheKey, ignoreExpiration: true);
      if (cachedStats != null) {
        appLogger.warn('Usando datos expirados del cache debido a error');
        return cachedStats;
      }
      
      // Si no hay datos en cache, retornar datos vacíos
      appLogger.warn('No hay datos disponibles, retornando estadísticas vacías');
      return DashboardStats.empty();
    }
  }

  /// Forzar actualización de datos (ignorar cache)
  Future<DashboardStats> actualizarEstadisticas({String? municipioId}) async {
    try {
      appLogger.info('Forzando actualización de estadísticas...');
      
      // Limpiar cache
      if (municipioId != null) {
        final cacheKey = '${_statsCacheKey}_municipio_$municipioId';
        await _prefs.remove(cacheKey);
        await _prefs.remove('${cacheKey}_timestamp');
      } else {
        await _prefs.remove(_statsCacheKey);
        await _prefs.remove(_lastUpdateKey);
      }
      
      // Obtener datos actualizados
      if (municipioId != null) {
        return await obtenerEstadisticasPorMunicipio(municipioId);
      } else {
        return await obtenerEstadisticasGenerales();
      }
    } catch (e) {
      appLogger.error('Error actualizando estadísticas: $e');
      return DashboardStats.empty();
    }
  }

  /// Obtener datos cacheados
  Future<DashboardStats?> _getCachedStats({
    String cacheKey = _statsCacheKey,
    bool ignoreExpiration = false,
  }) async {
    try {
      final statsJson = _prefs.getString(cacheKey);
      final timestampJson = _prefs.getString('${cacheKey}_timestamp');
      
      if (statsJson == null || timestampJson == null) {
        return null;
      }
      
      // Verificar si el cache ha expirado
      if (!ignoreExpiration) {
        final lastUpdate = DateTime.parse(timestampJson);
        final now = DateTime.now();
        
        if (now.difference(lastUpdate) > _cacheExpiration) {
          return null;
        }
      }
      
      // Decodificar y retornar estadísticas
      final statsData = jsonDecode(statsJson) as Map<String, dynamic>;
      return DashboardStats.fromJson(statsData);
    } catch (e) {
      appLogger.error('Error obteniendo datos cacheados: $e');
      return null;
    }
  }

  /// Guardar estadísticas en cache
  Future<void> _cacheStats(DashboardStats stats, {String cacheKey = _statsCacheKey}) async {
    try {
      final statsJson = jsonEncode(stats.toJson());
      final timestampJson = DateTime.now().toIso8601String();
      
      await _prefs.setString(cacheKey, statsJson);
      await _prefs.setString('${cacheKey}_timestamp', timestampJson);
      
      // Actualizar timestamp de última actualización general
      if (cacheKey == _statsCacheKey) {
        await _prefs.setString(_lastUpdateKey, timestampJson);
      }
      
      appLogger.debug('Estadísticas guardadas en cache');
    } catch (e) {
      appLogger.error('Error guardando estadísticas en cache: $e');
    }
  }

  /// Obtener estadísticas de la API real
  Future<DashboardStats> _fetchStatsFromApi({
    String? municipioId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      appLogger.info('🚀 DashboardService: Iniciando obtención de estadísticas de la API real');
      appLogger.info('🌐 DashboardService: URL base: $_baseUrl');
      
      // Construir URL base
      String endpoint = '/dashboard/estadisticas';
      appLogger.info('📍 DashboardService: Endpoint: $endpoint');
      
      // Agregar parámetros de consulta
      Map<String, dynamic> queryParams = {};
      
      if (municipioId != null) {
        queryParams['municipio_id'] = municipioId;
      }
      
      if (startDate != null && endDate != null) {
        queryParams['fecha_inicio'] = startDate.toIso8601String();
        queryParams['fecha_fin'] = endDate.toIso8601String();
      }
      
      appLogger.info('📋 DashboardService: Parámetros: $queryParams');
      appLogger.info('⏳ DashboardService: Realizando llamada a la API...');
      
      // Realizar llamada a la API
      final response = await _apiService.get(endpoint, queryParameters: queryParams);
      
      appLogger.info('📨 DashboardService: Respuesta recibida - Status: ${response.statusCode}');
      appLogger.info('� DashbooardService: Respuesta recibida - Data Type: ${response.data.runtimeType}');
      appLogger.info('� DashboaardService: Respuesta recibida - Data: ${response.data}');
      
      // Procesar respuesta
      if (response.statusCode == 200 && response.data != null) {
        // Verificar si la respuesta es un Map
        if (response.data is! Map<String, dynamic>) {
          appLogger.error('❌ DashboardService: La respuesta no es un Map<String, dynamic>');
          throw Exception('La respuesta de la API no tiene el formato esperado: ${response.data.runtimeType}');
        }
        
        final data = response.data as Map<String, dynamic>;
        
        appLogger.info('🔍 DashboardService: Procesando datos de la API...');
        
        // Extraer los datos de la respuesta (el backend devuelve data.data)
        final statsData = data['data'] as Map<String, dynamic>? ?? data;
        
        appLogger.info('👥 DashboardService: totalGestantes: ${statsData['totalGestantes']}');
        appLogger.info('🏥 DashboardService: controlesRealizados: ${statsData['controlesRealizados']}');
        appLogger.info('⚠️ DashboardService: alertasActivas: ${statsData['alertasActivas']}');
        
        // Verificar campos requeridos
        final requiredFields = ['totalGestantes', 'controlesRealizados', 'alertasActivas'];
        for (final field in requiredFields) {
          if (!statsData.containsKey(field)) {
            appLogger.error('❌ DashboardService: Campo requerido faltante: $field');
          } else if (statsData[field] == null) {
            appLogger.warn('⚠️ DashboardService: Campo requerido es null: $field');
          }
        }
        
        // Convertir datos de la API a DashboardStats con validación
        final totalGestantes = _parseIntSafely(statsData['totalGestantes'], 'totalGestantes');
        final controlesRealizados = _parseIntSafely(statsData['controlesRealizados'], 'controlesRealizados');
        final alertasActivas = _parseIntSafely(statsData['alertasActivas'], 'alertasActivas');
        final contenidosVistos = _parseIntSafely(statsData['contenidosVistos'], 'contenidosVistos');
        final proximosControles = _parseIntSafely(statsData['proximosCitas'], 'proximosCitas');
        final tasaCumplimiento = _parseDoubleSafely(statsData['tasaCumplimiento'], 'tasaCumplimiento');
        
        final totalMedicos = _parseIntSafely(statsData['totalMedicos'], 'totalMedicos');
        final totalIps = _parseIntSafely(statsData['totalIps'], 'totalIps');
        
        final stats = DashboardStats(
          totalGestantes: totalGestantes,
          controlesRealizados: controlesRealizados,
          alertasActivas: alertasActivas,
          contenidosVistos: contenidosVistos,
          proximosControles: proximosControles,
          tasaCumplimiento: tasaCumplimiento,
          totalMedicos: totalMedicos,
          totalIps: totalIps,
          lastUpdated: DateTime.now(),
        );
        
        appLogger.info('✅ DashboardService: Estadísticas procesadas exitosamente');
        appLogger.info('📊 DashboardService: Stats finales: $stats');
        
        return stats;
      } else {
        final errorMsg = 'Error en la respuesta de la API: ${response.statusCode}';
        appLogger.error('❌ DashboardService: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      appLogger.error('💥 DashboardService: Error obteniendo estadísticas de la API', error: e);
      
      // Re-lanzar el error para que sea manejado por el método que llama
      rethrow;
    }
  }
  
  /// Parsear entero de forma segura
  int _parseIntSafely(dynamic value, String fieldName) {
    if (value == null) {
      appLogger.warn('⚠️ DashboardService: Campo $fieldName es null, usando 0');
      return 0;
    }
    
    if (value is int) {
      return value;
    }
    
    if (value is double) {
      return value.toInt();
    }
    
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    
    appLogger.warn('⚠️ DashboardService: No se pudo parsear $fieldName ($value, ${value.runtimeType}), usando 0');
    return 0;
  }
  
  /// Parsear double de forma segura
  double _parseDoubleSafely(dynamic value, String fieldName) {
    if (value == null) {
      appLogger.warn('⚠️ DashboardService: Campo $fieldName es null, usando 0.0');
      return 0.0;
    }
    
    if (value is double) {
      return value;
    }
    
    if (value is int) {
      return value.toDouble();
    }
    
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    
    appLogger.warn('⚠️ DashboardService: No se pudo parsear $fieldName ($value, ${value.runtimeType}), usando 0.0');
    return 0.0;
  }

  /// Limpiar todo el cache
  Future<void> limpiarCache() async {
    try {
      final keys = _prefs.getKeys();
      final dashboardKeys = keys.where((key) => key.startsWith(_statsCacheKey));
      
      for (final key in dashboardKeys) {
        await _prefs.remove(key);
      }
      
      appLogger.info('Cache de dashboard limpiado');
    } catch (e) {
      appLogger.error('Error limpiando cache: $e');
    }
  }
}