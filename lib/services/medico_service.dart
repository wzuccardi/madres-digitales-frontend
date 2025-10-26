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

  /// Asegurar que el usuario esté autenticado antes de hacer peticiones
  Future<void> _ensureAuthenticated() async {
    if (!_authService.isAuthenticated) {
      appLogger.info('MedicoService: Usuario no autenticado, inicializando AuthService...');
      await _authService.initialize();
      
      if (!_authService.isAuthenticated) {
        throw Exception('Usuario no autenticado. Por favor, inicie sesión.');
      }
    }
  }

  // Obtener todos los médicos
  Future<List<dynamic>> getAllMedicos() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Obteniendo todos los médicos');
      final response = await _apiService.get('/medicos');
      return response.data as List<dynamic>;
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
      return response.data as List<dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo médicos activos', error: e);
      rethrow;
    }
  }

  // Buscar médicos por nombre (filtrado en el cliente por ahora)
  Future<List<dynamic>> searchMedicos(String query) async {
    try {
      appLogger.info('MedicoService: Buscando médicos con query: $query');
      final response = await _apiService.get('/medicos');
      final medicos = response.data as List<dynamic>;
      
      // Filtrar en el cliente por nombre
      return medicos.where((medico) {
        final nombre = medico['nombre']?.toString().toLowerCase() ?? '';
        return nombre.contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      appLogger.error('Error buscando médicos', error: e);
      rethrow;
    }
  }

  // Obtener médico por ID
  Future<Map<String, dynamic>> getMedicoById(String id) async {
    try {
      appLogger.info('MedicoService: Obteniendo médico por ID: $id');
      final response = await _apiService.get('/medicos/$id');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo médico por ID', error: e);
      rethrow;
    }
  }

  // Obtener médicos por IPS
  Future<List<dynamic>> getMedicosByIps(String ipsId) async {
    try {
      appLogger.info('MedicoService: Obteniendo médicos por IPS: $ipsId');
      final response = await _apiService.get('/medicos/ips/$ipsId');
      return response.data as List<dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo médicos por IPS', error: e);
      rethrow;
    }
  }

  // Crear nuevo médico
  Future<Map<String, dynamic>> createMedico(Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Creando nuevo médico');
      final response = await _apiService.post('/medicos', data: medicoData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error creando médico', error: e);
      rethrow;
    }
  }

  // Actualizar médico
  Future<Map<String, dynamic>> updateMedico(String id, Map<String, dynamic> medicoData) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MedicoService: Actualizando médico ID: $id');
      final response = await _apiService.put('/medicos/$id', data: medicoData);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error actualizando médico', error: e);
      rethrow;
    }
  }

  // Eliminar médico
  Future<void> deleteMedico(String id) async {
    try {
      appLogger.info('MedicoService: Eliminando médico ID: $id');
      await _apiService.delete('/medicos/$id');
    } catch (e) {
      appLogger.error('Error eliminando médico', error: e);
      rethrow;
    }
  }

  // Activar/Desactivar médico (usando update con campo activo)
  Future<Map<String, dynamic>> toggleMedicoStatus(String id, bool activo) async {
    try {
      appLogger.info('MedicoService: Cambiando estado del médico ID: $id a $activo');
      final response = await _apiService.put('/medicos/$id', data: {'activo': activo});
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error cambiando estado del médico', error: e);
      rethrow;
    }
  }

  // Obtener estadísticas de médicos (calculadas en el cliente)
  Future<Map<String, dynamic>> getMedicosStats() async {
    try {
      appLogger.info('MedicoService: Obteniendo estadísticas de médicos');
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
      appLogger.error('Error obteniendo estadísticas de médicos', error: e);
      rethrow;
    }
  }
}