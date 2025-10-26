import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class IPSService {
  final ApiService _apiService;

  IPSService(this._apiService);

  Future<List<dynamic>> obtenerTodasLasIPS() async {
    try {
      appLogger.info('IPSService: Obteniendo todas las IPS');
      final response = await _apiService.get('/ips');
      return response.data as List<dynamic>;
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
      // Usar el endpoint CRUD que tiene mejor implementación
      final response = await _apiService.post('/ips-crud', data: data);
      return response.data;
    } catch (e) {
      appLogger.error('Error creando IPS', error: e);
      rethrow;
    }
  }

  Future<dynamic> actualizarIPS(String id, Map<String, dynamic> data) async {
    try {
      appLogger.info('IPSService: Actualizando IPS: $id');
      // Usar el endpoint CRUD que tiene mejor implementación
      final response = await _apiService.put('/ips-crud/$id', data: data);
      return response.data;
    } catch (e) {
      appLogger.error('Error actualizando IPS', error: e);
      rethrow;
    }
  }

  Future<void> eliminarIPS(String id) async {
    try {
      appLogger.info('IPSService: Eliminando IPS: $id');
      // Usar el endpoint CRUD que tiene mejor implementación
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
      return response.data as List<dynamic>;
    } catch (e) {
      appLogger.error('Error obteniendo municipios', error: e);
      rethrow;
    }
  }
}