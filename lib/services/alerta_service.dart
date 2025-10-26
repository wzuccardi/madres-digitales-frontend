import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/gestante_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class Municipio {
  final String id;
  final String nombre;

  Municipio({required this.id, required this.nombre});

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }
}

class Madrina {
  final String id;
  final String nombre;

  Madrina({required this.id, required this.nombre});

  factory Madrina.fromJson(Map<String, dynamic> json) {
    return Madrina(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
    );
  }
}

class Alerta {
  final String id;
  final String gestanteId;
  final String? madrinaId;
  final String tipoAlerta;
  final String nivelPrioridad;
  final String mensaje;
  final List<String> sintomas;
  final bool resuelta;
  final DateTime? fechaResolucion;
  final String? generadoPorId;
  final String estado;
  final String? descripcionDetallada;
  final int? scoreRiesgo;
  final bool esAutomatica;
  final Map<String, dynamic>? signosVitales;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final Gestante? gestante;
  final Madrina? madrina;

  Alerta({
    required this.id,
    required this.gestanteId,
    this.madrinaId,
    required this.tipoAlerta,
    required this.nivelPrioridad,
    required this.mensaje,
    this.sintomas = const [],
    this.resuelta = false,
    this.fechaResolucion,
    this.generadoPorId,
    this.estado = 'pendiente',
    this.descripcionDetallada,
    this.scoreRiesgo,
    this.esAutomatica = false,
    this.signosVitales,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.gestante,
    this.madrina,
  });

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'] ?? '',
      gestanteId: json['gestante_id'] ?? '',
      madrinaId: json['madrina_id'],
      tipoAlerta: json['tipo_alerta'] ?? '',
      nivelPrioridad: json['nivel_prioridad'] ?? 'baja',
      mensaje: json['mensaje'] ?? '',
      sintomas: json['sintomas'] != null ? List<String>.from(json['sintomas']) : [],
      resuelta: json['resuelta'] ?? false,
      fechaResolucion: json['fecha_resolucion'] != null 
          ? DateTime.parse(json['fecha_resolucion']) 
          : null,
      generadoPorId: json['generado_por_id'],
      estado: json['estado'] ?? 'pendiente',
      descripcionDetallada: json['descripcion_detallada'],
      scoreRiesgo: json['score_riesgo'],
      esAutomatica: json['es_automatica'] ?? false,
      signosVitales: json['signos_vitales'],
      fechaCreacion: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : DateTime.now(),
      fechaActualizacion: json['fecha_actualizacion'] != null 
          ? DateTime.parse(json['fecha_actualizacion']) 
          : DateTime.now(),
      gestante: json['gestante'] != null ? Gestante.fromJson(json['gestante']) : null,
      madrina: json['madrina'] != null ? Madrina.fromJson(json['madrina']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestanteId,
      'madrina_id': madrinaId,
      'tipo_alerta': tipoAlerta,
      'nivel_prioridad': nivelPrioridad,
      'mensaje': mensaje,
      'sintomas': sintomas,
      'resuelta': resuelta,
      'fecha_resolucion': fechaResolucion?.toIso8601String(),
      'generado_por_id': generadoPorId,
      'estado': estado,
      'descripcion_detallada': descripcionDetallada,
      'score_riesgo': scoreRiesgo,
      'es_automatica': esAutomatica,
      'signos_vitales': signosVitales,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  // Getters útiles
  bool get esCritica => nivelPrioridad == 'critica';
  bool get esAlta => nivelPrioridad == 'alta';
  bool get esPendiente => estado == 'pendiente';
  
  String get prioridadTexto {
    switch (nivelPrioridad) {
      case 'critica': return 'CRÍTICA';
      case 'alta': return 'ALTA';
      case 'media': return 'MEDIA';
      case 'baja': return 'BAJA';
      default: return 'DESCONOCIDA';
    }
  }

  String get tipoTexto {
    switch (tipoAlerta) {
      case 'emergencia_obstetrica': return 'Emergencia Obstétrica';
      case 'hipertension': return 'Hipertensión';
      case 'preeclampsia': return 'Preeclampsia';
      case 'sepsis': return 'Sepsis Materna';
      case 'hemorragia': return 'Hemorragia';
      case 'shock_hipovolemico': return 'Shock Hipovolémico';
      case 'parto_prematuro': return 'Parto Prematuro';
      case 'manual': return 'Alerta Manual';
      default: return tipoAlerta;
    }
  }
}

class AlertaService {
  final ApiService _apiService;
  final GestanteService? _gestanteService;

  AlertaService(this._apiService, [this._gestanteService]);

  Future<List<Alerta>> obtenerAlertas({
    String? nivelPrioridad,
    String? tipoAlerta,
    String? estado,
    bool? esAutomatica,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      appLogger.info('AlertaService: Obteniendo alertas filtradas');
      
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (nivelPrioridad != null) queryParams['nivel_prioridad'] = nivelPrioridad;
      if (tipoAlerta != null) queryParams['tipo_alerta'] = tipoAlerta;
      if (estado != null) queryParams['estado'] = estado;
      if (esAutomatica != null) queryParams['es_automatica'] = esAutomatica.toString();
      if (fechaDesde != null) queryParams['fecha_desde'] = fechaDesde.toIso8601String();
      if (fechaHasta != null) queryParams['fecha_hasta'] = fechaHasta.toIso8601String();
      
      String url = '/alertas-automaticas/alertas';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        url += '?$queryString';
      }
      final response = await _apiService.get(url);
      
      if (response.data['success'] == true) {
        final List<dynamic> alertasData = response.data['data']['alertas'] as List<dynamic>;
        
        // Si tenemos un servicio de gestantes, obtener los datos completos
        if (_gestanteService != null) {
          final alertas = <Alerta>[];
          final gestantesMap = <String, Gestante>{};
          
          // Primero obtener todas las gestantes para minimizar llamadas
          try {
            final gestantes = await _gestanteService!.obtenerGestantes();
            for (final gestante in gestantes) {
              gestantesMap[gestante.id] = gestante;
            }
          } catch (e) {
            appLogger.info('No se pudieron cargar las gestantes para alertas: $e');
          }
          
          // Luego procesar las alertas con los datos de gestantes
          for (final data in alertasData) {
            final alertaData = Map<String, dynamic>.from(data);
            final gestanteId = alertaData['gestante_id']?.toString();
            
            if (gestanteId != null && gestantesMap.containsKey(gestanteId)) {
              alertaData['gestante'] = gestantesMap[gestanteId]!.toJson();
            }
            
            alertas.add(Alerta.fromJson(alertaData));
          }
          
          return alertas;
        }
        
        // Si no hay servicio de gestantes, retornar las alertas sin datos adicionales
        return alertasData.map((data) => Alerta.fromJson(data)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Error obteniendo alertas');
      }
    } catch (e) {
      appLogger.error('Error obteniendo alertas', error: e);
      rethrow;
    }
  }

  Future<Alerta?> obtenerAlertaPorId(String id) async {
    try {
      appLogger.info('AlertaService: Obteniendo alerta por ID: $id');
      final response = await _apiService.get('/alertas/$id');
      return Alerta.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      appLogger.error('Error obteniendo alerta por ID', error: e, context: {
        'id': id,
      });
      return null;
    }
  }

  Future<Alerta> crearAlerta({
    required String gestanteId,
    required String tipoAlerta,
    required String nivelPrioridad,
    required String mensaje,
    List<String>? sintomas,
    String? descripcionDetallada,
    List<double>? coordenadas,
  }) async {
    try {
      appLogger.info('AlertaService: Creando alerta manual');
      
      final alertaData = {
        'gestante_id': gestanteId,
        'tipo_alerta': tipoAlerta,
        'nivel_prioridad': nivelPrioridad,
        'mensaje': mensaje,
        'sintomas': sintomas ?? [],
        'descripcion_detallada': descripcionDetallada,
        'es_automatica': false,
      };
      
      if (coordenadas != null && coordenadas.length == 2) {
        alertaData['coordenadas_alerta'] = coordenadas;
      }
      
      final response = await _apiService.post('/alertas', data: alertaData);
      
      if (response.data['success'] == true) {
        return Alerta.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['error'] ?? 'Error creando alerta');
      }
    } catch (e) {
      appLogger.error('Error creando alerta', error: e);
      rethrow;
    }
  }

  Future<Alerta> actualizarAlerta(String id, Map<String, dynamic> alertaData) async {
    try {
      appLogger.info('AlertaService: Actualizando alerta', context: {
        'id': id,
      });
      final response = await _apiService.put('/alertas/$id', data: alertaData);
      return Alerta.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      appLogger.error('Error actualizando alerta', error: e, context: {
        'id': id,
      });
      rethrow;
    }
  }

  Future<bool> resolverAlerta(String id) async {
    try {
      appLogger.info('AlertaService: Resolviendo alerta', context: {'id': id});
      final response = await _apiService.put('/alertas/$id/resolver');
      return response.data['success'] == true;
    } catch (e) {
      appLogger.error('Error resolviendo alerta', error: e, context: {'id': id});
      rethrow;
    }
  }

  Future<List<Gestante>> obtenerGestantesDisponibles() async {
    try {
      appLogger.info('AlertaService: Obteniendo gestantes disponibles para alertas');
      
      // Si tenemos un servicio de gestantes, usarlo directamente
      if (_gestanteService != null) {
        final gestantes = await _gestanteService!.obtenerGestantes();
        return gestantes.where((g) => g.activa).toList();
      }
      
      // Si no, usar el endpoint específico
      final response = await _apiService.get('/gestantes/disponibles-para-alertas');
      
      if (response.data['success'] == true) {
        final List<dynamic> gestantesData = response.data['data'] as List<dynamic>;
        return gestantesData.map((data) => Gestante.fromJson(data)).toList();
      } else {
        throw Exception(response.data['error'] ?? 'Error obteniendo gestantes');
      }
    } catch (e) {
      appLogger.error('Error obteniendo gestantes disponibles', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> evaluarSignosVitales({
    double? presionSistolica,
    double? presionDiastolica,
    double? frecuenciaCardiaca,
    double? frecuenciaRespiratoria,
    double? temperatura,
    int? semanasGestacion,
    List<String>? sintomas,
  }) async {
    try {
      appLogger.info('AlertaService: Evaluando signos vitales');
      
      final data = <String, dynamic>{};
      if (presionSistolica != null) data['presion_sistolica'] = presionSistolica;
      if (presionDiastolica != null) data['presion_diastolica'] = presionDiastolica;
      if (frecuenciaCardiaca != null) data['frecuencia_cardiaca'] = frecuenciaCardiaca;
      if (frecuenciaRespiratoria != null) data['frecuencia_respiratoria'] = frecuenciaRespiratoria;
      if (temperatura != null) data['temperatura'] = temperatura;
      if (semanasGestacion != null) data['semanas_gestacion'] = semanasGestacion;
      if (sintomas != null) data['sintomas'] = sintomas;
      
      final response = await _apiService.post('/alertas-automaticas/evaluar-signos-vitales', data: data);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['error'] ?? 'Error evaluando signos vitales');
      }
    } catch (e) {
      appLogger.error('Error evaluando signos vitales', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> obtenerEstadisticasAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      appLogger.info('AlertaService: Obteniendo estadísticas de alertas');
      
      final queryParams = <String, dynamic>{};
      if (fechaInicio != null) queryParams['fecha_inicio'] = fechaInicio.toIso8601String();
      if (fechaFin != null) queryParams['fecha_fin'] = fechaFin.toIso8601String();
      
      String url = '/alertas-automaticas/stats';
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
        url += '?$queryString';
      }
      final response = await _apiService.get(url);
      
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['error'] ?? 'Error obteniendo estadísticas');
      }
    } catch (e) {
      appLogger.error('Error obteniendo estadísticas de alertas', error: e);
      rethrow;
    }
  }

  // Constantes para tipos de alerta
  static const List<String> tiposAlerta = [
    'manual',
    'emergencia_obstetrica',
    'hipertension',
    'preeclampsia',
    'sepsis',
    'hemorragia',
    'shock_hipovolemico',
    'parto_prematuro',
  ];

  static const List<String> nivelesPrioridad = [
    'baja',
    'media',
    'alta',
    'critica',
  ];

  static const List<String> sintomasComunes = [
    'dolor_cabeza_severo',
    'vision_borrosa',
    'dolor_epigastrico',
    'nauseas_vomitos_severos',
    'edema_facial',
    'edema_manos',
    'sangrado_vaginal_abundante',
    'contracciones_regulares',
    'dolor_abdominal_intenso',
    'fiebre',
    'escalofrios',
    'malestar_general',
    'confusion_mental',
    'ausencia_movimiento_fetal',
    'disminucion_movimientos_fetales',
    'ruptura_membranas',
    'presion_pelvica',
    'mareo',
    'debilidad',
  ];

  Future<bool> eliminarAlerta(String id) async {
    try {
      appLogger.info('AlertaService: Eliminando alerta', context: {
        'id': id,
      });
      await _apiService.delete('/alertas/$id');
      return true;
    } catch (e) {
      appLogger.error('Error eliminando alerta', error: e, context: {
        'id': id,
      });
      return false;
    }
  }

  Future<bool> marcarComoLeida(String id) async {
    try {
      appLogger.info('AlertaService: Marcando alerta como leída', context: {
        'id': id,
      });
      // Marcar alerta como leída
      final response = await _apiService.put('/alertas/$id', data: {'leida': true});
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['success'] == true;
      }
      return responseData != null;
    } catch (e) {
      appLogger.error('Error marcando alerta como leída', error: e, context: {
        'id': id,
      });
      rethrow;
    }
  }

  Future<Map<String, dynamic>> enviarAlertaSOS({required String gestanteId, required String motivo}) async {
    try {
      appLogger.info('AlertaService: Enviando alerta SOS para gestante: $gestanteId');
      final response = await _apiService.post('/alertas/sos', data: {
        'gestanteId': gestanteId,
        'motivo': motivo,
        'timestamp': DateTime.now().toIso8601String(),
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      appLogger.error('Error enviando alerta SOS', error: e, context: {
        'gestanteId': gestanteId,
        'motivo': motivo,
      });
      rethrow;
    }
  }
}