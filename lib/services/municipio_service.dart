import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

class MunicipioService {
  late final ApiService _apiService;
  late final AuthService _authService;

  MunicipioService() {
    _apiService = ApiService(); // Usar el singleton
    _authService = AuthService();
  }

  /// Asegurar que el usuario esté autenticado antes de hacer peticiones
  Future<void> _ensureAuthenticated() async {
    if (!_authService.isAuthenticated) {
      appLogger.info('MunicipioService: Usuario no autenticado, inicializando AuthService...');
      await _authService.initialize();
      
      if (!_authService.isAuthenticated) {
        throw Exception('Usuario no autenticado. Por favor, inicie sesión.');
      }
    }
  }

  // Obtener todos los municipios
  Future<List<dynamic>> getAllMunicipios() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo todos los municipios');
      
      final response = await _apiService.get('/municipios');
      
      // La respuesta del backend tiene formato { success: true, data: [...] }
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          final municipios = responseMap['data'] as List<dynamic>;
          appLogger.info('MunicipioService: ${municipios.length} municipios obtenidos exitosamente');
          return municipios;
        }
      }
      
      // Si no tiene el formato esperado, asumir que es una lista directa
      if (response.data is List<dynamic>) {
        final municipios = response.data as List<dynamic>;
        appLogger.info('MunicipioService: ${municipios.length} municipios obtenidos (formato directo)');
        return municipios;
      }
      
      throw Exception('Formato de respuesta inesperado');
    } catch (e) {
      appLogger.error('Error obteniendo municipios desde API', error: e);
      
      // Fallback temporal con municipios reales de Bolívar
      appLogger.info('MunicipioService: Usando fallback con municipios de Bolívar');
      return _getMunicipiosFallback();
    }
  }

  // Fallback temporal con municipios reales de Bolívar
  List<dynamic> _getMunicipiosFallback() {
    return [
      {'id': '13001', 'nombre': 'CARTAGENA DE INDIAS', 'departamento': 'BOLÍVAR'},
      {'id': '13430', 'nombre': 'MAGANGUÉ', 'departamento': 'BOLÍVAR'},
      {'id': '13244', 'nombre': 'EL CARMEN DE BOLÍVAR', 'departamento': 'BOLÍVAR'},
      {'id': '13836', 'nombre': 'TURBACO', 'departamento': 'BOLÍVAR'},
      {'id': '13052', 'nombre': 'ARJONA', 'departamento': 'BOLÍVAR'},
      {'id': '13442', 'nombre': 'MARÍA LA BAJA', 'departamento': 'BOLÍVAR'},
      {'id': '13433', 'nombre': 'MAHATES', 'departamento': 'BOLÍVAR'},
      {'id': '13468', 'nombre': 'SANTA CRUZ DE MOMPOX', 'departamento': 'BOLÍVAR'},
      {'id': '13657', 'nombre': 'SAN JUAN NEPOMUCENO', 'departamento': 'BOLÍVAR'},
      {'id': '13654', 'nombre': 'SAN JACINTO', 'departamento': 'BOLÍVAR'},
      {'id': '13140', 'nombre': 'CALAMAR', 'departamento': 'BOLÍVAR'},
      {'id': '13222', 'nombre': 'CLEMENCIA', 'departamento': 'BOLÍVAR'},
      {'id': '13760', 'nombre': 'SOPLAVIENTO', 'departamento': 'BOLÍVAR'},
      {'id': '13838', 'nombre': 'TURBANÁ', 'departamento': 'BOLÍVAR'},
      {'id': '13873', 'nombre': 'VILLANUEVA', 'departamento': 'BOLÍVAR'},
      {'id': '13006', 'nombre': 'ACHÍ', 'departamento': 'BOLÍVAR'},
      {'id': '13030', 'nombre': 'ALTOS DEL ROSARIO', 'departamento': 'BOLÍVAR'},
      {'id': '13042', 'nombre': 'ARENAL', 'departamento': 'BOLÍVAR'},
      {'id': '13062', 'nombre': 'ARROYOHONDO', 'departamento': 'BOLÍVAR'},
      {'id': '13074', 'nombre': 'BARRANCO DE LOBA', 'departamento': 'BOLÍVAR'},
    ];
  }

  // Obtener municipio por ID
  Future<Map<String, dynamic>> getMunicipioById(String id) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo municipio por ID: $id');
      
      final response = await _apiService.get('/municipios/$id');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'] as Map<String, dynamic>;
        }
      }
      
      // Si no tiene el formato esperado, asumir que es el objeto directo
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo municipio por ID', error: e);
      rethrow;
    }
  }

  // Buscar municipios por nombre
  Future<List<dynamic>> searchMunicipios(String query) async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Buscando municipios con query: $query');
      
      final response = await _apiService.get('/municipios?search=$query');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'] as List<dynamic>;
        }
      }
      
      if (response.data is List<dynamic>) {
        return response.data as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      appLogger.error('Error buscando municipios', error: e);
      rethrow;
    }
  }

  // Obtener municipios del departamento de Bolívar
  Future<List<dynamic>> getMunicipiosBolivar() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo municipios de Bolívar');
      
      final response = await _apiService.get('/municipios?departamento=BOLÍVAR');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'] as List<dynamic>;
        }
      }
      
      if (response.data is List<dynamic>) {
        return response.data as List<dynamic>;
      }
      
      return [];
    } catch (e) {
      appLogger.error('Error obteniendo municipios de Bolívar', error: e);
      rethrow;
    }
  }

  // Obtener estadísticas de municipios
  Future<Map<String, dynamic>> getMunicipiosStats() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo estadísticas de municipios');
      
      final response = await _apiService.get('/municipios/stats');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'] as Map<String, dynamic>;
        }
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas de municipios', error: e);
      rethrow;
    }
  }
}

