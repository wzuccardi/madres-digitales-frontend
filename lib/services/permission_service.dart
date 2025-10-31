import 'dart:async';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/permission_cache_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class PermissionService {
  final ApiService _apiService;
  
  // NUEVO: Instancia del servicio de cache de permisos
  final PermissionCacheService _cacheService = permissionCacheService;
  
  // NUEVO: Stream subscription para eventos del cache
  StreamSubscription<PermissionCacheEvent>? _cacheEventSubscription;
  
  // NUEVO: Mapa para control de concurrencia en verificaciÃ³n de permisos
  final Map<String, Completer<bool>> _permissionChecks = {};
  
  // NUEVO: Tiempo mÃ­nimo entre verificaciones del mismo permiso (5 segundos)
  static const Duration _minTimeBetweenChecks = Duration(seconds: 5);
  
  // NUEVO: Mapa para registrar tiempo de Ãºltima verificaciÃ³n
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
    
    // NUEVO: Crear clave Ãºnica para la verificaciÃ³n
    final checkKey = '${gestanteId}_$accion';
    
    // NUEVO: Verificar si ya hay una verificaciÃ³n en progreso
    if (_permissionChecks.containsKey(checkKey)) {
      try {
        return await _permissionChecks[checkKey]!.future;
      } catch (e) {
        // Si la verificaciÃ³n previa fallÃ³, continuar con nueva verificaciÃ³n
      }
    }
    
    // NUEVO: Verificar si pasÃ³ tiempo mÃ­nimo desde Ãºltima verificaciÃ³n
    final lastCheckTime = _lastCheckTimes[checkKey];
    if (lastCheckTime != null) {
      final tiempoDesdeUltimaVerificacion = DateTime.now().difference(lastCheckTime);
      if (tiempoDesdeUltimaVerificacion < _minTimeBetweenChecks) {
        
        // Intentar obtener del cache sin forzar recarga
        final cachedPermissions = await _cacheService.getPermissions(gestanteId);
        if (cachedPermissions != null) {
          final tienePermiso = cachedPermissions.contains(accion);
          return tienePermiso;
        }
      }
    }
    
    // NUEVO: Crear completer para la verificaciÃ³n
    final completer = Completer<bool>();
    _permissionChecks[checkKey] = completer;
    
    try {
      // NUEVO: Primero intentar obtener del cache
      final cachedPermissions = await _cacheService.getPermissions(gestanteId);
      
      if (cachedPermissions != null) {
        final tienePermiso = cachedPermissions.contains(accion);
        
        // NUEVO: Actualizar tiempo de Ãºltima verificaciÃ³n
        _lastCheckTimes[checkKey] = DateTime.now();
        
        // NUEVO: Liberar completer
        _permissionChecks.remove(checkKey);
        completer.complete(tienePermiso);
        
        return tienePermiso;
      }
      
      // NUEVO: Si no estÃ¡ en cache, verificar desde API
      final response = await _apiService.get('/api/permisos/verificar', queryParameters: {
        'gestanteId': gestanteId,
        'accion': accion,
      });
      
      if (response.data['success'] == true && response.data['data'] != null) {
        final tienePermiso = response.data['data']['tienePermiso'] == true;
        final permisos = response.data['data']['permisos'] != null
            ? Set<String>.from(response.data['data']['permisos'])
            : <String>{};
        
        
        // NUEVO: Guardar en cache
        if (tienePermiso && permisos.isNotEmpty) {
          await _cacheService.savePermissions(gestanteId, permisos);
        }
        
        // NUEVO: Actualizar tiempo de Ãºltima verificaciÃ³n
        _lastCheckTimes[checkKey] = DateTime.now();
        
        // NUEVO: Liberar completer
        _permissionChecks.remove(checkKey);
        completer.complete(tienePermiso);
        
        return tienePermiso;
      } else {
        throw Exception('Respuesta invÃ¡lida del servidor');
      }
    } catch (e) {
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

  /// NUEVO: Invalidar cache de permisos para una gestante especÃ­fica
  Future<void> invalidarPermisosGestante(String gestanteId) async {
    
    try {
      await _cacheService.invalidatePermissions(gestanteId);
      
      // NUEVO: Limpiar tiempo de Ãºltima verificaciÃ³n para esta gestante
      final keysToRemove = _lastCheckTimes.keys.where((key) => key.startsWith('${gestanteId}_')).toList();
      for (final key in keysToRemove) {
        _lastCheckTimes.remove(key);
      }
      
    } catch (e) {
      'Error invalidando permisos'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
    }
  }

  /// NUEVO: Invalidar todo el cache de permisos
  Future<void> invalidarTodosLosPermisos() async {
    
    try {
      await _cacheService.invalidateAllPermissions();
      
      // NUEVO: Limpiar todos los tiempos de Ãºltima verificaciÃ³n
      _lastCheckTimes.clear();
      
    } catch (e) {
      'Error invalidando todo el cache'.error(error: e);
    }
  }

  /// NUEVO: Limpiar cache expirado
  Future<void> limpiarCacheExpirado() async {
    
    try {
      await _cacheService.cleanExpiredCache();
    } catch (e) {
      'Error limpiando cache expirado'.error(error: e);
    }
  }

  /// NUEVO: Obtener estadÃ­sticas del cache
  Future<Map<String, dynamic>> obtenerEstadisticasCache() async {
    try {
      final cacheStats = await _cacheService.getCacheStats();
      
      return {
        ...cacheStats,
        'activePermissionChecks': _permissionChecks.length,
        'lastCheckTimesCount': _lastCheckTimes.length,
      };
    } catch (e) {
      'Error obteniendo estadÃ­sticas del cache'.error(error: e);
      return {};
    }
  }

  /// NUEVO: Forzar recarga de permisos desde API
  Future<bool> recargarPermisosDesdeAPI(String gestanteId) async {
    
    try {
      // NUEVO: Invalidar cache para forzar recarga
      await _cacheService.invalidatePermissions(gestanteId);
      
      // NUEVO: Limpiar tiempos de Ãºltima verificaciÃ³n para esta gestante
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
        }
        
        return true;
      } else {
        throw Exception('Respuesta invÃ¡lida del servidor');
      }
    } catch (e) {
      'Error recargando permisos desde API'.error(error: e, context: {
        'gestanteId': gestanteId,
      });
      return false;
    }
  }

  /// NUEVO: Verificar mÃºltiples permisos a la vez
  Future<Map<String, bool>> verificarMultiplesPermisos(String gestanteId, List<String> acciones) async {
    
    final resultados = <String, bool>{};
    
    try {
      // NUEVO: Primero intentar obtener todos los permisos del cache
      final cachedPermissions = await _cacheService.getPermissions(gestanteId);
      
      if (cachedPermissions != null) {
        // NUEVO: Verificar cuÃ¡les permisos estÃ¡n en cache
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
      'Error verificando mÃºltiples permisos'.error(error: e, context: {
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
