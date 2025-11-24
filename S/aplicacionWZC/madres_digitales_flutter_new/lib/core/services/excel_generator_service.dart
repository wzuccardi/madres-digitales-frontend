import 'dart:typed_data';
import '../../domain/entities/report.dart';

class ExcelGeneratorService {
  Future<Uint8List> generarExcel(Report reporte) async {
    try {
      // Simulación de generación de Excel
      // En una implementación real, aquí se usaría la librería excel
      
      // Por ahora, retornamos un Excel simulado en formato CSV
      final contenido = _generarContenidoExcel(reporte);
      
      // Convertir a bytes
      return Uint8List.fromList(contenido.codeUnits);
    } catch (e) {
      throw Exception('Error generando Excel: $e');
    }
  }
  
  String _generarContenidoExcel(Report reporte) {
    switch (reporte.tipo) {
      case ReportType.gestantes:
        return _generarContenidoGestantesExcel(reporte);
      case ReportType.controles:
        return _generarContenidoControlesExcel(reporte);
      case ReportType.alertas:
        return _generarContenidoAlertasExcel(reporte);
      case ReportType.actividadMadrinas:
        return _generarContenidoActividadMadrinasExcel(reporte);
      case ReportType.consolidadoMensual:
        return _generarContenidoConsolidadoExcel(reporte, 'Mensual');
      case ReportType.consolidadoAnual:
        return _generarContenidoConsolidadoExcel(reporte, 'Anual');
      case ReportType.personalizado:
        return _generarContenidoPersonalizadoExcel(reporte);
    }
  }
  
  String _generarContenidoGestantesExcel(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = 'ID,Nombre,Documento,Municipio,Edad,Semanas,Riesgo\n';
    
    for (int i = 0; i < datos.length; i++) {
      final gestante = datos[i] as Map<String, dynamic>;
      contenido += '${gestante['id']?.toString() ?? ''},${gestante['nombre']?.toString() ?? ''},${gestante['documento']?.toString() ?? ''},${gestante['municipio']?.toString() ?? ''},${gestante['edad']?.toString() ?? ''},${gestante['semanas']?.toString() ?? ''},${gestante['riesgo']?.toString() ?? ''}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoControlesExcel(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = 'ID,Gestante,Fecha,Peso,Presión,FCF,Síntomas\n';
    
    for (int i = 0; i < datos.length; i++) {
      final control = datos[i] as Map<String, dynamic>;
      contenido += '${control['id']?.toString() ?? ''},${control['gestante']?.toString() ?? ''},${control['fecha']?.toString() ?? ''},${control['peso']?.toString() ?? ''},${control['presion']?.toString() ?? ''},${control['fcf']?.toString() ?? ''},${control['sintomas']?.toString() ?? ''}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoAlertasExcel(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = 'ID,Gestante,Fecha,Tipo,Prioridad,Descripción,Estado\n';
    
    for (int i = 0; i < datos.length; i++) {
      final alerta = datos[i] as Map<String, dynamic>;
      contenido += '${alerta['id']?.toString() ?? ''},${alerta['gestante']?.toString() ?? ''},${alerta['fecha']?.toString() ?? ''},${alerta['tipo']?.toString() ?? ''},${alerta['prioridad']?.toString() ?? ''},${alerta['descripcion']?.toString() ?? ''},${alerta['estado']?.toString() ?? ''}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoActividadMadrinasExcel(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = 'ID Madrina,Nombre,Gestantes Asignadas,Controles Realizados,Alertas Atendidas\n';
    
    for (int i = 0; i < datos.length; i++) {
      final madrina = datos[i] as Map<String, dynamic>;
      contenido += '${madrina['id']?.toString() ?? ''},${madrina['nombre']?.toString() ?? ''},${madrina['gestantesAsignadas']?.toString() ?? '0'},${madrina['controlesRealizados']?.toString() ?? '0'},${madrina['alertasAtendidas']?.toString() ?? '0'}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoConsolidadoExcel(Report reporte, String periodo) {
    final datos = reporte.parametros['datos'] as Map<String, dynamic>? ?? {};
    
    var contenido = 'Resumen $periodo\n';
    
    if (datos.containsKey('totalGestantes')) {
      contenido += 'Total Gestantes,${datos['totalGestantes']}\n';
    }
    
    if (datos.containsKey('totalControles')) {
      contenido += 'Total Controles,${datos['totalControles']}\n';
    }
    
    if (datos.containsKey('totalAlertas')) {
      contenido += 'Total Alertas,${datos['totalAlertas']}\n';
    }
    
    if (datos.containsKey('madrinasActivas')) {
      contenido += 'Madrinas Activas,${datos['madrinasActivas']}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoPersonalizadoExcel(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    final campos = reporte.parametros['campos'] as List<String>? ?? [];
    
    var contenido = '${campos.join(',')}\n';
    
    for (int i = 0; i < datos.length; i++) {
      final item = datos[i] as Map<String, dynamic>;
      
      for (String campo in campos) {
        contenido += item[campo]?.toString() ?? '';
        
        if (campo != campos.last) {
          contenido += ',';
        }
      }
      
      contenido += '\n';
    }
    
    return contenido;
  }
}
