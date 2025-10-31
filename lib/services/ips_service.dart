import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class IPSService {
  final ApiService _apiService;

  IPSService(this._apiService);

  Future<List<dynamic>> obtenerTodasLasIPS() async {
    try {
      appLogger.info('IPSService: Obteniendo todas las IPS');
      final response = await _apiService.get('/ips');

      List<dynamic> ipsData;
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        // Estructura: { success: true, data: { ips: [...], total: ... } }
        if (responseMap['data'] is Map && responseMap['data']['ips'] != null) {
          ipsData = responseMap['data']['ips'] as List<dynamic>;
        }
        // Estructura: { success: true, data: [...] }
        else if (responseMap['success'] == true && responseMap['data'] is List) {
          ipsData = responseMap['data'] as List<dynamic>;
        } else {
          throw Exception('Respuesta inválida del servidor: ${responseMap['error'] ?? 'Error desconocido'}');
        }
      } else if (response.data is List) {
        // La respuesta es directamente una lista
        ipsData = response.data as List<dynamic>;
      } else {
        throw Exception('Formato de respuesta inválido para IPS');
      }
      
      return ipsData;
    } catch (e) {
      appLogger.error('Error obteniendo todas las IPS', error: e);
      rethrow;
    }
  }

  Future<dynamic> obtenerIPSPorId(String id) async {
    try {
      appLogger.info('IPSService: Obteniendo IPS por ID: $id');
      final response = await _apiService.get('/ips/$id');
      return response.data;
    } catch (e) {
      appLogger.error('Error obteniendo IPS por ID', error: e);
      return null;
    }
  }

  Future<dynamic> crearIPS(Map<String, dynamic> data) async {
    try {
      appLogger.info('IPSService: Creando nueva IPS');
      // CORREGIDO: Usar el endpoint correcto que implementamos
      final response = await _apiService.post('/ips', data: data);
      return response.data;
    } catch (e) {
      appLogger.error('Error creando IPS', error: e);
      rethrow;
    }
  }

  Future<dynamic> actualizarIPS(String id, Map<String, dynamic> data) async {
    try {
      appLogger.info('IPSService: Actualizando IPS: $id');
      // CORREGIDO: Usar el endpoint correcto que implementamos
      final response = await _apiService.put('/ips/$id', data: data);
      return response.data;
    } catch (e) {
      appLogger.error('Error actualizando IPS', error: e);
      rethrow;
    }
  }

  Future<void> eliminarIPS(String id) async {
    try {
      appLogger.info('IPSService: Eliminando IPS: $id');
      // Usar el endpoint CRUD que tiene mejor implementaciÃ³n
      await _apiService.delete('/ips-crud/$id');
    } catch (e) {
      appLogger.error('Error eliminando IPS', error: e);
      rethrow;
    }
  }

  // Nuevo método para obtener municipios
  Future<List<dynamic>> obtenerMunicipios() async {
    try {
      appLogger.info('IPSService: Obteniendo municipios');
      final response = await _apiService.get('/municipios');

      // Manejar estructura de respuesta del backend: { success: true, data: [...] }
      List<dynamic> municipiosData = [];
      if (response.data is Map && response.data['data'] != null) {
        final dataValue = response.data['data'];
        if (dataValue is List) {
          municipiosData = dataValue;
        }
      } else if (response.data is List) {
        municipiosData = response.data;
      }

      return municipiosData;
    } catch (e) {
      appLogger.error('Error obteniendo municipios', error: e);
      rethrow;
    }
  }
}
