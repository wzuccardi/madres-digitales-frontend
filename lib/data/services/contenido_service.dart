import 'dart:io';
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/services/file_service.dart';

class ContenidoService {
  ContenidoService(this._repository, this._apiService);
  final ContenidoRepository _repository;
  final ApiService _apiService;
  
  Future<List<ContenidoUnificado>> getAllContenidos() async {
    final result = await _repository.getContenidos();
    if (result.isSuccess) {
      final data = result.data as List<Contenido>;
      return data.map(_toUnificado).toList();
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<ContenidoUnificado> getContenidoById(String id) async {
    final result = await _repository.getContenidoById(id);
    if (result.isSuccess) {
      final data = result.data;
      if (data == null) {
        throw const NotFoundError('Contenido no encontrado');
      }
      return _toUnificado(data);
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<ContenidoUnificado> saveContenido(ContenidoUnificado contenido) async {
    final categoria = CategoriaContenido.fromString(contenido.categoria);
    final tipo = TipoContenido.fromString(contenido.tipo);
    final nivel = NivelDificultad.fromString(contenido.nivel ?? 'basico');
    final result = await _repository.createContenido(
      titulo: contenido.titulo,
      descripcion: contenido.descripcion ?? '',
      categoria: categoria,
      tipo: tipo,
      url: contenido.urlContenido,
      thumbnailUrl: contenido.urlImagen,
      duracion: contenido.duracionMinutos,
      nivel: nivel,
      etiquetas: contenido.tags ?? const [],
      semanaGestacionInicio: contenido.destacadoEnSemanaGestacion == true ? contenido.semanaGestacionInicio : contenido.semanaGestacionInicio,
      semanaGestacionFin: contenido.semanaGestacionFin,
    );
    if (result.isSuccess) {
      final data = result.data as Contenido;
      return _toUnificado(data);
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<void> deleteContenido(String id) async {
    final result = await _repository.deleteContenido(id);
    if (result.isFailure) {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<String> uploadFile(File file, {String? categoria}) async {
    final result = await FileService.uploadFile(
      file,
      additionalFields: {
        if (categoria != null) 'categoria': categoria,
      },
    );
    if (result.success && result.fileUrl != null) {
      return result.fileUrl!;
    }
    throw FileUploadError(result.errorMessage ?? 'Error al subir archivo');
  }
  
  Future<List<ContenidoUnificado>> searchContenidos(String query, {String? categoria}) async {
    final cat = categoria != null ? CategoriaContenido.fromString(categoria) : null;
    final result = await _repository.searchContenidos(query, categoria: cat);
    if (result.isSuccess) {
      final data = result.data as List<Contenido>;
      return data.map(_toUnificado).toList();
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<List<ContenidoUnificado>> getContenidosByCategoria(String categoria) async {
    final cat = CategoriaContenido.fromString(categoria);
    final result = await _repository.getContenidos(categoria: cat);
    if (result.isSuccess) {
      final data = result.data as List<Contenido>;
      return data.map(_toUnificado).toList();
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<List<ContenidoUnificado>> getContenidosByTipo(String tipo) async {
    final t = TipoContenido.fromString(tipo);
    final result = await _repository.getContenidos(tipo: t);
    if (result.isSuccess) {
      final data = result.data as List<Contenido>;
      return data.map(_toUnificado).toList();
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<List<ContenidoUnificado>> getContenidosByGestante(String gestanteId) async {
    final result = await _repository.getContenidos();
    if (result.isSuccess) {
      final data = result.data as List<Contenido>;
      final filtered = data.where((c) => c.etiquetas.contains(gestanteId)).map(_toUnificado).toList();
      return filtered;
    } else {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<void> updateContenido(ContenidoUnificado contenido) async {
    final categoria = CategoriaContenido.fromString(contenido.categoria);
    final tipo = TipoContenido.fromString(contenido.tipo);
    final nivel = NivelDificultad.fromString(contenido.nivel ?? 'basico');
    final result = await _repository.updateContenido(
      contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion,
      categoria: categoria,
      tipo: tipo,
      url: contenido.urlContenido,
      thumbnailUrl: contenido.urlImagen,
      duracion: contenido.duracionMinutos,
      nivel: nivel,
      etiquetas: contenido.tags,
      semanaGestacionInicio: contenido.semanaGestacionInicio,
      semanaGestacionFin: contenido.semanaGestacionFin,
    );
    if (result.isFailure) {
      final err = result.error as AppError;
      throw err;
    }
  }
  
  Future<bool> syncContenidos() async {
    return true;
  }
  
  Future<Map<String, dynamic>> getEstadisticasContenidos() async {
    final response = await _apiService.get('/contenido/estadisticas');
    if (response.statusCode == 200 && response.data != null) {
      return response.data['data'] as Map<String, dynamic>;
    }
    throw const ServerError('Error al cargar estadísticas');
  }

  ContenidoUnificado _toUnificado(Contenido c) {
    return ContenidoUnificado(
      id: c.id,
      titulo: c.titulo,
      descripcion: c.descripcion,
      categoria: c.categoria.value,
      tipo: c.tipo.value,
      urlContenido: c.url,
      urlImagen: c.thumbnailUrl,
      duracionMinutos: c.duracion,
      nivel: c.nivel.value,
      tags: c.etiquetas,
      fechaCreacion: c.createdAt,
      fechaActualizacion: c.updatedAt,
      activo: c.activo,
    );
  }
}