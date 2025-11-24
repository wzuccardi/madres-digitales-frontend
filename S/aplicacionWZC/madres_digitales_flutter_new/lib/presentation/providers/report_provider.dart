import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/report.dart';
import '../../../core/services/pdf_generator_service.dart';
import '../../../core/services/excel_generator_service.dart';
import '../../../core/services/csv_generator_service.dart';
import '../../../core/services/txt_generator_service.dart';

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(const ReportState());

  void setReportes(List<Report> reportes) {
    state = ReportState.loaded(reportes: reportes);
  }

  void setError(String message) {
    state = ReportState.error(message: message);
  }
}

enum ReportStatus {
  initial,
  loading,
  loaded,
  downloading,
  downloadComplete,
  error,
  deleted,
}

class ReportState {
  
  const ReportState({
    this.status = ReportStatus.initial,
    this.reportes,
    this.errorMessage,
  });
  
  const ReportState.loading() : this(status: ReportStatus.loading);
  const ReportState.loaded({required List<Report> reportes}) : this(status: ReportStatus.loaded, reportes: reportes);
  const ReportState.downloading() : this(status: ReportStatus.downloading);
  const ReportState.downloadComplete() : this(status: ReportStatus.downloadComplete);
  const ReportState.error({required String message}) : this(status: ReportStatus.error, errorMessage: message);
  const ReportState.deleted() : this(status: ReportStatus.deleted);
  final ReportStatus status;
  final List<Report>? reportes;
  final String? errorMessage;
  
  ReportState copyWith({
    ReportStatus? status,
    List<Report>? reportes,
    String? errorMessage,
  }) {
    return ReportState(
      status: status ?? this.status,
      reportes: reportes ?? this.reportes,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ReportState) return false;
    return status == other.status &&
        reportes?.length == other.reportes?.length &&
        errorMessage == other.errorMessage;
  }
  
  @override
  int get hashCode => Object.hash(status, reportes, errorMessage);
  
  @override
  String toString() {
    return 'ReportState{status: $status, reportes: ${reportes?.length}, errorMessage: $errorMessage}';
  }
}

// Provider para el estado de los reportes
final reportProviderProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) => ReportNotifier());

// Provider para el notifier de reportes
final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) => ReportNotifier());

// Providers para los use cases
// Providers simplificados
final pdfGeneratorServiceProvider = Provider<PDFGeneratorService>((ref) => PDFGeneratorService());
final excelGeneratorServiceProvider = Provider<ExcelGeneratorService>((ref) => ExcelGeneratorService());
final csvGeneratorServiceProvider = Provider<CSVGeneratorService>((ref) => CSVGeneratorService());
final txtGeneratorServiceProvider = Provider<TXTGeneratorService>((ref) => TXTGeneratorService());
