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
    // DEBUG: Analizar la estructura del JSON recibido
    appLogger.info('Gestante.fromJson DEBUG: Analizando JSON', error: {
      'jsonType': json.runtimeType.toString(),
      'jsonKeys': json.keys.toList(),
      'json': json,
    });

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

      // DEBUG: Analizar la estructura de la respuesta
      appLogger.info('GestanteService DEBUG: Estructura de respuesta', error: {
        'responseDataType': response.data.runtimeType.toString(),
        'responseData': response.data,
        'isMap': response.data is Map,
        'isList': response.data is List,
      });

      List<dynamic> gestantesData;
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // DEBUG: Analizar la estructura del data
        appLogger.info('GestanteService DEBUG: Estructura de responseData', error: {
          'responseData': responseData,
          'dataType': responseData['data']?.runtimeType.toString(),
          'dataValue': responseData['data'],
        });

        // Estructura: { success: true, data: { gestantes: [...], total: ... } }
        if (responseData['data'] is Map && responseData['data']['gestantes'] != null) {
          final gestantesValue = responseData['data']['gestantes'];

          // DEBUG: Analizar el valor de gestantes
          appLogger.info('GestanteService DEBUG: Estructura de gestantes', error: {
            'gestantesValueType': gestantesValue.runtimeType.toString(),
            'gestantesValue': gestantesValue,
          });

          if (gestantesValue is List) {
            gestantesData = gestantesValue;
          } else {
            appLogger.error('GestanteService: gestantes NO es una lista', error: {
              'type': gestantesValue.runtimeType.toString(),
              'value': gestantesValue,
            });
            gestantesData = [];
          }
        }
        // Estructura: { data: [...] }
        else if (responseData['data'] is List) {
          gestantesData = responseData['data'] as List<dynamic>;
        } else {
          gestantesData = [];
        }
      } else if (response.data is List) {
        // La respuesta es directamente una lista
        gestantesData = response.data as List<dynamic>;
      } else {
        appLogger.error('GestanteService: Tipo de respuesta inesperado', error: {
          'type': response.data.runtimeType.toString(),
          'data': response.data,
        });
        gestantesData = [];
      }

      final gestantes = gestantesData.map((data) {
        return Gestante.fromJson(data);
      }).toList();

      appLogger.info('GestanteService: ${gestantes.length} gestantes cargadas');
      return gestantes;
    } catch (e) {
      appLogger.error('Error obteniendo gestantes', error: e);
      rethrow;
    }
  }

  Future<Gestante?> obtenerGestantePorId(String id) async {
    try {
      appLogger.info('GestanteService: Obteniendo gestante por ID: $id');
      final response = await _apiService.get('/gestantes/$id');
      return Gestante.fromJson(response.data);  // CorrecciÃ³n: Acceder a data de Response
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
      final response = await _apiService.post('/gestantes', data: gestanteData);  // CorrecciÃ³n: Usar parÃ¡metro named
      return Gestante.fromJson(response.data);  // CorrecciÃ³n: Acceder a data de Response
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
      final response = await _apiService.put('/gestantes/$id', data: gestanteData);  // CorrecciÃ³n: Usar parÃ¡metro named
      return Gestante.fromJson(response.data);  // CorrecciÃ³n: Acceder a data de Response
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
