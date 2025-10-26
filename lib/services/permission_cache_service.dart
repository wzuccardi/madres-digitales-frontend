import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

/// Modelo para entrada de cache de permisos
class PermissionCacheEntry {
  final String gestanteId;
  final Set<String> permissions;
  final DateTime timestamp;
  final String version;

  PermissionCacheEntry({
    required this.gestanteId,
    required this.permissions,
    required this.timestamp,
    required this.version,
  });

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'gestanteId': gestanteId,
      'permissions': permissions.toList(),
      'timestamp': timestamp.toIso8601String(),
      'version': version,
    };
  }

  /// Crear desde JSON
  factory PermissionCacheEntry.fromJson(Map<String, dynamic> json) {
    return PermissionCacheEntry(
      gestanteId: json['gestanteId'],
      permissions: Set<String>.from(json['permissions']),
      timestamp: DateTime.parse(json['timestamp']),
      version: json['version'],
    );
  }

  /// Verificar si la entrada es válida (no ha expirado)
  bool isValid({int maxAgeMinutes = 15}) {
    final now = DateTime.now();
    final age = now.difference(timestamp);
    return age.inMinutes < maxAgeMinutes;
  }
}

/// Servicio para manejo de cache de permisos con invalidación
class PermissionCacheService {
  static const String _cacheKeyPrefix = 'permission_cache_';
  static const String _versionKey = 'permission_cache_version';
  static const String _globalInvalidationKey = 'permission_cache_global_invalidation';
  
  // NUEVO: Versión actual del cache para invalidación global
  static const String _currentVersion = '1.0.0';
  
  // NUEVO: Tiempo máximo de vida del cache (15 minutos)
  static const int _maxCacheAgeMinutes = 15;
  
  // NUEVO: Mapa para control de invalidaciones por gestante
  final Map<String, DateTime> _gestanteInvalidations = {};
  
  // NUEVO: Stream para notificar cambios en el cache
  final StreamController<PermissionCacheEvent> _eventController = 
      StreamController<PermissionCacheEvent>.broadcast();
  
  Stream<PermissionCacheEvent> get events => _eventController.stream;

  /// NUEVO: Obtener permisos cacheados con validación
  Future<Set<String>?> getPermissions(String gestanteId) async {
    try {
      'PermissionCacheService: Obteniendo permisos cacheados'.debug(context: {
        'gestanteId': gestanteId,
      });
      
      // Verificar si hay invalidación global
      if (await _isGloballyInvalidated()) {
        'PermissionCacheService: Cache globalmente invalidado'.debug(context: {
          'gestanteId': gestanteId,
        });
        await _clearGlobalInvalidation();
        return null;
      }
      
      // Verificar si hay invalidación específica para la gestante
      if (_isGestanteInvalidated(gestanteId)) {
        'PermissionCacheService: Cache de gestante invalidado'.debug(context: {
          'gestanteId': gestanteId,
        });
        _gestanteInvalidations.remove(gestanteId);
        return null;
      }
      
      // Obtener cache de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(gestanteId);
      final cacheJson = prefs.getString(cacheKey);
      
      if (cacheJson == null) {
        'PermissionCacheService: No hay cache para gestante'.debug(context: {
          'gestanteId': gestanteId,
        });
        return null;
      }
      
      // Decodificar entrada de cache
      final cacheData = jsonDecode(cacheJson);
      final cacheEntry = PermissionCacheEntry.fromJson(cacheData);
      
      // Verificar si el cache es válido
      if (!cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes)) {
        'PermissionCacheService: Cache expirado'.debug(context: {
          'gestanteId': gestanteId,
          'timestamp': cacheEntry.timestamp.toIso8601String(),
        });
        await invalidatePermissions(gestanteId);
        return null;
      }
      
      // Verificar si la versión es compatible
      if (cacheEntry.version != _currentVersion) {
        'PermissionCacheService: Versión de cache incompatible'.debug(context: {
          'gestanteId': gestanteId,
          'cacheVersion': cacheEntry.version,
          'currentVersion': _currentVersion,
        });
        await invalidatePermissions(gestanteId);
        return null;
      }
      
      'PermissionCacheService: Cache válido encontrado'.debug(context: {
        'gestanteId': gestanteId,
        'permissions': cacheEntry.permissions.toList(),
        'timestamp': cacheEntry.timestamp.toIso8601String(),
      });
      
      // Emitir evento de cache hit
      _eventController.add(PermissionCacheEvent(
        type: PermissionCacheEventType.cacheHit,
        gestanteId: gestanteId,
        permissions: cacheEntry.permissions,
      ));
      
      return cacheEntry.permissions;
    } catch (e) {
      'Error obteniendo permisos cacheados'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
      return null;
    }
  }

  /// NUEVO: Guardar permisos en cache
  Future<void> savePermissions(String gestanteId, Set<String> permissions) async {
    try {
      'PermissionCacheService: Guardando permisos en cache'.debug(context: {
        'gestanteId': gestanteId,
        'permissions': permissions.toList(),
      });
      
      final cacheEntry = PermissionCacheEntry(
        gestanteId: gestanteId,
        permissions: permissions,
        timestamp: DateTime.now(),
        version: _currentVersion,
      );
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(gestanteId);
      await prefs.setString(cacheKey, jsonEncode(cacheEntry.toJson()));
      
      // Actualizar versión global
      await prefs.setString(_versionKey, _currentVersion);
      
      // Limpiar invalidación específica si existe
      _gestanteInvalidations.remove(gestanteId);
      
      'PermissionCacheService: Permisos guardados en cache'.debug(context: {
        'gestanteId': gestanteId,
        'permissions': permissions.toList(),
        'timestamp': cacheEntry.timestamp.toIso8601String(),
      });
      
      // Emitir evento de cache actualizado
      _eventController.add(PermissionCacheEvent(
        type: PermissionCacheEventType.cacheUpdated,
        gestanteId: gestanteId,
        permissions: permissions,
      ));
    } catch (e) {
      'Error guardando permisos en cache'.error(error: e, context: {
        'gestanteId': gestanteId,
        'permissions': permissions.toList(),
      });
    }
  }

  /// NUEVO: Invalidar permisos de una gestante específica
  Future<void> invalidatePermissions(String gestanteId) async {
    try {
      'PermissionCacheService: Invalidando permisos'.debug(context: {
        'gestanteId': gestanteId,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(gestanteId);
      await prefs.remove(cacheKey);
      
      // Marcar como invalidado para evitar lecturas inmediatas
      _gestanteInvalidations[gestanteId] = DateTime.now();
      
      // Emitir evento de invalidación
      _eventController.add(PermissionCacheEvent(
        type: PermissionCacheEventType.cacheInvalidated,
        gestanteId: gestanteId,
        permissions: <String>{},
      ));
      
      'PermissionCacheService: Permisos invalidados'.debug(context: {
        'gestanteId': gestanteId,
      });
    } catch (e) {
      'Error invalidando permisos'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
    }
  }

  /// NUEVO: Invalidar todo el cache de permisos
  Future<void> invalidateAllPermissions() async {
    try {
      'PermissionCacheService: Invalidando todo el cache'.debug();
      
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener todas las claves que comienzan con el prefijo del cache
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      // Eliminar todas las entradas de cache
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
      
      // Marcar invalidación global
      await prefs.setString(_globalInvalidationKey, DateTime.now().toIso8601String());
      
      // Limpiar invalidaciones específicas
      _gestanteInvalidations.clear();
      
      // Emitir evento de invalidación global
      _eventController.add(PermissionCacheEvent(
        type: PermissionCacheEventType.globalCacheInvalidated,
        gestanteId: 'all',
        permissions: <String>{},
      ));
      
      'PermissionCacheService: Todo el cache invalidado'.debug(context: {
        'entriesRemoved': cacheKeys.length,
      });
    } catch (e) {
      'Error invalidando todo el cache'.error(error: e);
    }
  }

  /// NUEVO: Limpiar cache expirado
  Future<void> cleanExpiredCache() async {
    try {
      'PermissionCacheService: Limpiando cache expirado'.debug();
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      int removedCount = 0;
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = PermissionCacheEntry.fromJson(cacheData);
            
            // Si el cache está expirado o la versión es incompatible, eliminarlo
            if (!cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes) ||
                cacheEntry.version != _currentVersion) {
              await prefs.remove(key);
              removedCount++;
            }
          }
        } catch (e) {
          // Si hay error al procesar una entrada, eliminarla
          await prefs.remove(key);
          removedCount++;
        }
      }
      
      'PermissionCacheService: Cache expirado limpiado'.debug(context: {
        'entriesRemoved': removedCount,
      });
    } catch (e) {
      'Error limpiando cache expirado'.error(error: e);
    }
  }

  /// NUEVO: Verificar si hay invalidación global
  Future<bool> _isGloballyInvalidated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final invalidationTimestamp = prefs.getString(_globalInvalidationKey);
      
      if (invalidationTimestamp == null) {
        return false;
      }
      
      final invalidationTime = DateTime.parse(invalidationTimestamp);
      final now = DateTime.now();
      
      // Si la invalidación global es muy reciente (menos de 1 minuto), considerar activa
      return now.difference(invalidationTime).inSeconds < 60;
    } catch (e) {
      'Error verificando invalidación global'.error(error: e);
      return false;
    }
  }

  /// NUEVO: Limpiar invalidación global
  Future<void> _clearGlobalInvalidation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_globalInvalidationKey);
    } catch (e) {
      'Error limpiando invalidación global'.error(error: e);
    }
  }

  /// NUEVO: Verificar si hay invalidación específica para una gestante
  bool _isGestanteInvalidated(String gestanteId) {
    final invalidationTime = _gestanteInvalidations[gestanteId];
    if (invalidationTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    // Si la invalidación es muy reciente (menos de 30 segundos), considerar activa
    return now.difference(invalidationTime).inSeconds < 30;
  }

  /// NUEVO: Obtener clave de cache para una gestante
  String _getCacheKey(String gestanteId) {
    return '$_cacheKeyPrefix$gestanteId';
  }

  /// NUEVO: Obtener estadísticas del cache
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      int validEntries = 0;
      int expiredEntries = 0;
      int incompatibleEntries = 0;
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = PermissionCacheEntry.fromJson(cacheData);
            
            if (cacheEntry.version != _currentVersion) {
              incompatibleEntries++;
            } else if (!cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes)) {
              expiredEntries++;
            } else {
              validEntries++;
            }
          }
        } catch (e) {
          // Error al procesar entrada, contar como expirada
          expiredEntries++;
        }
      }
      
      return {
        'totalEntries': cacheKeys.length,
        'validEntries': validEntries,
        'expiredEntries': expiredEntries,
        'incompatibleEntries': incompatibleEntries,
        'gestanteInvalidations': _gestanteInvalidations.length,
        'currentVersion': _currentVersion,
        'maxCacheAgeMinutes': _maxCacheAgeMinutes,
      };
    } catch (e) {
      'Error obteniendo estadísticas del cache'.error(error: e);
      return {};
    }
  }

  /// NUEVO: Liberar recursos
  void dispose() {
    _eventController.close();
  }
}

/// NUEVO: Tipos de eventos del cache
enum PermissionCacheEventType {
  cacheHit,
  cacheMiss,
  cacheUpdated,
  cacheInvalidated,
  globalCacheInvalidated,
}

/// NUEVO: Evento del cache de permisos
class PermissionCacheEvent {
  final PermissionCacheEventType type;
  final String gestanteId;
  final Set<String> permissions;
  final DateTime timestamp;

  PermissionCacheEvent({
    required this.type,
    required this.gestanteId,
    required this.permissions,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'PermissionCacheEvent{type: $type, gestanteId: $gestanteId, permissions: ${permissions.length}, timestamp: $timestamp}';
  }
}

/// NUEVO: Singleton del servicio
final permissionCacheService = PermissionCacheService();