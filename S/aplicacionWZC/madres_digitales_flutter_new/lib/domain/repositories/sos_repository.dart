import '../entities/sos_alert.dart';
import '../entities/sos_location.dart';
import '../entities/sos_statistics.dart';

abstract class SOSRepository {
  /// Enviar una nueva alerta SOS
  Future<SOSAlert> enviarAlertaSOS(EnviarSOSParams params);
  
  /// Obtener todas las alertas activas
  Future<List<SOSAlert>> obtenerAlertasActivas();
  
  /// Obtener el historial de alertas con filtros opcionales
  Future<List<SOSAlert>> obtenerHistorialAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? gestanteId,
    String? madrinaId,
    SOSAlertStatus? estado,
    SOSPriority? prioridad,
    int? limite,
    int? pagina,
  });
  
  /// Obtener una alerta específica por su ID
  Future<SOSAlert?> obtenerAlertaPorId(String alertaId);
  
  /// Actualizar el estado de una alerta
  Future<SOSAlert> actualizarEstadoAlerta(String alertaId, SOSAlertStatus nuevoEstado, {
    String? atendidoPor,
    String? motivoCancelacion,
  });
  
  /// Cancelar una alerta
  Future<void> cancelarAlerta(String alertaId, String motivo);
  
  /// Marcar una alerta como atendida
  Future<SOSAlert> marcarAlertaComoAtendida(String alertaId, String atendidoPor);
  
  /// Marcar una alerta como falsa alarma
  Future<SOSAlert> marcarAlertaComoFalsaAlarma(String alertaId, String motivo);
  
  /// Obtener ubicaciones de alertas SOS
  Future<List<SOSLocation>> obtenerUbicacionesAlertas({
    String? alertaId,
    String? gestanteId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? limite,
  });
  
  /// Obtener estadísticas de SOS
  Future<SOSStatistics> obtenerEstadisticasSOS({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? municipioId,
    String? madrinaId,
  });
  
  /// Observar alertas activas en tiempo real (Stream)
  Stream<List<SOSAlert>> observarAlertasActivas();
  
  /// Observar una alerta específica en tiempo real (Stream)
  Stream<SOSAlert> observarAlerta(String alertaId);
  
  /// Observar cambios en estadísticas (Stream)
  Stream<SOSStatistics> observarEstadisticasSOS();
  
  /// Buscar alertas por texto o criterios
  Future<List<SOSAlert>> buscarAlertas({
    String? query,
    String? gestanteId,
    String? madrinaId,
    SOSAlertStatus? estado,
    SOSPriority? prioridad,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? limite,
    int? pagina,
  });
  
  /// Obtener alertas cercanas a una ubicación
  Future<List<SOSAlert>> obtenerAlertasCercanas({
    required double latitud,
    required double longitud,
    double radioKm = 5.0,
    int? limite,
  });
  
  /// Exportar alertas a diferentes formatos
  Future<String> exportarAlertas({
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? formato, // 'csv', 'excel', 'pdf'
    List<String>? campos,
  });
}

/// Parámetros para enviar una alerta SOS
class EnviarSOSParams {

  const EnviarSOSParams({
    required this.gestanteId,
    required this.gestanteNombre,
    required this.madrinaId,
    required this.madrinaNombre,
    required this.latitud,
    required this.longitud,
    required this.descripcion,
    this.nivelPrioridad = SOSPriority.critica,
    this.metadata,
  });
  final String gestanteId;
  final String gestanteNombre;
  final String madrinaId;
  final String madrinaNombre;
  final double latitud;
  final double longitud;
  final String descripcion;
  final SOSPriority nivelPrioridad;
  final Map<String, dynamic>? metadata;
}

/// Parámetros para actualizar estado de alerta
class ActualizarEstadoAlertaParams {

  const ActualizarEstadoAlertaParams({
    required this.alertaId,
    required this.nuevoEstado,
    this.atendidoPor,
    this.motivoCancelacion,
  });
  final String alertaId;
  final SOSAlertStatus nuevoEstado;
  final String? atendidoPor;
  final String? motivoCancelacion;
}

/// Parámetros de búsqueda de alertas
class BuscarAlertasParams {

  const BuscarAlertasParams({
    this.query,
    this.gestanteId,
    this.madrinaId,
    this.estado,
    this.prioridad,
    this.fechaInicio,
    this.fechaFin,
    this.limite,
    this.pagina,
  });
  final String? query;
  final String? gestanteId;
  final String? madrinaId;
  final SOSAlertStatus? estado;
  final SOSPriority? prioridad;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? limite;
  final int? pagina;
}

/// Parámetros para obtener alertas cercanas
class ObtenerAlertasCercanasParams {

  const ObtenerAlertasCercanasParams({
    required this.latitud,
    required this.longitud,
    this.radioKm = 5.0,
    this.limite,
  });
  final double latitud;
  final double longitud;
  final double radioKm;
  final int? limite;
}

/// Parámetros para exportar alertas
class ExportarAlertasParams {

  const ExportarAlertasParams({
    this.fechaInicio,
    this.fechaFin,
    required this.formato,
    this.campos,
  });
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String formato; // 'csv', 'excel', 'pdf'
  final List<String>? campos;
}
