import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/permission_cache_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class PermissionService {
  final ApiService _apiService;
  
  // NUEVO: Instancia del servicio de cache de permisos
  final PermissionCacheService _cacheService = permissionCacheService;
  
  // NUEVO: Stream subscription para eventos del cache
  StreamSubscription<PermissionCacheEvent>? _cacheEventSubscription;
  
  // NUEVO: Mapa para control de concurrencia en verificación de permisos
  final Map<String, Completer<bool>> _permissionChecks = {};
  
  // NUEVO: Tiempo mínimo entre verificaciones del mismo permiso (5 segundos)
  static const Duration _minTimeBetweenChecks = Duration(seconds: 5);
  
  // NUEVO: Mapa para registrar tiempo de última verificación
  final Map<String, DateTime> _lastCheckTimes = {};

  PermissionService(this._apiService) {
    // NUEVO: Escuchar eventos del cache
    _cacheEventSubscription = _cacheService.events.listen((event) {
      _handleCacheEvent(event);
    });
  }

  /// NUEVO: Manejar eventos del cache
  void _handleCacheEvent(PermissionCacheEvent event) {
    switch (event.type) {
      case PermissionCacheEventType.cacheInvalidated:
        'PermissionService: Cache invalidado'.debug(context: {
          'gestanteId': event.gestanteId,
        });
        break;
      case PermissionCacheEventType.globalCacheInvalidated:
        'PermissionService: Cache global invalidado'.debug();
        break;
      case PermissionCacheEventType.cacheUpdated:
        'PermissionService: Cache actualizado'.debug(context: {
          'gestanteId': event.gestanteId,
          'permissions': event.permissions.length,
        });
        break;
      case PermissionCacheEventType.cacheHit:
        'PermissionService: Cache hit'.debug(context: {
          'gestanteId': event.gestanteId,
        });
        break;
      default:
        break;
    }
  }

  /// Verificar si tiene permiso sobre una gestante con cache y control de concurrencia
  Future<bool> tienePermisoSobreGestante(String gestanteId, String accion) async {
    debugPrint('🔐 PermissionService: Verificando permiso "$accion" para gestante $gestanteId');
    
    // NUEVO: Crear clave única para la verificación
    final checkKey = '${gestanteId}_$accion';
    
    // NUEVO: Verificar si ya hay una verificación en progreso
    if (_permissionChecks.containsKey(checkKey)) {
      debugPrint('🔐 PermissionService: Verificación ya en progreso, esperando resultado...');
      try {
        return await _permissionChecks[checkKey]!.future;
      } catch (e) {
        debugPrint('❌ PermissionService: Error en verificación previa: $e');
        // Si la verificación previa falló, continuar con nueva verificación
      }
    }
    
    // NUEVO: Verificar si pasó tiempo mínimo desde última verificación
    final lastCheckTime = _lastCheckTimes[checkKey];
    if (lastCheckTime != null) {
      final tiempoDesdeUltimaVerificacion = DateTime.now().difference(lastCheckTime);
      if (tiempoDesdeUltimaVerificacion < _minTimeBetweenChecks) {
        debugPrint('🔐 PermissionService: Verificación muy reciente, usando cache...');
        
        // Intentar obtener del cache sin forzar recarga
        final cachedPermissions = await _cacheService.getPermissions(gestanteId);
        if (cachedPermissions != null) {
          final tienePermiso = cachedPermissions.contains(accion);
          debugPrint('🔐 PermissionService: Permiso desde cache reciente: $tienePermiso');
          return tienePermiso;
        }
      }
    }
    
    // NUEVO: Crear completer para la verificación
    final completer = Completer<bool>();
    _permissionChecks[checkKey] = completer;
    
    try {
      // NUEVO: Primero intentar obtener del cache
      final cachedPermissions = await _cacheService.getPermissions(gestanteId);
      
      if (cachedPermissions != null) {
        final tienePermiso = cachedPermissions.contains(accion);
        debugPrint('🔐 PermissionService: Permiso desde cache: $tienePermiso');
        
        // NUEVO: Actualizar tiempo de última verificación
        _lastCheckTimes[checkKey] = DateTime.now();
        
        // NUEVO: Liberar completer
        _permissionChecks.remove(checkKey);
        completer.complete(tienePermiso);
        
        return tienePermiso;
      }
      
      // NUEVO: Si no está en cache, verificar desde API
      debugPrint('🔐 PermissionService: Verificando desde API...');
      final response = await _apiService.get('/api/permisos/verificar', queryParameters: {
        'gestanteId': gestanteId,
        'accion': accion,
      });
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final tienePermiso = response.data['data']['tienePermiso'] == true;
        final permisos = response.data['data']['permisos'] != null
            ? Set<String>.from(response.data['data']['permisos'])
            : <String>{};
        
        debugPrint('🔐 PermissionService: Permiso desde API: $tienePermiso');
        
        // NUEVO: Guardar en cache
        if (tienePermiso && permisos.isNotEmpty) {
          await _cacheService.savePermissions(gestanteId, permisos);
          debugPrint('🔐 PermissionService: Permisos guardados en cache');
        }
        
        // NUEVO: Actualizar tiempo de última verificación
        _lastCheckTimes[checkKey] = DateTime.now();
        
        // NUEVO: Liberar completer
        _permissionChecks.remove(checkKey);
        completer.complete(tienePermiso);
        
        return tienePermiso;
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      debugPrint('❌ PermissionService: Error verificando permiso: $e');
      'Error verificando permiso'.error(error: e, context: {
        'gestanteId': gestanteId,
        'accion': accion,
      });
      
      // NUEVO: Liberar completer con error
      _permissionChecks.remove(checkKey);
      completer.completeError(e);
      
      return false;
    }
  }

  /// NUEVO: Invalidar cache de permisos para una gestante específica
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    debugPrint('🔐 PermissionService: Invalidando permisos para gestante $gestanteId');
    
    try {
      await _cacheService.invalidatePermissions(gestanteId);
      
      // NUEVO: Limpiar tiempo de última verificación para esta gestante
      final keysToRemove = _lastCheckTimes.keys.where((key) => key.startsWith('${gestanteId}_')).toList();
      for (final key in keysToRemove) {
        _lastCheckTimes.remove(key);
      }
      
      debugPrint('🔐 PermissionService: Permisos invalidados correctamente');
    } catch (e) {
      debugPrint('❌ PermissionService: Error invalidando permisos: $e');
      'Error invalidando permisos'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
    }
  }

  /// NUEVO: Invalidar todo el cache de permisos
  Future<void> invalidarTodosLosPermisos() async {
    debugPrint('🔐 PermissionService: Invalidando todo el cache de permisos');
    
    try {
      await _cacheService.invalidateAllPermissions();
      
      // NUEVO: Limpiar todos los tiempos de última verificación
      _lastCheckTimes.clear();
      
      debugPrint('🔐 PermissionService: Todo el cache invalidado correctamente');
    } catch (e) {
      debugPrint('❌ PermissionService: Error invalidando todo el cache: $e');
      'Error invalidando todo el cache'.error(error: e);
    }
  }

  /// NUEVO: Limpiar cache expirado
  Future<void> limpiarCacheExpirado() async {
    debugPrint('🔐 PermissionService: Limpiando cache expirado');
    
    try {
      await _cacheService.cleanExpiredCache();
      debugPrint('🔐 PermissionService: Cache expirado limpiado correctamente');
    } catch (e) {
      debugPrint('❌ PermissionService: Error limpiando cache expirado: $e');
      'Error limpiando cache expirado'.error(error: e);
    }
  }

  /// NUEVO: Obtener estadísticas del cache
  Future<Map<String, dynamic>> obtenerEstadisticasCache() async {
    try {
      final cacheStats = await _cacheService.getCacheStats();
      
      return {
        ...cacheStats,
        'activePermissionChecks': _permissionChecks.length,
        'lastCheckTimesCount': _lastCheckTimes.length,
      };
    } catch (e) {
      debugPrint('❌ PermissionService: Error obteniendo estadísticas del cache: $e');
      'Error obteniendo estadísticas del cache'.error(error: e);
      return {};
    }
  }

  /// NUEVO: Forzar recarga de permisos desde API
  Future<bool> recargarPermisosDesdeAPI(String gestanteId) async {
    debugPrint('🔐 PermissionService: Forzando recarga de permisos desde API para gestante $gestanteId');
    
    try {
      // NUEVO: Invalidar cache para forzar recarga
      await _cacheService.invalidatePermissions(gestanteId);
      
      // NUEVO: Limpiar tiempos de última verificación para esta gestante
      final keysToRemove = _lastCheckTimes.keys.where((key) => key.startsWith('${gestanteId}_')).toList();
      for (final key in keysToRemove) {
        _lastCheckTimes.remove(key);
      }
      
      // NUEVO: Obtener permisos actualizados desde API
      final response = await _apiService.get('/api/permisos/gestante/$gestanteId');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final permisos = response.data['data']['permisos'] != null
            ? Set<String>.from(response.data['data']['permisos'])
            : <String>{};
        
        // NUEVO: Guardar en cache
        if (permisos.isNotEmpty) {
          await _cacheService.savePermissions(gestanteId, permisos);
          debugPrint('🔐 PermissionService: Permisos recargados y guardados en cache');
        }
        
        return true;
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      debugPrint('❌ PermissionService: Error recargando permisos desde API: $e');
      'Error recargando permisos desde API'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
      return false;
    }
  }

  /// NUEVO: Verificar múltiples permisos a la vez
  Future<Map<String, bool>> verificarMultiplesPermisos(String gestanteId, List<String> acciones) async {
    debugPrint('🔐 PermissionService: Verificando múltiples permisos para gestante $gestanteId');
    
    final resultados = <String, bool>{};
    
    try {
      // NUEVO: Primero intentar obtener todos los permisos del cache
      final cachedPermissions = await _cacheService.getPermissions(gestanteId);
      
      if (cachedPermissions != null) {
        // NUEVO: Verificar cuáles permisos están en cache
        final permisosEnCache = <String>{};
        final permisosFaltantes = <String>[];
        
        for (final accion in acciones) {
          if (cachedPermissions.contains(accion)) {
            permisosEnCache.add(accion);
            resultados[accion] = true;
          } else {
            permisosFaltantes.add(accion);
            resultados[accion] = false;
          }
        }
        
        debugPrint('🔐 PermissionService: ${permisosEnCache.length} permisos encontrados en cache, ${permisosFaltantes.length} faltantes');
        
        // NUEVO: Si faltan permisos, verificarlos individualmente
        if (permisosFaltantes.isNotEmpty) {
          for (final accion in permisosFaltantes) {
            resultados[accion] = await tienePermisoSobreGestante(gestanteId, accion);
          }
        }
      } else {
        // NUEVO: Si no hay cache, verificar cada permiso individualmente
        for (final accion in acciones) {
          resultados[accion] = await tienePermisoSobreGestante(gestanteId, accion);
        }
      }
      
      return resultados;
    } catch (e) {
      debugPrint('❌ PermissionService: Error verificando múltiples permisos: $e');
      'Error verificando múltiples permisos'.error(error: e, context: {
        'gestanteId': gestanteId,
        'acciones': acciones,
      });
      
      // NUEVO: En caso de error, retornar false para todos los permisos
      for (final accion in acciones) {
        resultados[accion] = false;
      }
      
      return resultados;
    }
  }

  /// NUEVO: Liberar recursos
  void dispose() {
    _cacheEventSubscription?.cancel();
    _permissionChecks.clear();
    _lastCheckTimes.clear();
  }
}