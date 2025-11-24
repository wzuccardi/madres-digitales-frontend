import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';

// Estado del report provider
class ReportState {

  const ReportState({
    this.reportes,
    this.isLoading = false,
    this.errorMessage,
    this.selectedType,
    this.selectedFormat,
    this.hasFilters = false,
  });
  final List<Report>? reportes;
  final bool isLoading;
  final String? errorMessage;
  final ReportType? selectedType;
  final ReportFormat? selectedFormat;
  final bool hasFilters;

  ReportState copyWith({
    List<Report>? reportes,
    bool? isLoading,
    String? errorMessage,
    ReportType? selectedType,
    ReportFormat? selectedFormat,
    bool? hasFilters,
  }) {
    return ReportState(
      reportes: reportes ?? this.reportes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedType: selectedType ?? this.selectedType,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      hasFilters: hasFilters ?? this.hasFilters,
    );
  }
}

// Notifier para gestión de reportes
class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(const ReportState());

  // Actualizar tipo seleccionado
  void updateSelectedType(ReportType? type) {
    state = state.copyWith(selectedType: type, hasFilters: true);
  }

  // Actualizar formato seleccionado
  void updateSelectedFormat(ReportFormat? format) {
    state = state.copyWith(selectedFormat: format, hasFilters: true);
  }

  // Generar reporte
  Future<void> generarReporte({
    required ReportType tipo,
    required ReportFormat formato,
    required Map<String, dynamic> filtros,
    required String generadoPor,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Simulación de generación de reporte
      await Future.delayed(const Duration(seconds: 2));
      
      // Obtener el nombre del tipo de reporte para el título
      String tipoNombre = _getReportTypeDisplayName(tipo);
      
      final nuevoReporte = Report(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: 'Reporte $tipoNombre',
        descripcion: 'Reporte generado',
        tipo: tipo,
        formato: formato,
        gestanteId: null,
        medicoId: null,
        ipsId: null,
        fechaGeneracion: DateTime.now(),
        generadoPor: generadoPor,
        parametros: filtros,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final reportesActualizados = <Report>[...?state.reportes, nuevoReporte];
      
      state = state.copyWith(
        reportes: reportesActualizados,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Refrescar reporte
  Future<void> refrescarReporte(Report reporte) async {
    try {
      // Simulación de refresco
      await Future.delayed(const Duration(seconds: 1));
      
      final reportesActualizados = state.reportes?.map((r) {
        if (r.id == reporte.id) {
          return r.copyWith(
            updatedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();

      state = state.copyWith(reportes: reportesActualizados);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Método auxiliar para obtener el nombre para mostrar del tipo de reporte
  String _getReportTypeDisplayName(ReportType tipo) {
    switch (tipo) {
      case ReportType.gestantes:
        return 'Gestantes';
      case ReportType.controles:
        return 'Controles Prenatales';
      case ReportType.alertas:
        return 'Alertas';
      case ReportType.actividadMadrinas:
        return 'Actividad de Madrinas';
      case ReportType.consolidadoMensual:
        return 'Consolidado Mensual';
      case ReportType.consolidadoAnual:
        return 'Consolidado Anual';
      case ReportType.personalizado:
        return 'Personalizado';
    }
  }
}

// Provider
final reportProviderProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier();
});

// Provider para acceder al notifier
final reportProviderProviderNotificado = Provider<ReportNotifier>((ref) {
  return ref.read(reportProviderProvider.notifier);
});