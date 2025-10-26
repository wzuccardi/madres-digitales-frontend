import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';
import 'package:madres_digitales_flutter_new/models/contenido_model.dart';

/// Modelo para entrada de cache de contenidos
class ContenidoCacheEntry {
  final String contenidoId;
  final ContenidoModel contenido;
  final DateTime timestamp;
  final String version;
  final List<String> tags;

  ContenidoCacheEntry({
    required this.contenidoId,
    required this.contenido,
    required this.timestamp,
    required this.version,
    required this.tags,
  });

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'contenidoId': contenidoId,
      'contenido': contenido.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'version': version,
      'tags': tags,
    };
  }

  /// Crear desde JSON
  factory ContenidoCacheEntry.fromJson(Map<String, dynamic> json) {
    return ContenidoCacheEntry(
      contenidoId: json['contenidoId'],
      contenido: ContenidoModel.fromJson(json['contenido']),
      timestamp: DateTime.parse(json['timestamp']),
      version: json['version'],
      tags: List<String>.from(json['tags']),
    );
  }

  /// Verificar si la entrada es válida (no ha expirado)
  bool isValid({int maxAgeMinutes = 30}) {
    final now = DateTime.now();
    final age = now.difference(timestamp);
    return age.inMinutes < maxAgeMinutes;
  }

  /// Verificar si la entrada coincide con los tags especificados
  bool matchesTags(List<String> searchTags) {
    if (searchTags.isEmpty) return true;
    
    // Verificar si todos los tags de búsqueda están en los tags de la entrada
    for (final tag in searchTags) {
      if (!tags.contains(tag)) {
        return false;
      }
    }
    
    return true;
  }
}

/// Eventos de cache de contenidos
enum ContenidoCacheEventType {
  cacheHit,
  cacheMiss,
  cacheUpdated,
  cacheInvalidated,
  globalCacheInvalidated,
  tagCacheInvalidated,
  cacheCleaned,
}

/// Evento de cache de contenidos
class ContenidoCacheEvent {
  final ContenidoCacheEventType type;
  final String? contenidoId;
  final List<String>? tags;
  final DateTime timestamp;
  final String? message;

  ContenidoCacheEvent({
    required this.type,
    this.contenidoId,
    this.tags,
    this.message,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'ContenidoCacheEvent{type: $type, contenidoId: $contenidoId, tags: $tags, timestamp: $timestamp}';
  }
}

/// Servicio para manejo de cache de contenidos con invalidación
class ContenidoCacheService {
  static const String _cacheKeyPrefix = 'contenido_cache_';
  static const String _versionKey = 'contenido_cache_version';
  static const String _globalInvalidationKey = 'contenido_cache_global_invalidation';
  static const String _tagInvalidationKeyPrefix = 'contenido_tag_invalidation_';
  
  // NUEVO: Versión actual del cache para invalidación global
  static const String _currentVersion = '1.0.0';
  
  // NUEVO: Tiempo máximo de vida del cache (30 minutos)
  static const int _maxCacheAgeMinutes = 30;
  
  // NUEVO: Mapa para control de invalidaciones por contenido
  final Map<String, DateTime> _contenidoInvalidations = {};
  
  // NUEVO: Mapa para control de invalidaciones por tag
  final Map<String, DateTime> _tagInvalidations = {};
  
  // NUEVO: Stream para notificar cambios en el cache
  final StreamController<ContenidoCacheEvent> _eventController = 
      StreamController<ContenidoCacheEvent>.broadcast();
  
  Stream<ContenidoCacheEvent> get events => _eventController.stream;

  /// NUEVO: Obtener contenido cacheado con validación
  Future<ContenidoModel?> getContenido(String contenidoId) async {
    try {
      'ContenidoCacheService: Obteniendo contenido cacheado'.debug(context: {
        'contenidoId': contenidoId,
      });
      
      // Verificar si hay invalidación global
      if (await _isGloballyInvalidated()) {
        'ContenidoCacheService: Cache globalmente invalidado'.debug(context: {
          'contenidoId': contenidoId,
        });
        await _clearGlobalInvalidation();
        return null;
      }
      
      // Verificar si hay invalidación específica para el contenido
      if (_isContenidoInvalidated(contenidoId)) {
        'ContenidoCacheService: Cache de contenido invalidado'.debug(context: {
          'contenidoId': contenidoId,
        });
        _contenidoInvalidations.remove(contenidoId);
        return null;
      }
      
      // Obtener cache de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(contenidoId);
      final cacheJson = prefs.getString(cacheKey);
      
      if (cacheJson == null) {
        'ContenidoCacheService: No hay cache para contenido'.debug(context: {
          'contenidoId': contenidoId,
        });
        return null;
      }
      
      // Decodificar entrada de cache
      final cacheData = jsonDecode(cacheJson);
      final cacheEntry = ContenidoCacheEntry.fromJson(cacheData);
      
      // Verificar si el cache es válido
      if (!cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes)) {
        'ContenidoCacheService: Cache expirado'.debug(context: {
          'contenidoId': contenidoId,
          'timestamp': cacheEntry.timestamp.toIso8601String(),
        });
        await invalidateContenido(contenidoId);
        return null;
      }
      
      // Verificar si la versión es compatible
      if (cacheEntry.version != _currentVersion) {
        'ContenidoCacheService: Versión de cache incompatible'.debug(context: {
          'contenidoId': contenidoId,
          'cacheVersion': cacheEntry.version,
          'currentVersion': _currentVersion,
        });
        await invalidateContenido(contenidoId);
        return null;
      }
      
      'ContenidoCacheService: Cache válido encontrado'.debug(context: {
        'contenidoId': contenidoId,
        'titulo': cacheEntry.contenido.titulo,
        'timestamp': cacheEntry.timestamp.toIso8601String(),
      });
      
      // Emitir evento de cache hit
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.cacheHit,
        contenidoId: contenidoId,
      ));
      
      return cacheEntry.contenido;
    } catch (e) {
      'Error obteniendo contenido cacheado'.error(error: e, context: {
        'contenidoId': contenidoId,
      });
      return null;
    }
  }

  /// NUEVO: Guardar contenido en cache
  Future<void> saveContenido(ContenidoModel contenido, {List<String>? tags}) async {
    try {
      'ContenidoCacheService: Guardando contenido en cache'.debug(context: {
        'contenidoId': contenido.id,
        'titulo': contenido.titulo,
        'tags': tags,
      });
      
      final cacheEntry = ContenidoCacheEntry(
        contenidoId: contenido.id,
        contenido: contenido,
        timestamp: DateTime.now(),
        version: _currentVersion,
        tags: tags ?? [],
      );
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(contenido.id);
      await prefs.setString(cacheKey, jsonEncode(cacheEntry.toJson()));
      
      // Actualizar versión global
      await prefs.setString(_versionKey, _currentVersion);
      
      // Limpiar invalidación específica si existe
      _contenidoInvalidations.remove(contenido.id);
      
      'ContenidoCacheService: Contenido guardado en cache'.debug(context: {
        'contenidoId': contenido.id,
        'titulo': contenido.titulo,
        'timestamp': cacheEntry.timestamp.toIso8601String(),
      });
      
      // Emitir evento de cache actualizado
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.cacheUpdated,
        contenidoId: contenido.id,
        tags: tags,
      ));
    } catch (e) {
      'Error guardando contenido en cache'.error(error: e, context: {
        'contenidoId': contenido.id,
        'titulo': contenido.titulo,
      });
    }
  }

  /// NUEVO: Obtener múltiples contenidos cacheados por tags
  Future<List<ContenidoModel>> getContenidosByTags(List<String> tags) async {
    try {
      'ContenidoCacheService: Obteniendo contenidos por tags'.debug(context: {
        'tags': tags,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      final List<ContenidoModel> contenidos = [];
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = ContenidoCacheEntry.fromJson(cacheData);
            
            // Verificar si el cache es válido
            if (cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes) &&
                cacheEntry.version == _currentVersion &&
                cacheEntry.matchesTags(tags)) {
              
              // Verificar si hay invalidación de tag
              bool hasTagInvalidation = false;
              for (final tag in tags) {
                if (_isTagInvalidated(tag)) {
                  hasTagInvalidation = true;
                  break;
                }
              }
              
              if (!hasTagInvalidation) {
                contenidos.add(cacheEntry.contenido);
              }
            }
          }
        } catch (e) {
          // Si hay error al procesar una entrada, continuar con la siguiente
          'Error procesando entrada de cache'.error(error: e);
        }
      }
      
      'ContenidoCacheService: Contenidos obtenidos por tags'.debug(context: {
        'tags': tags,
        'cantidad': contenidos.length,
      });
      
      return contenidos;
    } catch (e) {
      'Error obteniendo contenidos por tags'.error(error: e, context: {
        'tags': tags,
      });
      return [];
    }
  }

  /// NUEVO: Invalidar contenido específico
  Future<void> invalidateContenido(String contenidoId) async {
    try {
      'ContenidoCacheService: Invalidando contenido'.debug(context: {
        'contenidoId': contenidoId,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(contenidoId);
      await prefs.remove(cacheKey);
      
      // Marcar como invalidado para evitar lecturas inmediatas
      _contenidoInvalidations[contenidoId] = DateTime.now();
      
      // Emitir evento de invalidación
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.cacheInvalidated,
        contenidoId: contenidoId,
      ));
      
      'ContenidoCacheService: Contenido invalidado'.debug(context: {
        'contenidoId': contenidoId,
      });
    } catch (e) {
      'Error invalidando contenido'.error(error: e, context: {
        'contenidoId': contenidoId,
      });
    }
  }

  /// NUEVO: Invalidar contenidos por tag
  Future<void> invalidateContenidosByTag(String tag) async {
    try {
      'ContenidoCacheService: Invalidando contenidos por tag'.debug(context: {
        'tag': tag,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      int invalidatedCount = 0;
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = ContenidoCacheEntry.fromJson(cacheData);
            
            // Si el contenido tiene el tag, invalidarlo
            if (cacheEntry.tags.contains(tag)) {
              await prefs.remove(key);
              invalidatedCount++;
            }
          }
        } catch (e) {
          // Si hay error al procesar una entrada, eliminarla
          await prefs.remove(key);
          invalidatedCount++;
        }
      }
      
      // Marcar tag como invalidado
      _tagInvalidations[tag] = DateTime.now();
      
      // Emitir evento de invalidación por tag
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.tagCacheInvalidated,
        tags: [tag],
        message: 'Invalidados $invalidatedCount contenidos con tag: $tag',
      ));
      
      'ContenidoCacheService: Contenidos por tag invalidados'.debug(context: {
        'tag': tag,
        'invalidatedCount': invalidatedCount,
      });
    } catch (e) {
      'Error invalidando contenidos por tag'.error(error: e, context: {
        'tag': tag,
      });
    }
  }

  /// NUEVO: Invalidar todo el cache de contenidos
  Future<void> invalidateAllContenidos() async {
    try {
      'ContenidoCacheService: Invalidando todo el cache de contenidos';
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      // Eliminar todas las entradas de cache
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
      
      // Marcar invalidación global
      await prefs.setString(_globalInvalidationKey, DateTime.now().toIso8601String());
      
      // Limpiar invalidaciones específicas
      _contenidoInvalidations.clear();
      _tagInvalidations.clear();
      
      // Emitir evento de invalidación global
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.globalCacheInvalidated,
        message: 'Todo el cache de contenidos invalidado',
      ));
      
      'ContenidoCacheService: Todo el cache invalidado'.debug(context: {
        'entriesRemoved': cacheKeys.length,
      });
    } catch (e) {
      'Error invalidando todo el cache'.error(error: e);
    }
  }

  /// NUEVO: Limpiar cache expirado
  Future<void> cleanExpiredCache() async {
    try {
      'ContenidoCacheService: Limpiando cache expirado';
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cacheKeyPrefix));
      
      int removedCount = 0;
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = ContenidoCacheEntry.fromJson(cacheData);
            
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
      
      'ContenidoCacheService: Cache expirado limpiado'.debug(context: {
        'entriesRemoved': removedCount,
      });
      
      // Emitir evento de cache limpio
      _eventController.add(ContenidoCacheEvent(
        type: ContenidoCacheEventType.cacheCleaned,
        message: 'Limpiadas $removedCount entradas expiradas',
      ));
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

  /// NUEVO: Verificar si hay invalidación específica para un contenido
  bool _isContenidoInvalidated(String contenidoId) {
    final invalidationTime = _contenidoInvalidations[contenidoId];
    if (invalidationTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    // Si la invalidación es muy reciente (menos de 30 segundos), considerar activa
    return now.difference(invalidationTime).inSeconds < 30;
  }

  /// NUEVO: Verificar si hay invalidación específica para un tag
  bool _isTagInvalidated(String tag) {
    final invalidationTime = _tagInvalidations[tag];
    if (invalidationTime == null) {
      return false;
    }
    
    final now = DateTime.now();
    // Si la invalidación es muy reciente (menos de 30 segundos), considerar activa
    return now.difference(invalidationTime).inSeconds < 30;
  }

  /// NUEVO: Obtener clave de cache para un contenido
  String _getCacheKey(String contenidoId) {
    return '$_cacheKeyPrefix$contenidoId';
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
      final Map<String, int> tagCounts = {};
      
      for (final key in cacheKeys) {
        try {
          final cacheJson = prefs.getString(key);
          if (cacheJson != null) {
            final cacheData = jsonDecode(cacheJson);
            final cacheEntry = ContenidoCacheEntry.fromJson(cacheData);
            
            if (cacheEntry.version != _currentVersion) {
              incompatibleEntries++;
            } else if (!cacheEntry.isValid(maxAgeMinutes: _maxCacheAgeMinutes)) {
              expiredEntries++;
            } else {
              validEntries++;
              
              // Contar tags
              for (final tag in cacheEntry.tags) {
                tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
              }
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
        'contenidoInvalidations': _contenidoInvalidations.length,
        'tagInvalidations': _tagInvalidations.length,
        'currentVersion': _currentVersion,
        'maxCacheAgeMinutes': _maxCacheAgeMinutes,
        'tagCounts': tagCounts,
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

/// NUEVO: Singleton del servicio
final contenidoCacheService = ContenidoCacheService();