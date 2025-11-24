import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import '../../core/network/api_service.dart';
import 'auth_service.dart';
import 'cache_service.dart';
import 'sync_service.dart';


class MedicoService {

  MedicoService({
    ApiService? apiService,
    AuthService? authService,
    CacheService? cacheService,
    SyncService? syncService,
  }) : _apiService = apiService ?? ApiService(),
       _authService = authService ?? AuthService(),
       _cacheService = cacheService ?? CacheService(),
       _syncService = syncService ?? SyncService();
  final ApiService _apiService;
  final AuthService _authService;
  final CacheService _cacheService;
  final SyncService _syncService;

  /// Asegurar que el usuario esté autenticado antes de hacer peticiones
  Future<void> _ensureAuthenticated() async {
    try {
      final token = await _apiService.getAccessToken();
      if (token == null) {
        AppLogger.info('MedicoService: Usuario no autenticado, inicializando AuthService...');
        await _authService.initialize();
        
        final newToken = await _apiService.getAccessToken();
        if (newToken == null) {
          throw Exception('Usuario no autenticado. Por favor, inicie sesión.');
        }
      }
    } catch (e) {
      AppLogger.error('MedicoService: Error en autenticación', error: e);
      throw Exception('Error de autenticación: ${e.toString()}');
    }
  }

  // Obtener todos los médicos
  Future<List<dynamic>> getAllMedicos() async {
    AppLogger.info('MedicoService: Obteniendo todos los médicos');
    final response = await _apiService.get<dynamic>('/medicos');
    List<dynamic> medicosData = const [];
    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
          medicosData = responseMap['data']['medicos'] as List<dynamic>;
        } else if (responseMap['success'] == true && responseMap['data'] is List) {
          medicosData = responseMap['data'] as List<dynamic>;
        }
      } else if (response.data is List) {
        medicosData = response.data as List<dynamic>;
      }
    }
    if (medicosData.isEmpty) {
      final retry = await _apiService.get<dynamic>('/medicos', queryParameters: {'ts': DateTime.now().millisecondsSinceEpoch});
      if (retry.success && retry.data != null) {
        if (retry.data is Map<String, dynamic>) {
          final responseMap = retry.data as Map<String, dynamic>;
          if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
            medicosData = responseMap['data']['medicos'] as List<dynamic>;
          } else if (responseMap['success'] == true && responseMap['data'] is List) {
            medicosData = responseMap['data'] as List<dynamic>;
          }
        } else if (retry.data is List) {
          medicosData = retry.data as List<dynamic>;
        }
      }
    }
    if (medicosData.isNotEmpty) {
      await _cacheService.setList('medicos_list', medicosData);
      await _cacheService.set('medicos_list_meta', {'ts': DateTime.now().toIso8601String()});
      return medicosData;
    }
    final cached = await _cacheService.getList('medicos_list') ?? const [];
    if (cached.isNotEmpty) {
      return cached;
    }
    return const [];
  }

  Future<Map<String, dynamic>?> getMedicoById(String id) async {
    try {
      final resp = await _apiService.get<dynamic>('/medicos/$id');
      if (!resp.success) return null;
      final map = _apiService.extractObject(resp.data);
      return map;
    } catch (e) {
      AppLogger.error('Error obteniendo médico por id', error: e);
      return null;
    }
  }

  // Obtener médicos activos (usa el endpoint principal que ya filtra por activos)
  Future<List<dynamic>> getActiveMedicos() async {
    AppLogger.info('MedicoService: Obteniendo médicos activos');
    final response = await _apiService.get<dynamic>('/medicos');
    List<dynamic> medicosData = const [];
    if (response.success && response.data != null) {
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
          medicosData = responseMap['data']['medicos'] as List<dynamic>;
        } else if (responseMap['success'] == true && responseMap['data'] is List) {
          medicosData = responseMap['data'] as List<dynamic>;
        }
      } else if (response.data is List) {
        medicosData = response.data as List<dynamic>;
      }
    }
    if (medicosData.isEmpty) {
      final retry = await _apiService.get<dynamic>('/medicos', queryParameters: {'ts': DateTime.now().millisecondsSinceEpoch});
      if (retry.success && retry.data != null) {
        if (retry.data is Map<String, dynamic>) {
          final responseMap = retry.data as Map<String, dynamic>;
          if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
            medicosData = responseMap['data']['medicos'] as List<dynamic>;
          } else if (responseMap['success'] == true && responseMap['data'] is List) {
            medicosData = responseMap['data'] as List<dynamic>;
          }
        } else if (retry.data is List) {
          medicosData = retry.data as List<dynamic>;
        }
      }
    }
    if (medicosData.isNotEmpty) {
      await _cacheService.setList('medicos_active_list', medicosData);
      await _cacheService.set('medicos_active_meta', {'ts': DateTime.now().toIso8601String()});
      return medicosData;
    }
    final cached = await _cacheService.getList('medicos_active_list') ?? const [];
    if (cached.isNotEmpty) {
      return cached;
    }
    return const [];
  }

  // Buscar médicos por nombre (filtrado en el cliente por ahora)
  Future<List<dynamic>> searchMedicos(String query) async {
    try {
      AppLogger.info('MedicoService: Buscando médicos con query: $query');
      final response = await _apiService.get<dynamic>('/medicos');
      
      if (response.success && response.data != null) {
        List<dynamic> medicos;
        
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          if (responseMap['success'] == true && responseMap['data'] != null) {
            medicos = responseMap['data'] as List<dynamic>;
          } else {
            throw Exception('Respuesta inválida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
          }
        } else {
          medicos = response.data as List<dynamic>;
        }
        
        // Filtrar en el cliente por nombre
        final resultados = medicos.where((medico) {
          final nombre = medico['nombre']?.toString().toLowerCase() ?? '';
          return nombre.contains(query.toLowerCase());
        }).toList();
        
        return resultados;
      } else {
        final errorMessage = response.error?.message ?? 'Error al buscar médicos';
        AppLogger.error('MedicoService: Error buscando médicos: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error buscando médicos', error: e);
      rethrow;
    }
  }

  // Método duplicado removido

  // Obtener médicos por IPS
  Future<List<dynamic>> getMedicosByIps(String ipsId) async {
    try {
      AppLogger.info('MedicoService: Obteniendo médicos por IPS: $ipsId');
      final response = await _apiService.get<List<dynamic>>('/medicos/ips/$ipsId');
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener médicos por IPS';
        AppLogger.error('MedicoService: Error obteniendo médicos por IPS: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error obteniendo médicos por IPS', error: e);
      rethrow;
    }
  }

  // Crear nuevo médico
  Future<Map<String, dynamic>> createMedico(Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      AppLogger.info('MedicoService: Creando nuevo médico');
      final response = await _apiService.post<Map<String, dynamic>>('/medicos', data: medicoData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMessage = response.error?.message ?? 'Error al crear médico';
        AppLogger.error('MedicoService: Error creando médico: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      await _syncService.markForSync('medicos_create', medicoData);
      AppLogger.error('Error creando médico', error: e);
      rethrow;
    }
  }

  // Actualizar médico
  Future<Map<String, dynamic>> updateMedico(String id, Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      AppLogger.info('MedicoService: Actualizando médico ID: $id');
      final response = await _apiService.put<Map<String, dynamic>>('/medicos/$id', data: medicoData);
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMessage = response.error?.message ?? 'Error al actualizar médico';
        AppLogger.error('MedicoService: Error actualizando médico: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      await _syncService.markForSync('medicos_update', {'id': id, ...medicoData});
      AppLogger.error('Error actualizando médico', error: e);
      rethrow;
    }
  }

  // Eliminar médico
  Future<void> deleteMedico(String id) async {
    try {
      AppLogger.info('MedicoService: Eliminando médico ID: $id');
      final response = await _apiService.delete<dynamic>('/medicos/$id');
      
      if (response.success) {
        AppLogger.info('MedicoService: Médico eliminado exitosamente');
      } else {
        final errorMessage = response.error?.message ?? 'Error al eliminar médico';
        AppLogger.error('MedicoService: Error eliminando médico: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      await _syncService.markForSync('medicos_delete', {'id': id});
      AppLogger.error('Error eliminando médico', error: e);
      rethrow;
    }
  }

  // Activar/Desactivar médico (usando update con campo activo)
  Future<Map<String, dynamic>> toggleMedicoStatus(String id, bool activo) async {
    try {
      AppLogger.info('MedicoService: Cambiando estado del médico ID: $id a $activo');
      final response = await _apiService.put<Map<String, dynamic>>('/medicos/$id', data: {'activo': activo});
      
      if (response.success && response.data != null) {
        return response.data!;
      } else {
        final errorMessage = response.error?.message ?? 'Error al cambiar estado del médico';
        AppLogger.error('MedicoService: Error cambiando estado del médico: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      await _syncService.markForSync('medicos_toggle', {'id': id, 'activo': activo});
      AppLogger.error('Error cambiando estado del médico', error: e);
      rethrow;
    }
  }

  // Obtener estadísticas de médicos (calculadas en el cliente)
  Future<Map<String, dynamic>> getMedicosStats() async {
    try {
      AppLogger.info('MedicoService: Obteniendo estadísticas de médicos');
      final response = await _apiService.get<dynamic>('/medicos');
      
      if (response.success && response.data != null) {
        List<dynamic> medicos;
        
        if (response.data is Map<String, dynamic>) {
          final responseMap = response.data as Map<String, dynamic>;
          if (responseMap['success'] == true && responseMap['data'] != null) {
            medicos = responseMap['data'] as List<dynamic>;
          } else {
            medicos = [];
          }
        } else if (response.data is List) {
          medicos = response.data as List<dynamic>;
        } else {
          medicos = [];
        }
        
        // Cachea lista simple para estadísticas rápidas
        await _cacheService.setList('medicos_list', medicos);
        await _cacheService.set('medicos_list_meta', {'ts': DateTime.now().toIso8601String()});
        final total = medicos.length;
        final activos = medicos.where((m) => m['activo'] == true).length;
        final inactivos = total - activos;
        
        return {
          'total': total,
          'activos': activos,
          'inactivos': inactivos,
        };
      } else {
        final errorMessage = response.error?.message ?? 'Error al obtener estadísticas de médicos';
        AppLogger.error('MedicoService: Error obteniendo estadísticas de médicos: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      AppLogger.error('Error obteniendo estadísticas de médicos', error: e);
      rethrow;
    }
  }
}
