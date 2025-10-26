import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class Gestante {
  final String id;
  final String documento;
  final String nombre;
  final String? telefono;
  final DateTime? fecha_nacimiento;
  final DateTime? fecha_ultima_menstruacion;
  final DateTime? fecha_probable_parto;
  final String? eps;
  final String? regimen_salud;
  final String? municipio_id;
  final String? madrina_id;
  final bool activa;
  final bool riesgo_alto;

  Gestante({
    required this.id,
    required this.documento,
    required this.nombre,
    this.telefono,
    this.fecha_nacimiento,
    this.fecha_ultima_menstruacion,
    this.fecha_probable_parto,
    this.eps,
    this.regimen_salud,
    this.municipio_id,
    this.madrina_id,
    this.activa = true,
    this.riesgo_alto = false,
  });

  factory Gestante.fromJson(Map<String, dynamic> json) {
    print('🔍 Gestante.fromJson: Procesando JSON con claves: ${json.keys.toList()}');
    return Gestante(
      id: json['id']?.toString() ?? '',
      documento: json['documento']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      fecha_nacimiento: json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento'].toString())
          : null,
      fecha_ultima_menstruacion: json['fecha_ultima_menstruacion'] != null
          ? DateTime.tryParse(json['fecha_ultima_menstruacion'].toString())
          : null,
      fecha_probable_parto: json['fecha_probable_parto'] != null
          ? DateTime.tryParse(json['fecha_probable_parto'].toString())
          : null,
      eps: json['eps']?.toString(),
      regimen_salud: json['regimen_salud']?.toString(),
      municipio_id: json['municipio_id']?.toString(),
      madrina_id: json['madrina_id']?.toString(),
      activa: json['activa'] ?? true,
      riesgo_alto: json['riesgo_alto'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'documento': documento,
      'nombre': nombre,
      'telefono': telefono,
      'fecha_nacimiento': fecha_nacimiento?.toIso8601String(),
      'fecha_ultima_menstruacion': fecha_ultima_menstruacion?.toIso8601String(),
      'fecha_probable_parto': fecha_probable_parto?.toIso8601String(),
      'eps': eps,
      'regimen_salud': regimen_salud,
      'municipio_id': municipio_id,
      'madrina_id': madrina_id,
      'activa': activa,
      'riesgo_alto': riesgo_alto,
    };
  }
}

class GestanteService {
  final ApiService _apiService;

  GestanteService(this._apiService);

  Future<List<Gestante>> obtenerGestantes() async {
    try {
      appLogger.info('GestanteService: Obteniendo gestantes');
      final response = await _apiService.get('/gestantes');
      print('🔍 GestanteService: Respuesta recibida - Tipo: ${response.data.runtimeType}');
      print('🔍 GestanteService: Respuesta recibida - Contenido: ${response.data}');
      
      List<dynamic> gestantesData;
      if (response.data is Map<String, dynamic>) {
        // La respuesta tiene la estructura {data: [...]}
        gestantesData = response.data['data'] as List<dynamic>;
        print('🔍 GestanteService: Extraída lista de gestantes de la clave "data": ${gestantesData.length} elementos');
      } else {
        // La respuesta es directamente una lista
        gestantesData = response.data as List<dynamic>;
        print('🔍 GestanteService: La respuesta es directamente una lista: ${gestantesData.length} elementos');
      }
      
      final gestantes = gestantesData.map((data) {
        print('🔍 GestanteService: Procesando gestante: $data');
        return Gestante.fromJson(data);
      }).toList();
      print('🔍 GestanteService: ${gestantes.length} gestantes procesadas correctamente');
      return gestantes;
    } catch (e, stackTrace) {
      print('❌ GestanteService: Error obteniendo gestantes: $e');
      print('❌ GestanteService: Tipo de error: ${e.runtimeType}');
      print('❌ GestanteService: Stack trace: $stackTrace');
      appLogger.error('Error obteniendo gestantes', error: e);
      rethrow;
    }
  }

  Future<Gestante?> obtenerGestantePorId(String id) async {
    try {
      appLogger.info('GestanteService: Obteniendo gestante por ID: $id');
      final response = await _apiService.get('/gestantes/$id');
      return Gestante.fromJson(response.data);  // Corrección: Acceder a data de Response
    } catch (e) {
      appLogger.error('Error obteniendo gestante por ID', error: e, context: {
        'id': id,
      });
      return null;
    }
  }

  Future<Gestante> crearGestante(Map<String, dynamic> gestanteData) async {
    try {
      appLogger.info('GestanteService: Creando gestante');
      final response = await _apiService.post('/gestantes', data: gestanteData);  // Corrección: Usar parámetro named
      return Gestante.fromJson(response.data);  // Corrección: Acceder a data de Response
    } catch (e) {
      appLogger.error('Error creando gestante', error: e);
      rethrow;
    }
  }

  Future<Gestante> actualizarGestante(String id, Map<String, dynamic> gestanteData) async {
    try {
      appLogger.info('GestanteService: Actualizando gestante', context: {
        'id': id,
      });
      final response = await _apiService.put('/gestantes/$id', data: gestanteData);  // Corrección: Usar parámetro named
      return Gestante.fromJson(response.data);  // Corrección: Acceder a data de Response
    } catch (e) {
      appLogger.error('Error actualizando gestante', error: e, context: {
        'id': id,
      });
      rethrow;
    }
  }

  Future<bool> eliminarGestante(String id) async {
    try {
      appLogger.info('GestanteService: Eliminando gestante', context: {
        'id': id,
      });
      await _apiService.delete('/gestantes/$id');
      return true;
    } catch (e) {
      appLogger.error('Error eliminando gestante', error: e, context: {
        'id': id,
      });
      return false;
    }
  }
}