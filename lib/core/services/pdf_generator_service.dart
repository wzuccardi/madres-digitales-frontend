import 'dart:typed_data';
import '../../domain/entities/report.dart';

class PDFGeneratorService {
  Future<Uint8List> generarPDF(Report reporte) async {
    try {
      // Simulación de generación de PDF
      // En una implementación real, aquí se usaría la librería pdf
      
      // Por ahora, retornamos un PDF simulado
      final contenido = _generarContenidoPDF(reporte);
      final header = _generarHeaderPDF(reporte);
      
      // Combinar header y contenido
      final pdfCompleto = '$header\n\n$contenido';
      
      // Convertir a bytes
      return Uint8List.fromList(pdfCompleto.codeUnits);
    } catch (e) {
      throw Exception('Error generando PDF: $e');
    }
  }
  
  String _generarHeaderPDF(Report reporte) {
    return '''
====================================================
              SISTEMA MADRES DIGITALES - REPORTE
====================================================
Tipo de Reporte: ${reporte.tipoDisplay}
Formato: ${reporte.formatoDisplay}
Fecha Generación: ${reporte.formattedFechaGeneracion}
Generado por: ${reporte.generadoPor}
====================================================

''';
  }
  
  String _generarContenidoPDF(Report reporte) {
    switch (reporte.tipo) {
      case ReportType.gestantes:
        return _generarContenidoGestantesPDF(reporte);
      case ReportType.controles:
        return _generarContenidoControlesPDF(reporte);
      case ReportType.alertas:
        return _generarContenidoAlertasPDF(reporte);
      case ReportType.actividadMadrinas:
        return _generarContenidoActividadMadrinasPDF(reporte);
      case ReportType.consolidadoMensual:
        return _generarContenidoConsolidadoPDF(reporte, 'Mensual');
      case ReportType.consolidadoAnual:
        return _generarContenidoConsolidadoPDF(reporte, 'Anual');
      case ReportType.personalizado:
        return _generarContenidoPersonalizadoPDF(reporte);
    }
  }
  
  String _generarContenidoGestantesPDF(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = '''
LISTADO DE GESTANTES
===================

Total de Gestantes: ${datos.length}

Datos:
''';
    
    for (int i = 0; i < datos.length && i < 10; i++) {
      final gestante = datos[i] as Map<String, dynamic>;
      contenido += '''
${i + 1}. ID: ${gestante['id']?.toString() ?? ''}
${i + 1}. Nombre: ${gestante['nombre']?.toString() ?? ''}
${i + 1}. Documento: ${gestante['documento']?.toString() ?? ''}
${i + 1}. Municipio: ${gestante['municipio']?.toString() ?? ''}
${i + 1}. Edad: ${gestante['edad']?.toString() ?? ''}
${i + 1}. Semanas: ${gestante['semanas']?.toString() ?? ''}
${i + 1}. Riesgo: ${gestante['riesgo']?.toString() ?? ''}

''';
    }
    
    if (datos.length > 10) {
      contenido += '... y ${datos.length - 10} gestantes más\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoControlesPDF(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = '''
LISTADO DE CONTROLES PRENATALES
==============================

Total de Controles: ${datos.length}

Datos:
''';
    
    for (int i = 0; i < datos.length && i < 10; i++) {
      final control = datos[i] as Map<String, dynamic>;
      contenido += '''
${i + 1}. ID: ${control['id']?.toString() ?? ''}
${i + 1}. Gestante: ${control['gestante']?.toString() ?? ''}
${i + 1}. Fecha: ${control['fecha']?.toString() ?? ''}
${i + 1}. Peso: ${control['peso']?.toString() ?? ''}
${i + 1}. Presión: ${control['presion']?.toString() ?? ''}
${i + 1}. FCF: ${control['fcf']?.toString() ?? ''}
${i + 1}. Síntomas: ${control['sintomas']?.toString() ?? ''}

''';
    }
    
    if (datos.length > 10) {
      contenido += '... y ${datos.length - 10} controles más\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoAlertasPDF(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = '''
LISTADO DE ALERTAS
==================

Total de Alertas: ${datos.length}

Datos:
''';
    
    for (int i = 0; i < datos.length && i < 10; i++) {
      final alerta = datos[i] as Map<String, dynamic>;
      contenido += '''
${i + 1}. ID: ${alerta['id']?.toString() ?? ''}
${i + 1}. Gestante: ${alerta['gestante']?.toString() ?? ''}
${i + 1}. Fecha: ${alerta['fecha']?.toString() ?? ''}
${i + 1}. Tipo: ${alerta['tipo']?.toString() ?? ''}
${i + 1}. Prioridad: ${alerta['prioridad']?.toString() ?? ''}
${i + 1}. Descripción: ${alerta['descripcion']?.toString() ?? ''}
${i + 1}. Estado: ${alerta['estado']?.toString() ?? ''}

''';
    }
    
    if (datos.length > 10) {
      contenido += '... y ${datos.length - 10} alertas más\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoActividadMadrinasPDF(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    
    var contenido = '''
ESTADÍSTICAS DE ACTIVIDAD DE MADRINAS
=======================================

Total de Madrinas Activas: ${datos.length}

Datos:
''';
    
    for (int i = 0; i < datos.length && i < 10; i++) {
      final madrina = datos[i] as Map<String, dynamic>;
      contenido += '''
${i + 1}. ID Madrina: ${madrina['id']?.toString() ?? ''}
${i + 1}. Nombre: ${madrina['nombre']?.toString() ?? ''}
${i + 1}. Gestantes Asignadas: ${madrina['gestantesAsignadas']?.toString() ?? '0'}
${i + 1}. Controles Realizados: ${madrina['controlesRealizados']?.toString() ?? '0'}
${i + 1}. Alertas Atendidas: ${madrina['alertasAtendidas']?.toString() ?? '0'}

''';
    }
    
    if (datos.length > 10) {
      contenido += '... y ${datos.length - 10} madrinas más\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoConsolidadoPDF(Report reporte, String periodo) {
    final datos = reporte.parametros['datos'] as Map<String, dynamic>? ?? {};
    
    var contenido = '''
REPORTE CONSOLIDADO $periodo
============================

Resumen:
''';
    
    if (datos.containsKey('totalGestantes')) {
      contenido += 'Total Gestantes: ${datos['totalGestantes']}\n';
    }
    
    if (datos.containsKey('totalControles')) {
      contenido += 'Total Controles: ${datos['totalControles']}\n';
    }
    
    if (datos.containsKey('totalAlertas')) {
      contenido += 'Total Alertas: ${datos['totalAlertas']}\n';
    }
    
    if (datos.containsKey('madrinasActivas')) {
      contenido += 'Madrinas Activas: ${datos['madrinasActivas']}\n';
    }
    
    return contenido;
  }
  
  String _generarContenidoPersonalizadoPDF(Report reporte) {
    final datos = reporte.parametros['datos'] as List<dynamic>? ?? [];
    final campos = reporte.parametros['campos'] as List<String>? ?? [];
    
    var contenido = '''
REPORTE PERSONALIZADO
====================

Campos seleccionados: ${campos.join(', ')}

Total de Registros: ${datos.length}

Datos:
''';
    
    for (int i = 0; i < datos.length && i < 10; i++) {
      final item = datos[i] as Map<String, dynamic>;
      contenido += '''
${i + 1}. ''';
      
      for (String campo in campos) {
        contenido += '$campo: ${item[campo]?.toString() ?? ''}\n';
      }
      
      contenido += '\n';
    }
    
    if (datos.length > 10) {
      contenido += '... y ${datos.length - 10} registros más\n';
    }
    
    return contenido;
  }
}
