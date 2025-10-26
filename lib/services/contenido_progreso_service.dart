import 'dart:async';
import 'package:madres_digitales_flutter_new/services/api_service.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

/// Modelo de progreso de contenido
class ProgresoContenido {
  final String contenidoId;
  final bool completado;
  final int porcentajeProgreso;
  final int? tiempoVisto;
  final DateTime? fechaInicio;
  final DateTime? fechaCompletado;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  ProgresoContenido({
    required this.contenidoId,
    required this.completado,
    required this.porcentajeProgreso,
    this.tiempoVisto,
    this.fechaInicio,
    this.fechaCompletado,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory ProgresoContenido.fromJson(Map<String, dynamic> json) {
    return ProgresoContenido(
      contenidoId: json['contenido_id'] ?? '',
      completado: json['completado'] ?? false,
      porcentajeProgreso: json['porcentaje_progreso'] ?? 0,
      tiempoVisto: json['tiempo_visto'],
      fechaInicio: json['fecha_inicio'] != null 
          ? DateTime.parse(json['fecha_inicio']) 
          : null,
      fechaCompletado: json['fecha_completado'] != null 
          ? DateTime.parse(json['fecha_completado']) 
          : null,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contenido_id': contenidoId,
      'completado': completado,
      'porcentaje_progreso': porcentajeProgreso,
      'tiempo_visto': tiempoVisto,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_completado': fechaCompletado?.toIso8601String(),
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }
}

/// Servicio para gestionar el progreso de contenidos educativos
class ContenidoProgresoService {
  final ApiService _apiService;
  
  // Cache de progreso local
  final Map<String, ProgresoContenido> _progresoCache = {};
  
  // Stream para notificar cambios de progreso
  final StreamController<ProgresoContenido> _progresoController = 
      StreamController<ProgresoContenido>.broadcast();
  
  Stream<ProgresoContenido> get progresoStream => _progresoController.stream;

  ContenidoProgresoService(this._apiService);

  /// Actualizar progreso de un contenido
  Future<void> actualizarProgreso({
    required String contenidoId,
    required int porcentajeProgreso,
    bool? completado,
    int? tiempoVisto,
    DateTime? fechaInicio,
  }) async {
    try {
      appLogger.debug('ContenidoProgresoService: Actualizando progreso', context: {
        'contenidoId': contenidoId,
        'porcentaje': porcentajeProgreso,
        'completado': completado,
        'tiempoVisto': tiempoVisto,
      });

      final data = {
        'contenidoId': contenidoId,
        'progreso': porcentajeProgreso,
        'completado': completado ?? (porcentajeProgreso >= 95),
        'tiempoVisto': tiempoVisto,
        'fechaInicio': fechaInicio?.toIso8601String(),
      };

      final response = await _apiService.post('/contenido/$contenidoId/progreso', data: data);
      
      if (response.data['success'] == true) {
        // Actualizar cache local
        final progreso = ProgresoContenido(
          contenidoId: contenidoId,
          completado: completado ?? (porcentajeProgreso >= 95),
          porcentajeProgreso: porcentajeProgreso,
          tiempoVisto: tiempoVisto,
          fechaInicio: fechaInicio,
          fechaCompletado: (completado ?? (porcentajeProgreso >= 95)) ? DateTime.now() : null,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        );
        
        _progresoCache[contenidoId] = progreso;
        _progresoController.add(progreso);
        
        appLogger.debug('ContenidoProgresoService: Progreso actualizado exitosamente');
      }
    } catch (e) {
      appLogger.error('Error actualizando progreso de contenido', error: e, context: {
        'contenidoId': contenidoId,
      });
      rethrow;
    }
  }

  /// Obtener progreso de un contenido específico
  Future<ProgresoContenido?> obtenerProgreso(String contenidoId) async {
    try {
      // Verificar cache primero
      if (_progresoCache.containsKey(contenidoId)) {
        return _progresoCache[contenidoId];
      }

      appLogger.debug('ContenidoProgresoService: Obteniendo progreso', context: {
        'contenidoId': contenidoId,
      });

      final response = await _apiService.get('/contenido/$contenidoId/progreso');
      
      if (response.data != null) {
        final progreso = ProgresoContenido.fromJson(response.data);
        _progresoCache[contenidoId] = progreso;
        return progreso;
      }
      
      return null;
    } catch (e) {
      appLogger.error('Error obteniendo progreso de contenido', error: e, context: {
        'contenidoId': contenidoId,
      });
      return null;
    }
  }

  /// Registrar vista de contenido
  Future<void> registrarVista(String contenidoId) async {
    try {
      appLogger.debug('ContenidoProgresoService: Registrando vista', context: {
        'contenidoId': contenidoId,
      });

      await _apiService.post('/contenido/$contenidoId/vista');
      
      appLogger.debug('ContenidoProgresoService: Vista registrada exitosamente');
    } catch (e) {
      appLogger.error('Error registrando vista de contenido', error: e, context: {
        'contenidoId': contenidoId,
      });
      // No relanzar el error para vistas, es opcional
    }
  }

  /// Calificar contenido
  Future<void> calificarContenido(String contenidoId, int calificacion) async {
    try {
      appLogger.debug('ContenidoProgresoService: Calificando contenido', context: {
        'contenidoId': contenidoId,
        'calificacion': calificacion,
      });

      final data = {
        'calificacion': calificacion,
      };

      await _apiService.post('/contenido/$contenidoId/calificar', data: data);
      
      appLogger.debug('ContenidoProgresoService: Contenido calificado exitosamente');
    } catch (e) {
      appLogger.error('Error calificando contenido', error: e, context: {
        'contenidoId': contenidoId,
        'calificacion': calificacion,
      });
      rethrow;
    }
  }

  /// Obtener todos los progresos del usuario
  Future<List<ProgresoContenido>> obtenerTodosLosProgresos() async {
    try {
      appLogger.debug('ContenidoProgresoService: Obteniendo todos los progresos');

      final response = await _apiService.get('/contenido/progreso/usuario');
      
      if (response.data is List) {
        final progresos = (response.data as List)
            .map((data) => ProgresoContenido.fromJson(data))
            .toList();
        
        // Actualizar cache
        for (final progreso in progresos) {
          _progresoCache[progreso.contenidoId] = progreso;
        }
        
        return progresos;
      }
      
      return [];
    } catch (e) {
      appLogger.error('Error obteniendo todos los progresos', error: e);
      return [];
    }
  }

  /// Obtener contenidos completados
  Future<List<ProgresoContenido>> obtenerCompletados() async {
    try {
      final progresos = await obtenerTodosLosProgresos();
      return progresos.where((p) => p.completado).toList();
    } catch (e) {
      appLogger.error('Error obteniendo contenidos completados', error: e);
      return [];
    }
  }

  /// Obtener contenidos en progreso
  Future<List<ProgresoContenido>> obtenerEnProgreso() async {
    try {
      final progresos = await obtenerTodosLosProgresos();
      return progresos.where((p) => !p.completado && p.porcentajeProgreso > 0).toList();
    } catch (e) {
      appLogger.error('Error obteniendo contenidos en progreso', error: e);
      return [];
    }
  }

  /// Limpiar cache de progreso
  void limpiarCache() {
    _progresoCache.clear();
    appLogger.debug('ContenidoProgresoService: Cache limpiado');
  }

  /// Obtener progreso desde cache
  ProgresoContenido? obtenerProgresoCache(String contenidoId) {
    return _progresoCache[contenidoId];
  }

  /// Verificar si un contenido está completado
  bool estaCompletado(String contenidoId) {
    final progreso = _progresoCache[contenidoId];
    return progreso?.completado ?? false;
  }

  /// Obtener porcentaje de progreso
  int obtenerPorcentajeProgreso(String contenidoId) {
    final progreso = _progresoCache[contenidoId];
    return progreso?.porcentajeProgreso ?? 0;
  }

  /// Disponer recursos
  void dispose() {
    _progresoController.close();
    _progresoCache.clear();
  }
}