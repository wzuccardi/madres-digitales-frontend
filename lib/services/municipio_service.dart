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

  /// Asegurar que el usuario estÃ© autenticado antes de hacer peticiones
  Future<void> _ensureAuthenticated() async {
    if (!_authService.isAuthenticated) {
      appLogger.info('MunicipioService: Usuario no autenticado, inicializando AuthService...');
      await _authService.initialize();
      
      if (!_authService.isAuthenticated) {
        throw Exception('Usuario no autenticado. Por favor, inicie sesiÃ³n.');
      }
    }
  }

  // Obtener todos los municipios
  Future<List<dynamic>> getAllMunicipios() async {
    try {
      // No requiere autenticación para municipios
      appLogger.info('MunicipioService: Obteniendo todos los municipios desde API');
      final response = await _apiService.get('/municipios');
      
      List<dynamic> municipiosData;
      if (response.data is Map<String, dynamic>) {
        // La respuesta tiene la estructura {success: true, data: [...]}
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          municipiosData = responseMap['data'] as List<dynamic>;
        } else {
          throw Exception('Respuesta invÃ¡lida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
        }
      } else if (response.data is List<dynamic>) {
        // La respuesta es directamente una lista
        municipiosData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inesperado: ${response.data.runtimeType}');
      }
      
      appLogger.info('MunicipioService: ${municipiosData.length} municipios obtenidos desde API');
      return municipiosData;
    } catch (e) {
      appLogger.error('Error obteniendo municipios desde API', error: e);
      
      // Fallback temporal con municipios reales de BolÃ­var
      appLogger.info('MunicipioService: Usando fallback con municipios de BolÃ­var');
      return _getMunicipiosFallback();
    }
  }

  // Fallback temporal con municipios reales de BolÃ­var
  List<dynamic> _getMunicipiosFallback() {
    return [
      {'id': '13001', 'nombre': 'CARTAGENA DE INDIAS', 'departamento': 'BOLÃVAR'},
      {'id': '13430', 'nombre': 'MAGANGUÃ‰', 'departamento': 'BOLÃVAR'},
      {'id': '13244', 'nombre': 'EL CARMEN DE BOLÃVAR', 'departamento': 'BOLÃVAR'},
      {'id': '13836', 'nombre': 'TURBACO', 'departamento': 'BOLÃVAR'},
      {'id': '13052', 'nombre': 'ARJONA', 'departamento': 'BOLÃVAR'},
      {'id': '13442', 'nombre': 'MARÃA LA BAJA', 'departamento': 'BOLÃVAR'},
      {'id': '13433', 'nombre': 'MAHATES', 'departamento': 'BOLÃVAR'},
      {'id': '13468', 'nombre': 'SANTA CRUZ DE MOMPOX', 'departamento': 'BOLÃVAR'},
      {'id': '13657', 'nombre': 'SAN JUAN NEPOMUCENO', 'departamento': 'BOLÃVAR'},
      {'id': '13654', 'nombre': 'SAN JACINTO', 'departamento': 'BOLÃVAR'},
      {'id': '13140', 'nombre': 'CALAMAR', 'departamento': 'BOLÃVAR'},
      {'id': '13222', 'nombre': 'CLEMENCIA', 'departamento': 'BOLÃVAR'},
      {'id': '13760', 'nombre': 'SOPLAVIENTO', 'departamento': 'BOLÃVAR'},
      {'id': '13838', 'nombre': 'TURBANÃ', 'departamento': 'BOLÃVAR'},
      {'id': '13873', 'nombre': 'VILLANUEVA', 'departamento': 'BOLÃVAR'},
      {'id': '13006', 'nombre': 'ACHÃ', 'departamento': 'BOLÃVAR'},
      {'id': '13030', 'nombre': 'ALTOS DEL ROSARIO', 'departamento': 'BOLÃVAR'},
      {'id': '13042', 'nombre': 'ARENAL', 'departamento': 'BOLÃVAR'},
      {'id': '13062', 'nombre': 'ARROYOHONDO', 'departamento': 'BOLÃVAR'},
      {'id': '13074', 'nombre': 'BARRANCO DE LOBA', 'departamento': 'BOLÃVAR'},
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

  // Obtener municipios del departamento de BolÃ­var
  Future<List<dynamic>> getMunicipiosBolivar() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo municipios de BolÃ­var');
      
      final response = await _apiService.get('/municipios?departamento=BOLÃVAR');
      
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
      appLogger.error('Error obteniendo municipios de BolÃ­var', error: e);
      rethrow;
    }
  }

  // Obtener estadÃ­sticas de municipios
  Future<Map<String, dynamic>> getMunicipiosStats() async {
    try {
      await _ensureAuthenticated();
      appLogger.info('MunicipioService: Obteniendo estadÃ­sticas de municipios');
      
      final response = await _apiService.get('/municipios/stats');
      
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;
        if (responseMap['success'] == true && responseMap['data'] != null) {
          return responseMap['data'] as Map<String, dynamic>;
        }
      }
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo estadÃ­sticas de municipios', error: e);
      rethrow;
    }
  }
}


