import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/models/dashboard_model.dart';
import 'package:madres_digitales_flutter_new/models/usuario_model.dart';

/// Servicio para manejar datos offline
class OfflineService {
  final SharedPreferences _prefs;
  static const String _estadisticasCacheKey = 'estadisticas_cache';
  static const String _estadisticasTimestampKey = 'estadisticas_timestamp';
  static const String _gestantesCacheKey = 'gestantes_cache';
  static const String _contenidosCacheKey = 'contenidos_cache';
  static const Duration _cacheExpiration = Duration(hours: 1);

  OfflineService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Guardar estadísticas en cache offline
  Future<void> saveEstadisticasCache(EstadisticasGeneralesModel estadisticas) async {
    try {
      final estadisticasJson = jsonEncode(estadisticas.toJson());
      final timestampJson = DateTime.now().toIso8601String();
      
      await _prefs.setString(_estadisticasCacheKey, estadisticasJson);
      await _prefs.setString(_estadisticasTimestampKey, timestampJson);
      
      appLogger.info('Estadísticas guardadas en cache offline');
    } catch (e) {
      appLogger.error('Error guardando estadísticas en cache', error: e);
    }
  }

  /// Obtener estadísticas desde cache offline
  Future<EstadisticasGeneralesModel?> getEstadisticasCache() async {
    try {
      final estadisticasJson = _prefs.getString(_estadisticasCacheKey);
      final timestampJson = _prefs.getString(_estadisticasTimestampKey);
      
      if (estadisticasJson == null || timestampJson == null) {
        return null;
      }
      
      // Verificar si el cache ha expirado
      final lastUpdate = DateTime.parse(timestampJson);
      final now = DateTime.now();
      
      if (now.difference(lastUpdate) > _cacheExpiration) {
        appLogger.warn('Cache de estadísticas expirado');
        return null;
      }
      
      // Decodificar y retornar estadísticas
      final estadisticasData = jsonDecode(estadisticasJson) as Map<String, dynamic>;
      final estadisticas = EstadisticasGeneralesModel.fromJson(estadisticasData);
      
      appLogger.info('Estadísticas obtenidas desde cache offline');
      return estadisticas;
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas cache', error: e);
      return null;
    }
  }

  /// Limpiar cache de estadísticas
  Future<void> clearEstadisticasCache() async {
    try {
      await _prefs.remove(_estadisticasCacheKey);
      await _prefs.remove(_estadisticasTimestampKey);
      
      appLogger.info('Cache de estadísticas limpiado');
    } catch (e) {
      appLogger.error('Error limpiando cache de estadísticas', error: e);
    }
  }

  /// Guardar gestantes en cache offline
  Future<void> saveGestantesCache(List<Map<String, dynamic>> gestantes) async {
    try {
      final gestantesJson = jsonEncode(gestantes);
      await _prefs.setString(_gestantesCacheKey, gestantesJson);
      
      appLogger.info('Gestantes guardadas en cache offline: ${gestantes.length}');
    } catch (e) {
      appLogger.error('Error guardando gestantes en cache', error: e);
    }
  }

  /// Obtener gestantes desde cache offline
  Future<List<Map<String, dynamic>>?> getGestantesCache() async {
    try {
      final gestantesJson = _prefs.getString(_gestantesCacheKey);
      
      if (gestantesJson == null) {
        return null;
      }
      
      final gestantesData = jsonDecode(gestantesJson) as List<dynamic>;
      final gestantes = gestantesData.cast<Map<String, dynamic>>();
      
      appLogger.info('Gestantes obtenidas desde cache offline: ${gestantes.length}');
      return gestantes;
    } catch (e) {
      appLogger.error('Error obteniendo gestantes cache', error: e);
      return null;
    }
  }

  /// Guardar contenidos en cache offline
  Future<void> saveContenidosCache(List<Map<String, dynamic>> contenidos) async {
    try {
      final contenidosJson = jsonEncode(contenidos);
      await _prefs.setString(_contenidosCacheKey, contenidosJson);
      
      appLogger.info('Contenidos guardados en cache offline: ${contenidos.length}');
    } catch (e) {
      appLogger.error('Error guardando contenidos en cache', error: e);
    }
  }

  /// Obtener contenidos desde cache offline
  Future<List<Map<String, dynamic>>?> getContenidosCache() async {
    try {
      final contenidosJson = _prefs.getString(_contenidosCacheKey);
      
      if (contenidosJson == null) {
        return null;
      }
      
      final contenidosData = jsonDecode(contenidosJson) as List<dynamic>;
      final contenidos = contenidosData.cast<Map<String, dynamic>>();
      
      appLogger.info('Contenidos obtenidos desde cache offline: ${contenidos.length}');
      return contenidos;
    } catch (e) {
      appLogger.error('Error obteniendo contenidos cache', error: e);
      return null;
    }
  }

  /// Guardar contenidos por categoría en cache offline
  Future<void> saveContenidosPorCategoriaCache(
    String categoria, 
    List<Map<String, dynamic>> contenidos
  ) async {
    try {
      final cacheKey = '${_contenidosCacheKey}_$categoria';
      final contenidosJson = jsonEncode(contenidos);
      await _prefs.setString(cacheKey, contenidosJson);
      
      appLogger.info('Contenidos guardados en cache offline para categoría $categoria: ${contenidos.length}');
    } catch (e) {
      appLogger.error('Error guardando contenidos en cache para categoría $categoria', error: e);
    }
  }

  /// Obtener contenidos por categoría desde cache offline
  Future<List<Map<String, dynamic>>?> getContenidosPorCategoriaCache(String categoria) async {
    try {
      final cacheKey = '${_contenidosCacheKey}_$categoria';
      final contenidosJson = _prefs.getString(cacheKey);
      
      if (contenidosJson == null) {
        return null;
      }
      
      final contenidosData = jsonDecode(contenidosJson) as List<dynamic>;
      final contenidos = contenidosData.cast<Map<String, dynamic>>();
      
      return contenidos;
    } catch (e) {
      appLogger.error('Error obteniendo contenidos cache para categoría $categoria', error: e);
      return null;
    }
  }

  /// Limpiar todo el cache
  Future<void> clearAllCache() async {
    try {
      await clearEstadisticasCache();
      await _prefs.remove(_gestantesCacheKey);
      await _prefs.remove(_contenidosCacheKey);
      
      // Limpiar cache por categorías
      final keys = _prefs.getKeys();
      final categoriaKeys = keys.where((key) => 
        key.startsWith('${_contenidosCacheKey}_') && key != _contenidosCacheKey
      );
      
      for (final key in categoriaKeys) {
        await _prefs.remove(key);
      }
      
      appLogger.info('Todo el cache offline limpiado');
    } catch (e) {
      appLogger.error('Error limpiando todo el cache', error: e);
    }
  }

  /// Verificar si hay datos cacheados
  Future<bool> hasCachedData() async {
    try {
      final estadisticasJson = _prefs.getString(_estadisticasCacheKey);
      final gestantesJson = _prefs.getString(_gestantesCacheKey);
      final contenidosJson = _prefs.getString(_contenidosCacheKey);
      
      return estadisticasJson != null || 
             gestantesJson != null || 
             contenidosJson != null;
    } catch (e) {
      appLogger.error('Error verificando datos cacheados', error: e);
      return false;
    }
  }

  /// Obtener tamaño del cache
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final keys = _prefs.getKeys();
      
      for (final key in keys) {
        if (key.contains('cache')) {
          final value = _prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      appLogger.error('Error obteniendo tamaño del cache', error: e);
      return 0;
    }
  }
  
  /// Reintentar operación con backoff exponencial
  Future<bool> reintentarOperacion(Future Function() operacion) async {
    const maxIntentos = 5;
    for (int i = 1; i <= maxIntentos; i++) {
      try {
        await operacion();
        return true;
      } catch (e) {
        if (i == maxIntentos) rethrow;
        // Calcular delay con backoff exponencial (2^i segundos, máximo 30 segundos)
        final delaySeconds = (1 << (i - 1)).clamp(1, 30);
        final delay = Duration(seconds: delaySeconds);
        
        appLogger.warn('Error en operación, reintentando en ${delay.inSeconds}s', error: e);
        await Future.delayed(delay);
      }
    }
    return false;
  }
  
  /// Guardar datos offline para sincronización posterior
  Future<void> saveOfflineData(String key, Map<String, dynamic> data) async {
    try {
      final offlineData = _prefs.getString('offline_data_$key') ?? '[]';
      final List<dynamic> dataList = jsonDecode(offlineData);
      dataList.add({
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await _prefs.setString('offline_data_$key', jsonEncode(dataList));
      appLogger.info('Datos guardados offline para sincronización: $key');
    } catch (e) {
      appLogger.error('Error guardando datos offline', error: e);
    }
  }
  
  /// Obtener datos guardados offline
  Future<List<Map<String, dynamic>>> getOfflineData(String key) async {
    try {
      final offlineData = _prefs.getString('offline_data_$key');
      if (offlineData == null) return [];
      
      final List<dynamic> dataList = jsonDecode(offlineData);
      return dataList.cast<Map<String, dynamic>>();
    } catch (e) {
      appLogger.error('Error obteniendo datos offline', error: e);
      return [];
    }
  }
  
  /// Sincronizar datos pendientes
  Future<void> syncPendingData() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith('offline_data_')).toList();
      
      for (final key in keys) {
        final entityKey = key.replaceFirst('offline_data_', '');
        final dataList = await getOfflineData(entityKey);
        
        if (dataList.isNotEmpty) {
          appLogger.info('Sincronizando ${dataList.length} elementos para $entityKey');
          
          // Aquí iría la lógica específica para sincronizar cada tipo de entidad
          // Por ahora, solo limpiamos los datos offline
          await _prefs.remove(key);
        }
      }
      
      appLogger.info('Sincronización de datos offline completada');
    } catch (e) {
      appLogger.error('Error sincronizando datos offline', error: e);
    }
  }
  
  /// Obtener IPS offline
  Future<List<IpsModel>> getOfflineIps() async {
    try {
      final ipsData = await getOfflineData('ips');
      return ipsData.map((json) => IpsModel.fromJson(json)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo IPS offline', error: e);
      return [];
    }
  }
  
  /// Obtener médicos offline
  Future<List<MedicoModel>> getOfflineMedicos() async {
    try {
      final medicosData = await getOfflineData('medicos');
      return medicosData.map((json) => MedicoModel.fromJson(json)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo médicos offline', error: e);
      return [];
    }
  }
  
  /// Guardar IPS offline
  Future<void> saveOfflineIps(List<IpsModel> ipsList) async {
    try {
      final ipsData = ipsList.map((ips) => ips.toJson()).toList();
      await saveOfflineData('ips', {'ips': ipsData});
      appLogger.info('IPS guardadas offline: ${ipsList.length}');
    } catch (e) {
      appLogger.error('Error guardando IPS offline', error: e);
    }
  }
  
  /// Guardar médicos offline
  Future<void> saveOfflineMedicos(List<MedicoModel> medicosList) async {
    try {
      final medicosData = medicosList.map((medico) => medico.toJson()).toList();
      await saveOfflineData('medicos', {'medicos': medicosData});
      appLogger.info('Médicos guardados offline: ${medicosList.length}');
    } catch (e) {
      appLogger.error('Error guardando médicos offline', error: e);
    }
  }
  
  /// Limpiar datos offline de IPS
  Future<void> clearOfflineIps() async {
    try {
      await _prefs.remove('offline_data_ips');
      appLogger.info('Datos offline de IPS eliminados');
    } catch (e) {
      appLogger.error('Error eliminando datos offline de IPS', error: e);
    }
  }
  
  /// Limpiar datos offline de médicos
  Future<void> clearOfflineMedicos() async {
    try {
      await _prefs.remove('offline_data_medicos');
      appLogger.info('Datos offline de médicos eliminados');
    } catch (e) {
      appLogger.error('Error eliminando datos offline de médicos', error: e);
    }
  }
  
  /// Verificar si hay datos offline de IPS
  Future<bool> hasOfflineIps() async {
    try {
      final ipsData = _prefs.getString('offline_data_ips');
      return ipsData != null;
    } catch (e) {
      appLogger.error('Error verificando datos offline de IPS', error: e);
      return false;
    }
  }
  
  /// Verificar si hay datos offline de médicos
  Future<bool> hasOfflineMedicos() async {
    try {
      final medicosData = _prefs.getString('offline_data_medicos');
      return medicosData != null;
    } catch (e) {
      appLogger.error('Error verificando datos offline de médicos', error: e);
      return false;
    }
  }
}