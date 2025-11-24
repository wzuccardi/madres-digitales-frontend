import 'dart:typed_data';
import '../../../core/interfaces/usecase.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';

class GenerateReportUseCase implements UseCase<Report, GenerateReportParams> {
  
  GenerateReportUseCase(this._repository);
  final ReportRepository _repository;
  
  @override
  Future<Report> call(GenerateReportParams params) async {
    final res = await _repository.generarReporte(params.reporte);
    if (res.isSuccess) return res.dataOrThrow;
    throw res.errorOrThrow;
  }
}

class GenerateReportParams {
  
  const GenerateReportParams({
    required this.reporte,
  });
  final Report reporte;
}

class GetReportsUseCase implements NoParamsUseCase<List<Report>> {
  
  GetReportsUseCase(this._repository);
  final ReportRepository _repository;
  
  @override
  Future<List<Report>> call() async {
    final res = await _repository.getAll();
    if (res.isSuccess) return res.dataOrThrow;
    throw res.errorOrThrow;
  }
}

class GetReportByIdUseCase implements UseCase<Report?, GetReportByIdParams> {
  
  GetReportByIdUseCase(this._repository);
  final ReportRepository _repository;
  
  @override
  Future<Report?> call(GetReportByIdParams params) async {
    final res = await _repository.getById(params.id);
    if (res.isSuccess) return res.data;
    throw res.errorOrThrow;
  }
}

class GetReportByIdParams {
  
  const GetReportByIdParams({
    required this.id,
  });
  final String id;
}

class DownloadReportUseCase implements UseCase<Uint8List, DownloadReportParams> {
  
  DownloadReportUseCase(this._repository);
  final ReportRepository _repository;
  
  @override
  Future<Uint8List> call(DownloadReportParams params) async {
    final res = await _repository.descargarReporte(params.id);
    if (res.isSuccess) return res.dataOrThrow;
    throw res.errorOrThrow;
  }
}

class DownloadReportParams {
  
  const DownloadReportParams({
    required this.id,
  });
  final String id;
}

class DeleteReportUseCase implements UseCase<void, DeleteReportParams> {
  
  DeleteReportUseCase(this._repository);
  final ReportRepository _repository;
  
  @override
  Future<void> call(DeleteReportParams params) async {
    final res = await _repository.delete(params.id);
    if (!res.isSuccess) throw res.errorOrThrow;
  }
}

class DeleteReportParams {
  
  const DeleteReportParams({
    required this.id,
  });
  final String id;
}
