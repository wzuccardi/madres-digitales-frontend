import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/services/gestante_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

class Control {
  final String id;
  final String gestanteId;
  final String? gestanteNombre; // Para compatibilidad con UI existente
  final Gestante? gestante; // Datos completos de la gestante
  final String? medicoId;
  final DateTime fechaControl;
  final int? semanasGestacion;
  final double? peso;
  final double? alturaUterina;
  final int? presionSistolica;
  final int? presionDiastolica;
  final int? frecuenciaCardiaca;
  final int? frecuenciaRespiratoria;
  final double? temperatura;
  final String? movimientosFetales;
  final String? edemas;
  final String? proteinuria;
  final String? glucosuria;
  final Map<String, dynamic>? hallazgos;
  final String? recomendaciones;
  final DateTime? proximoControl;
  final bool realizado;
  final String? observaciones;
  final Map<String, dynamic>? examenesSolicitados;
  final Map<String, dynamic>? resultadosExamenes;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  Control({
    required this.id,
    required this.gestanteId,
    this.gestanteNombre,
    this.gestante,
    this.medicoId,
    required this.fechaControl,
    this.semanasGestacion,
    this.peso,
    this.alturaUterina,
    this.presionSistolica,
    this.presionDiastolica,
    this.frecuenciaCardiaca,
    this.frecuenciaRespiratoria,
    this.temperatura,
    this.movimientosFetales,
    this.edemas,
    this.proteinuria,
    this.glucosuria,
    this.hallazgos,
    this.recomendaciones,
    this.proximoControl,
    this.realizado = false,
    this.observaciones,
    this.examenesSolicitados,
    this.resultadosExamenes,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory Control.fromJson(Map<String, dynamic> json) {
    return Control(
      id: json['id']?.toString() ?? '',
      gestanteId: json['gestante_id']?.toString() ?? '',
      gestanteNombre: json['gestante_nombre'] as String?, // Para compatibilidad
      gestante: json['gestante'] != null ? Gestante.fromJson(json['gestante']) : null,
      medicoId: json['medico_id'] as String?,
      fechaControl: json['fecha_control'] != null
          ? DateTime.parse(json['fecha_control'])
          : DateTime.now(),
      semanasGestacion: json['semanas_gestacion'] as int?,
      peso: _parseDouble(json['peso']),
      alturaUterina: _parseDouble(json['altura_uterina']),
      presionSistolica: json['presion_sistolica'] as int?,
      presionDiastolica: json['presion_diastolica'] as int?,
      frecuenciaCardiaca: json['frecuencia_cardiaca'] as int?,
      frecuenciaRespiratoria: json['frecuencia_respiratoria'] as int?,
      temperatura: _parseDouble(json['temperatura']),
      movimientosFetales: json['movimientos_fetales'] as String?,
      edemas: json['edemas'] as String?,
      proteinuria: json['proteinuria'] as String?,
      glucosuria: json['glucosuria'] as String?,
      hallazgos: json['hallazgos'] as Map<String, dynamic>?,
      recomendaciones: json['recomendaciones'] as String?,
      proximoControl: json['proximo_control'] != null
          ? DateTime.parse(json['proximo_control'])
          : null,
      realizado: json['realizado'] as bool? ?? false,
      observaciones: json['observaciones'] as String?,
      examenesSolicitados: json['examenes_solicitados'] as Map<String, dynamic>?,
      resultadosExamenes: json['resultados_examenes'] as Map<String, dynamic>?,
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gestante_id': gestanteId,
      'gestante_nombre': gestanteNombre, // Para compatibilidad
      'medico_id': medicoId,
      'fecha_control': fechaControl.toIso8601String(),
      'semanas_gestacion': semanasGestacion,
      'peso': peso,
      'altura_uterina': alturaUterina,
      'presion_sistolica': presionSistolica,
      'presion_diastolica': presionDiastolica,
      'frecuencia_cardiaca': frecuenciaCardiaca,
      'frecuencia_respiratoria': frecuenciaRespiratoria,
      'temperatura': temperatura,
      'movimientos_fetales': movimientosFetales,
      'edemas': edemas,
      'proteinuria': proteinuria,
      'glucosuria': glucosuria,
      'hallazgos': hallazgos,
      'recomendaciones': recomendaciones,
      'proximo_control': proximoControl?.toIso8601String(),
      'realizado': realizado,
      'observaciones': observaciones,
      'examenes_solicitados': examenesSolicitados,
      'resultados_examenes': resultadosExamenes,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // Getters para compatibilidad con código existente
  DateTime get fechaProgramada => fechaControl;
  String get gestanteNombreDisplay => gestanteNombre ?? 'Gestante';
  String get estado => 'realizado';
  String get tipo => 'prenatal';
}

class ControlService {
  final ApiService _apiService;
  final GestanteService? _gestanteService;

  ControlService(this._apiService, [this._gestanteService]);

  Future<List<Control>> obtenerControles() async {
    try {
      appLogger.info('ControlService: Obteniendo controles');
      final response = await _apiService.get('/controles');
      final List<dynamic> controlesData = response.data;  // Corrección: Acceder a data de Response
      
      // Si tenemos un servicio de gestantes, obtener los datos completos
      if (_gestanteService != null) {
        final controles = <Control>[];
        final gestantesMap = <String, Gestante>{};
        
        // Primero obtener todas las gestantes para minimizar llamadas
        try {
          final gestantes = await _gestanteService!.obtenerGestantes();
          for (final gestante in gestantes) {
            gestantesMap[gestante.id] = gestante;
          }
          appLogger.info('ControlService: Se cargaron ${gestantes.length} gestantes');
        } catch (e) {
          appLogger.info('No se pudieron cargar las gestantes: $e');
        }
        
        // Luego procesar los controles con los datos de gestantes
        for (final data in controlesData) {
          final controlData = Map<String, dynamic>.from(data);
          final gestanteId = controlData['gestante_id']?.toString();
          
          if (gestanteId != null && gestantesMap.containsKey(gestanteId)) {
            controlData['gestante'] = gestantesMap[gestanteId]!.toJson();
            controlData['gestante_nombre'] = gestantesMap[gestanteId]!.nombre;
            appLogger.info('ControlService: Asociando control ${controlData['id']} con gestante ${gestantesMap[gestanteId]!.nombre}');
          } else {
            appLogger.info('ControlService: No se encontró gestante para ID $gestanteId');
          }
          
          controles.add(Control.fromJson(controlData));
        }
        
        return controles;
      }
      
      // Si no hay servicio de gestantes, retornar los controles sin datos adicionales
      return controlesData.map((data) => Control.fromJson(data)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo controles', error: e);
      rethrow;
    }
  }

  Future<Control?> obtenerControlPorId(String id) async {
    try {
      appLogger.info('ControlService: Obteniendo control por ID: $id');
      final response = await _apiService.get('/controles/$id');
      return Control.fromJson(response.data);  // Corrección: Acceder a data de Response
    } catch (e) {
      appLogger.error('Error obteniendo control por ID', error: e, context: {
        'id': id,
      });
      return null;
    }
  }

  Future<List<Control>> obtenerControlesPorGestante(String gestanteId) async {
    try {
      appLogger.info('ControlService: Obteniendo controles por gestante', context: {
        'gestanteId': gestanteId,
      });
      final response = await _apiService.get('/controles/gestante/$gestanteId');
      final List<dynamic> controlesData = response.data;  // Corrección: Acceder a data de Response
      return controlesData.map((data) => Control.fromJson(data)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo controles por gestante', error: e, context: {
        'gestanteId': gestanteId,
      });
      rethrow;
    }
  }

  Future<Control> crearControl(Map<String, dynamic> controlData) async {
    try {
      appLogger.info('ControlService: Creando control');
      appLogger.info('Datos del control: $controlData');
      
      final response = await _apiService.post('/controles', data: controlData);
      
      // Manejar diferentes formatos de respuesta del backend
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Si la respuesta contiene el control directamente
        if (responseData.containsKey('control')) {
          return Control.fromJson(responseData['control'] as Map<String, dynamic>);
        }
        
        // Si la respuesta es el control directamente
        if (responseData.containsKey('id')) {
          return Control.fromJson(responseData);
        }
      }
      
      throw Exception('Formato de respuesta inválido al crear control');
    } catch (e) {
      appLogger.error('Error creando control', error: e);
      rethrow;
    }
  }

  Future<Control> actualizarControl(String id, Map<String, dynamic> controlData) async {
    try {
      appLogger.info('ControlService: Actualizando control', context: {
        'id': id,
      });
      appLogger.info('Datos de actualización: $controlData');
      
      final response = await _apiService.put('/controles/$id', data: controlData);
      
      // Manejar diferentes formatos de respuesta del backend
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;
        
        // Si la respuesta contiene el control directamente
        if (responseData.containsKey('control')) {
          return Control.fromJson(responseData['control'] as Map<String, dynamic>);
        }
        
        // Si la respuesta es el control directamente
        if (responseData.containsKey('id')) {
          return Control.fromJson(responseData);
        }
      }
      
      throw Exception('Formato de respuesta inválido al actualizar control');
    } catch (e) {
      appLogger.error('Error actualizando control', error: e, context: {
        'id': id,
      });
      rethrow;
    }
  }

  Future<bool> eliminarControl(String id) async {
    try {
      appLogger.info('ControlService: Eliminando control', context: {
        'id': id,
      });
      await _apiService.delete('/controles/$id');
      return true;
    } catch (e) {
      appLogger.error('Error eliminando control', error: e, context: {
        'id': id,
      });
      return false;
    }
  }

  Future<bool> marcarComoCompletado(String id) async {
    try {
      appLogger.info('ControlService: Marcando control como completado', context: {
        'id': id,
      });
      final response = await _apiService.put('/controles/$id', data: {'estado': 'completado'});  // Corrección: Usar parámetro named
      return response.data['success'] == true;  // Corrección: Acceder a data de Response
    } catch (e) {
      appLogger.error('Error marcando control como completado', error: e, context: {
        'id': id,
      });
      return false;
    }
  }

  Future<List<Control>> obtenerControlesVencidos() async {
    try {
      appLogger.info('ControlService: Obteniendo controles vencidos');
      final response = await _apiService.get('/controles/vencidos');
      final List<dynamic> controlesData = response.data;  // Corrección: Acceder a data de Response
      return controlesData.map((data) => Control.fromJson(data)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo controles vencidos', error: e);
      rethrow;
    }
  }

  Future<List<Control>> obtenerControlesPendientes() async {
    try {
      appLogger.info('ControlService: Obteniendo controles pendientes');
      final response = await _apiService.get('/controles/pendientes');
      final List<dynamic> controlesData = response.data;  // Corrección: Acceder a data de Response
      return controlesData.map((data) => Control.fromJson(data)).toList();
    } catch (e) {
      appLogger.error('Error obteniendo controles pendientes', error: e);
      rethrow;
    }
  }
}