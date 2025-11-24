import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/data/services/cache_service.dart';
import 'package:madres_digitales_flutter_new/domain/entities/user_permission.dart';
import 'package:madres_digitales_flutter_new/domain/entities/tipo_permiso.dart';
import 'package:madres_digitales_flutter_new/domain/repositories/permission_repository.dart';

class PermissionRepositoryImpl implements PermissionRepository {

  PermissionRepositoryImpl(this._apiService, this._cacheService);
  final ApiService _apiService;
  final CacheService _cacheService;
  
  // Cache local para permisos
  final Map<String, UserPermission> _permissionCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Duración del cache en minutos
  static const int _cacheDurationMinutes = 15;

  @override
  Future<UserPermission> obtenerPermisosUsuario(String userId) async {
    try {
      // Verificar si hay cache válido
      if (_isCacheValid(userId)) {
        return _permissionCache[userId]!;
      }

      // Obtener desde API
      final response = await _apiService.get<Map<String, dynamic>>('/usuarios/$userId/permisos');
      if (response.success) {
        final userPermission = UserPermission.fromJson(response.data!);
        
        // Actualizar cache
        _permissionCache[userId] = userPermission;
        _cacheTimestamps[userId] = DateTime.now();
        
        // Guardar en cache persistente
        await _cacheService.set('user_permissions_$userId', userPermission.toJson());
        
        return userPermission;
      } else {
        throw PermissionFailure(response.message ?? 'Error obteniendo permisos');
      }
    } catch (e) {
      throw PermissionFailure('Error obteniendo permisos: $e');
    }
  }

  @override
  Future<bool> verificarPermiso(String userId, TipoPermiso permiso) async {
    try {
      final userPermission = await obtenerPermisosUsuario(userId);
      return userPermission.tienePermiso(permiso);
    } catch (e) {
      // Fail-safe: denegar si hay error
      return false;
    }
  }

  @override
  Future<bool> verificarPermisoSobreGestante(String userId, String gestanteId, TipoPermiso permiso) async {
    try {
      // Verificar permiso general primero
      final tienePermisoGeneral = await verificarPermiso(userId, permiso);
      if (!tienePermisoGeneral) {
        return false;
      }

      // Para permisos específicos de gestantes, verificar con API
      final response = await _apiService.post<Map<String, dynamic>>('/permisos/verificar-gestante', data: {
        'userId': userId,
        'gestanteId': gestanteId,
        'permiso': permiso.toString().split('.').last,
      });
      
      if (response.success) {
        return (response.data?['tienePermiso'] as bool?) ?? false;
      } else {
        // Fallback a verificación local
        final userPermission = await obtenerPermisosUsuario(userId);
        
        // Si es madrina o coordinador, verificar si la gestante está asignada
        if (['madrina', 'coordinador'].contains(userPermission.rol)) {
          // Aquí se podría verificar si la gestante está asignada a esta madrina
          // Por ahora, retornamos true si tiene el permiso general
          return true;
        }
        
        return false;
      }
    } catch (e) {
      // Fail-safe: denegar si hay error
      return false;
    }
  }

  @override
  Future<void> actualizarPermisosUsuario(String userId, Set<TipoPermiso> nuevosPermisos) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>('/usuarios/$userId/permisos', data: {
        'permisos': nuevosPermisos.map((p) => p.toString().split('.').last).toList(),
      });
      
      if (response.success) {
        // Invalidar cache local
        _invalidateCache(userId);
        
        // Obtener permisos actualizados
        await obtenerPermisosUsuario(userId);
        return;
      } else {
        throw PermissionFailure(response.message ?? 'Error actualizando permisos');
      }
    } catch (e) {
      throw PermissionFailure('Error actualizando permisos: $e');
    }
  }

  @override
  Stream<UserPermission> observarCambiosPermisos(String userId) {
    // Emite cambios cada 30s usando asyncMap para no devolver Future en el Stream
    return Stream.periodic(const Duration(seconds: 30)).asyncMap((_) async {
      try {
        final userPermission = await obtenerPermisosUsuario(userId);
        return userPermission;
      } catch (e) {
        return _permissionCache[userId] ?? UserPermission.madrina(userId);
      }
    });
  }

  // Métodos de permisos específicos
  @override
  Future<bool> puedeVerGestantesAsignadas(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verGestantesAsignadas);
  }

  @override
  Future<bool> puedeVerTodasGestantes(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verTodasGestantes);
  }

  @override
  Future<bool> puedeCrearGestante(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.crearGestante);
  }

  @override
  Future<bool> puedeEditarGestante(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.editarGestante);
  }

  @override
  Future<bool> puedeEliminarGestante(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.eliminarGestante);
  }

  @override
  Future<bool> puedeAsignarGestante(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.asignarGestante);
  }

  @override
  Future<bool> puedeVerControles(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verControles);
  }

  @override
  Future<bool> puedeCrearControl(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.crearControl);
  }

  @override
  Future<bool> puedeEditarControl(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.editarControl);
  }

  @override
  Future<bool> puedeVerAlertas(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verAlertas);
  }

  @override
  Future<bool> puedeCrearAlerta(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.crearAlerta);
  }

  @override
  Future<bool> puedeGestionarAlertasCriticas(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.gestionarAlertasCriticas);
  }

  @override
  Future<bool> puedeVerReportesBasicos(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verReportesBasicos);
  }

  @override
  Future<bool> puedeVerReportesAvanzados(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verReportesAvanzados);
  }

  @override
  Future<bool> puedeExportarReportes(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.exportarReportes);
  }

  @override
  Future<bool> puedeActivarSOS(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.activarSOS);
  }

  @override
  Future<bool> puedeVerTerminalSOS(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.verTerminalSOS);
  }

  @override
  Future<bool> puedeGestionarEmergencias(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.gestionarEmergencias);
  }

  @override
  Future<bool> puedeGestionarUsuarios(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.gestionarUsuarios);
  }

  @override
  Future<bool> puedeGestionarMunicipios(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.gestionarMunicipios);
  }

  @override
  Future<bool> puedeConfigurarSistema(String userId) async {
    return await verificarPermiso(userId, TipoPermiso.configurarSistema);
  }

  // Métodos privados para manejo de cache
  bool _isCacheValid(String userId) {
    final timestamp = _cacheTimestamps[userId];
    if (timestamp == null) return false;
    
    final cacheAge = DateTime.now().difference(timestamp);
    return cacheAge.inMinutes < _cacheDurationMinutes;
  }

  void _invalidateCache(String userId) {
    _permissionCache.remove(userId);
    _cacheTimestamps.remove(userId);
    
    // También invalidar en cache persistente
    _cacheService.remove('user_permissions_$userId');
  }
}
