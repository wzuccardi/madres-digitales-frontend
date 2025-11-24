import 'dart:typed_data';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/domain/entities/report.dart';
import 'package:madres_digitales_flutter_new/domain/repositories/report_repository.dart';
import 'package:madres_digitales_flutter_new/core/services/pdf_generator_service.dart';
import 'package:madres_digitales_flutter_new/core/services/excel_generator_service.dart';
import 'package:madres_digitales_flutter_new/core/services/csv_generator_service.dart';
import 'package:madres_digitales_flutter_new/core/services/txt_generator_service.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl({required PDFGeneratorService pdfGeneratorService, required ExcelGeneratorService excelGeneratorService, required CSVGeneratorService csvGeneratorService, required TXTGeneratorService txtGeneratorService})
      : _pdf = pdfGeneratorService,
        _excel = excelGeneratorService,
        _csv = csvGeneratorService,
        _txt = txtGeneratorService;

  final PDFGeneratorService _pdf;
  final ExcelGeneratorService _excel;
  final CSVGeneratorService _csv;
  final TXTGeneratorService _txt;

  @override
  Future<Result<Report, AppError>> generarReporte(Report reporte) async {
    try {
      return Result.success(reporte);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  @override
  Future<Result<List<Report>, AppError>> getAll() async {
    try {
      return const Result.success(<Report>[]);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  @override
  Future<Result<Report?, AppError>> getById(String id) async {
    try {
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  @override
  Future<Result<Uint8List, AppError>> descargarReporte(String id) async {
    try {
      final dummy = Report(
        id: id,
        titulo: 'Reporte',
        descripcion: 'Descarga placeholder',
        tipo: ReportType.personalizado,
        formato: ReportFormat.txt,
        fechaGeneracion: DateTime.now(),
        generadoPor: 'sistema',
        parametros: {
          'datos': <Map<String, dynamic>>[],
          'campos': <String>[],
        },
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final bytes = await _txt.generarTXT(dummy);
      await Future.wait([
        _pdf.generarPDF(dummy),
        _excel.generarExcel(dummy),
        _csv.generarCSV(dummy),
      ]);
      return Result.success(bytes);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }

  @override
  Future<Result<void, AppError>> delete(String id) async {
    try {
      return const Result.success(null);
    } catch (e) {
      return Result.failure(UnknownError(e.toString()));
    }
  }
}