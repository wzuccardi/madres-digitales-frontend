import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/auth_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class MedicoService {
  late final ApiService _apiService;
  late final AuthService _authService;

  MedicoService() {
    _apiService = ApiService(); // Usar el singleton
    _authService = AuthService();
  }

  /// Asegurar que el usuario estÃ© autenticado antes de hacer peticiones
  Future<void> _ensureAuthenticated() async {
    if (!_authService.isAuthenticated) {
      appLogger.info('MedicoService: Usuario no autenticado, inicializando AuthService...');
      await _authService.initialize();
      
      if (!_authService.isAuthenticated) {
        throw Exception('Usuario no autenticado. Por favor, inicie sesiÃ³n.');
      }
    }
  }

  // Obtener todos los médicos
  Future<List<dynamic>> getAllMedicos() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Obteniendo todos los médicos');
      final response = await _apiService.get('/medicos');

      List<dynamic> medicosData;
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        // Estructura: { success: true, data: { medicos: [...], total: ... } }
        if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
          medicosData = responseMap['data']['medicos'] as List<dynamic>;
        }
        // Estructura: { success: true, data: [...] }
        else if (responseMap['success'] == true && responseMap['data'] is List) {
          medicosData = responseMap['data'] as List<dynamic>;
        } else {
          throw Exception('Respuesta inválida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
        }
      } else if (response.data is List) {
        // La respuesta es directamente una lista
        medicosData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido para médicos');
      }

      return medicosData;
    } catch (e) {
      appLogger.error('Error obteniendo todos los médicos', error: e);
      rethrow;
    }
  }

  // Obtener médicos activos (usa el endpoint principal que ya filtra por activos)
  Future<List<dynamic>> getActiveMedicos() async {
    try {
      appLogger.info('MedicoService: Obteniendo médicos activos');
      final response = await _apiService.get('/medicos');

      List<dynamic> medicosData;
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        // Estructura: { success: true, data: { medicos: [...], total: ... } }
        if (responseMap['data'] is Map && responseMap['data']['medicos'] != null) {
          medicosData = responseMap['data']['medicos'] as List<dynamic>;
        }
        // Estructura: { success: true, data: [...] }
        else if (responseMap['success'] == true && responseMap['data'] is List) {
          medicosData = responseMap['data'] as List<dynamic>;
        } else {
          throw Exception('Respuesta inválida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
        }
      } else if (response.data is List) {
        medicosData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido para médicos');
      }

      return medicosData;
    } catch (e) {
      appLogger.error('Error obteniendo médicos activos', error: e);
      rethrow;
    }
  }

  // Buscar mÃ©dicos por nombre (filtrado en el cliente por ahora)
  Future<List<dynamic>> searchMedicos(String query) async {
    try {
      appLogger.info('MedicoService: Buscando mÃ©dicos con query: $query');
      final response = await _apiService.get('/medicos');
      
      List<dynamic> medicos;
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          medicos = responseMap['data'] as List<dynamic>;
        } else {
          throw Exception('Respuesta invÃ¡lida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
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
    } catch (e) {
      appLogger.error('Error buscando médicos', error: e);
      rethrow;
    }
  }

  // Obtener mÃ©dico por ID
  Future<Map<String, dynamic>> getMedicoById(String id) async {
    try {
      appLogger.info('MedicoService: Obteniendo mÃ©dico por ID: $id');
      final response = await _apiService.get('/medicos/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo mÃ©dico por ID', error: e);
      rethrow;
    }
  }

  // Obtener mÃ©dicos por IPS
  Future<List<dynamic>> getMedicosByIps(String ipsId) async {
    try {
      appLogger.info('MedicoService: Obteniendo mÃ©dicos por IPS: $ipsId');
      final response = await _apiService.get('/medicos/ips/$ipsId');
      return response.data as List<dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo mÃ©dicos por IPS', error: e);
      rethrow;
    }
  }

  // Crear nuevo mÃ©dico
  Future<Map<String, dynamic>> createMedico(Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Creando nuevo mÃ©dico');
      final response = await _apiService.post('/medicos', data: medicoData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error creando mÃ©dico', error: e);
      rethrow;
    }
  }

  // Actualizar mÃ©dico
  Future<Map<String, dynamic>> updateMedico(String id, Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Actualizando mÃ©dico ID: $id');
      final response = await _apiService.put('/medicos/$id', data: medicoData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error actualizando mÃ©dico', error: e);
      rethrow;
    }
  }

  // Eliminar mÃ©dico
  Future<void> deleteMedico(String id) async {
    try {
      appLogger.info('MedicoService: Eliminando mÃ©dico ID: $id');
      await _apiService.delete('/medicos/$id');
    } catch (e) {
      appLogger.error('Error eliminando mÃ©dico', error: e);
      rethrow;
    }
  }

  // Activar/Desactivar mÃ©dico (usando update con campo activo)
  Future<Map<String, dynamic>> toggleMedicoStatus(String id, bool activo) async {
    try {
      appLogger.info('MedicoService: Cambiando estado del mÃ©dico ID: $id a $activo');
      final response = await _apiService.put('/medicos/$id', data: {'activo': activo});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error cambiando estado del mÃ©dico', error: e);
      rethrow;
    }
  }

  // Obtener estadÃ­sticas de mÃ©dicos (calculadas en el cliente)
  Future<Map<String, dynamic>> getMedicosStats() async {
    try {
      appLogger.info('MedicoService: Obteniendo estadÃ­sticas de mÃ©dicos');
      final response = await _apiService.get('/medicos');
      final medicos = response.data as List<dynamic>;
      
      final total = medicos.length;
      final activos = medicos.where((m) => m['activo'] == true).length;
      final inactivos = total - activos;
      
      return {
        'total': total,
        'activos': activos,
        'inactivos': inactivos,
      };
    } catch (e) {
      appLogger.error('Error obteniendo estadÃ­sticas de mÃ©dicos', error: e);
      rethrow;
    }
  }
}
