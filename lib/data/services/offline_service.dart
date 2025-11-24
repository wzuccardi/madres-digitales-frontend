import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_model.dart';
import '../models/usuario_models.dart';

/// Servicio para manejar datos offline
class OfflineService {

  OfflineService({required SharedPreferences prefs}) : _prefs = prefs;
  final SharedPreferences _prefs;
  static const String _estadisticasCacheKey = 'estadisticas_cache';
  static const String _estadisticasTimestampKey = 'estadisticas_timestamp';
  static const String _gestantesCacheKey = 'gestantes_cache';
  static const String _contenidosCacheKey = 'contenidos_cache';
  static const Duration _cacheExpiration = Duration(hours: 1);
  static const String _conflictsKey = 'sync_conflicts';

  /// Guardar estadísticas en cache offline
  Future<void> saveEstadisticasCache(EstadisticasGeneralesModel estadisticas) async {
    try {
      final estadisticasJson = jsonEncode(estadisticas.toJson());
      final timestampJson = DateTime.now().toIso8601String();
      
      await _prefs.setString(_estadisticasCacheKey, estadisticasJson);
      await _prefs.setString(_estadisticasTimestampKey, timestampJson);
      
      AppLogger.info('Estadísticas guardadas en cache offline');
    } catch (e) {
      AppLogger.error('Error guardando estadísticas en cache', error: e);
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
        AppLogger.warn('Cache de estadísticas expirado');
        return null;
      }
      
      // Decodificar y retornar estadísticas
      final estadisticasData = jsonDecode(estadisticasJson) as Map<String, dynamic>;
      final estadisticas = EstadisticasGeneralesModel.fromJson(estadisticasData);
      
      AppLogger.info('Estadísticas obtenidas desde cache offline');
      return estadisticas;
    } catch (e) {
      AppLogger.error('Error obteniendo estadísticas cache', error: e);
      return null;
    }
  }

  /// Limpiar cache de estadísticas
  Future<void> clearEstadisticasCache() async {
    try {
      await _prefs.remove(_estadisticasCacheKey);
      await _prefs.remove(_estadisticasTimestampKey);
      
      AppLogger.info('Cache de estadísticas limpiado');
    } catch (e) {
      AppLogger.error('Error limpiando cache de estadísticas', error: e);
    }
  }

  /// Guardar gestantes en cache offline
  Future<void> saveGestantesCache(List<Map<String, dynamic>> gestantes) async {
    try {
      final gestantesJson = jsonEncode(gestantes);
      await _prefs.setString(_gestantesCacheKey, gestantesJson);
      
      AppLogger.info('Gestantes guardadas en cache offline: ${gestantes.length}');
    } catch (e) {
      AppLogger.error('Error guardando gestantes en cache', error: e);
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
      
      AppLogger.info('Gestantes obtenidas desde cache offline: ${gestantes.length}');
      return gestantes;
    } catch (e) {
      AppLogger.error('Error obteniendo gestantes cache', error: e);
      return null;
    }
  }

  /// Guardar contenidos en cache offline
  Future<void> saveContenidosCache(List<Map<String, dynamic>> contenidos) async {
    try {
      final contenidosJson = jsonEncode(contenidos);
      await _prefs.setString(_contenidosCacheKey, contenidosJson);
      
      AppLogger.info('Contenidos guardados en cache offline: ${contenidos.length}');
    } catch (e) {
      AppLogger.error('Error guardando contenidos en cache', error: e);
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
      
      AppLogger.info('Contenidos obtenidos desde cache offline: ${contenidos.length}');
      return contenidos;
    } catch (e) {
      AppLogger.error('Error obteniendo contenidos cache', error: e);
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
      
      AppLogger.info('Contenidos guardados en cache offline para categoría $categoria: ${contenidos.length}');
    } catch (e) {
      AppLogger.error('Error guardando contenidos en cache para categoría $categoria', error: e);
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
      AppLogger.error('Error obteniendo contenidos cache para categoría $categoria', error: e);
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
      
      AppLogger.info('Todo el cache offline limpiado');
    } catch (e) {
      AppLogger.error('Error limpiando todo el cache', error: e);
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
      AppLogger.error('Error verificando datos cacheados', error: e);
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
      AppLogger.error('Error obteniendo tamaño del cache', error: e);
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
        
        AppLogger.warn('Error en operación, reintentando en ${delay.inSeconds}s', error: e);
        await Future.delayed(delay);
      }
    }
    return false;
  }
  
  // Conflictos de sincronización
  List<Map<String, dynamic>> getConflicts() {
    try {
      final jsonStr = _prefs.getString(_conflictsKey);
      if (jsonStr == null) return const [];
      final data = jsonDecode(jsonStr) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      AppLogger.error('OfflineService: error leyendo conflictos', error: e);
      return const [];
    }
  }

  Future<void> addConflict(Map<String, dynamic> conflict) async {
    try {
      final conflicts = getConflicts();
      conflicts.add(conflict);
      await _prefs.setString(_conflictsKey, jsonEncode(conflicts));
    } catch (e) {
      AppLogger.error('OfflineService: error agregando conflicto', error: e);
    }
  }

  Future<void> resolveConflictLocal(Map<String, dynamic> conflict) async {
    try {
      final conflicts = getConflicts();
      conflicts.removeWhere((c) => c['id'] == conflict['id']);
      await _prefs.setString(_conflictsKey, jsonEncode(conflicts));
      AppLogger.info('OfflineService: conflicto resuelto (local)');
    } catch (e) {
      AppLogger.error('OfflineService: error resolviendo conflicto local', error: e);
    }
  }

  Future<void> resolveConflictRemote(Map<String, dynamic> conflict) async {
    try {
      final conflicts = getConflicts();
      conflicts.removeWhere((c) => c['id'] == conflict['id']);
      await _prefs.setString(_conflictsKey, jsonEncode(conflicts));
      AppLogger.info('OfflineService: conflicto resuelto (remoto)');
    } catch (e) {
      AppLogger.error('OfflineService: error resolviendo conflicto remoto', error: e);
    }
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
      AppLogger.info('Datos guardados offline para sincronización: $key');
    } catch (e) {
      AppLogger.error('Error guardando datos offline', error: e);
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
      AppLogger.error('Error obteniendo datos offline', error: e);
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
          AppLogger.info('Sincronizando ${dataList.length} elementos para $entityKey');
          
          // Aquí iría la lógica específica para sincronizar cada tipo de entidad
          // Por ahora, solo limpiamos los datos offline
          await _prefs.remove(key);
        }
      }
      
      AppLogger.info('Sincronización de datos offline completada');
    } catch (e) {
      AppLogger.error('Error sincronizando datos offline', error: e);
    }
  }
  
  /// Obtener IPS offline
  Future<List<IpsModel>> getOfflineIps() async {
    try {
      final ipsData = await getOfflineData('ips');
      return ipsData.map((json) => IpsModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error obteniendo IPS offline', error: e);
      return [];
    }
  }
  
  /// Obtener médicos offline
  Future<List<MedicoModel>> getOfflineMedicos() async {
    try {
      final medicosData = await getOfflineData('medicos');
      return medicosData.map((json) => MedicoModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error obteniendo médicos offline', error: e);
      return [];
    }
  }
  
  /// Guardar IPS offline
  Future<void> saveOfflineIps(List<IpsModel> ipsList) async {
    try {
      final ipsData = ipsList.map((ips) => ips.toJson()).toList();
      await saveOfflineData('ips', {'ips': ipsData});
      AppLogger.info('IPS guardadas offline: ${ipsList.length}');
    } catch (e) {
      AppLogger.error('Error guardando IPS offline', error: e);
    }
  }
  
  /// Guardar médicos offline
  Future<void> saveOfflineMedicos(List<MedicoModel> medicosList) async {
    try {
      final medicosData = medicosList.map((medico) => medico.toJson()).toList();
      await saveOfflineData('medicos', {'medicos': medicosData});
      AppLogger.info('Médicos guardados offline: ${medicosList.length}');
    } catch (e) {
      AppLogger.error('Error guardando médicos offline', error: e);
    }
  }
  
  /// Limpiar datos offline de IPS
  Future<void> clearOfflineIps() async {
    try {
      await _prefs.remove('offline_data_ips');
      AppLogger.info('Datos offline de IPS eliminados');
    } catch (e) {
      AppLogger.error('Error eliminando datos offline de IPS', error: e);
    }
  }
  
  /// Limpiar datos offline de médicos
  Future<void> clearOfflineMedicos() async {
    try {
      await _prefs.remove('offline_data_medicos');
      AppLogger.info('Datos offline de médicos eliminados');
    } catch (e) {
      AppLogger.error('Error eliminando datos offline de médicos', error: e);
    }
  }
  
  /// Verificar si hay datos offline de IPS
  Future<bool> hasOfflineIps() async {
    try {
      final ipsData = _prefs.getString('offline_data_ips');
      return ipsData != null;
    } catch (e) {
      AppLogger.error('Error verificando datos offline de IPS', error: e);
      return false;
    }
  }
  
  /// Verificar si hay datos offline de médicos
  Future<bool> hasOfflineMedicos() async {
    try {
      final medicosData = _prefs.getString('offline_data_medicos');
      return medicosData != null;
    } catch (e) {
      AppLogger.error('Error verificando datos offline de médicos', error: e);
      return false;
    }
  }
}
