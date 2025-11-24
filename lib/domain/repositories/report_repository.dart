import 'dart:typed_data';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/domain/entities/report.dart';

abstract class ReportRepository {
  Future<Result<Report, AppError>> generarReporte(Report reporte);
  Future<Result<List<Report>, AppError>> getAll();
  Future<Result<Report?, AppError>> getById(String id);
  Future<Result<Uint8List, AppError>> descargarReporte(String id);
  Future<Result<void, AppError>> delete(String id);
}
