import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_remote_datasource.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_local_datasource.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/models/contenido_model.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/categoria.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/repositories/contenido_repository.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/network/network_info.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';

class ContenidoRepositoryImpl implements ContenidoRepository {

  ContenidoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final ContenidoRemoteDataSource remoteDataSource;
  final ContenidoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<List<Contenido>, AppError>> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    if (await networkInfo.isConnected && !forceRefresh) {
      try {
        final remoteContenidos = await remoteDataSource.getContenidos(
          categoria: categoria,
          tipo: tipo,
          nivel: nivel,
          page: page,
          limit: limit,
        );
        await localDataSource.cacheContenidos(remoteContenidos);
        final list = remoteContenidos.map((model) => model.toEntity()).toList();
        return Result.success(list);
      } on ServerException {
        final cached = await _getCachedContenidos(categoria, tipo, nivel);
        return Result.success(cached);
      }
    } else {
      final cached = await _getCachedContenidos(categoria, tipo, nivel);
      return Result.success(cached);
    }
  }

  Future<List<Contenido>> _getCachedContenidos(
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
  ) async {
    try {
      return (await localDataSource.getCachedContenidos(
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
      )).map((model) => model.toEntity()).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<Result<Contenido?, AppError>> getContenidoById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContenido = await remoteDataSource.getContenidoById(id);
        await localDataSource.cacheContenido(remoteContenido);
        return Result.success(remoteContenido.toEntity());
      } on ServerException {
        final cached = await _getCachedContenidoById(id);
        return Result.success(cached);
      }
    } else {
      final cached = await _getCachedContenidoById(id);
      return Result.success(cached);
    }
  }

  Future<Contenido?> _getCachedContenidoById(String id) async {
    try {
      final cachedModel = await localDataSource.getCachedContenidoById(id);
      return cachedModel?.toEntity();
    } on CacheException {
      return null;
    }
  }

  @override
  Future<Result<Contenido, AppError>> createContenido({
    required String titulo,
    required String descripcion,
    required CategoriaContenido categoria,
    required TipoContenido tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad nivel = NivelDificultad.basico,
    List<String> etiquetas = const [],
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final contenidoModel = await remoteDataSource.createContenido(
          titulo: titulo,
          descripcion: descripcion,
          categoria: categoria,
          tipo: tipo,
          url: url,
          thumbnailUrl: thumbnailUrl,
          duracion: duracion,
          nivel: nivel,
          etiquetas: etiquetas,
          semanaGestacionInicio: semanaGestacionInicio,
          semanaGestacionFin: semanaGestacionFin,
        );
        final contenido = contenidoModel.toEntity();
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(contenido));
        return Result.success(contenido);
      } on ServerException {
        return const Result.failure(ServerError('Error al crear contenido en el servidor'));
      }
    } else {
      return const Result.failure(NetworkError('Sin conexión a internet'));
    }
  }

  @override
  Future<Result<Contenido, AppError>> updateContenido(
    String id, {
    String? titulo,
    String? descripcion,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    String? url,
    String? thumbnailUrl,
    int? duracion,
    NivelDificultad? nivel,
    List<String>? etiquetas,
    int? semanaGestacionInicio,
    int? semanaGestacionFin,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final contenidoModel = await remoteDataSource.updateContenido(
          id,
          titulo: titulo,
          descripcion: descripcion,
          categoria: categoria,
          tipo: tipo,
          url: url,
          thumbnailUrl: thumbnailUrl,
          duracion: duracion,
          nivel: nivel,
          etiquetas: etiquetas,
          semanaGestacionInicio: semanaGestacionInicio,
          semanaGestacionFin: semanaGestacionFin,
        );
        final contenido = contenidoModel.toEntity();
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(contenido));
        return Result.success(contenido);
      } on ServerException {
        return const Result.failure(ServerError('Error al actualizar contenido en el servidor'));
      }
    } else {
      return const Result.failure(NetworkError('Sin conexión a internet'));
    }
  }

  @override
  Future<Result<void, AppError>> deleteContenido(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteContenido(id);
        await localDataSource.deleteCachedContenido(id);
        return const Result.success(null);
      } on ServerException {
        return const Result.failure(ServerError('Error al eliminar contenido en el servidor'));
      }
    } else {
      return const Result.failure(NetworkError('Sin conexión a internet'));
    }
  }

  @override
  Future<Result<List<Contenido>, AppError>> searchContenidos(
    String query, {
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContenidos = await remoteDataSource.searchContenidos(
          query,
          categoria: categoria,
          tipo: tipo,
          nivel: nivel,
          page: page,
          limit: limit,
        );
        await localDataSource.cacheSearchResults(query, remoteContenidos);
        final list = remoteContenidos.map((model) => model.toEntity()).toList();
        return Result.success(list);
      } on ServerException {
        final cached = await _getCachedSearchResults(query);
        return Result.success(cached);
      }
    } else {
      final cached = await _getCachedSearchResults(query);
      return Result.success(cached);
    }
  }

  Future<List<Contenido>> _getCachedSearchResults(String query) async {
    try {
      return (await localDataSource.getCachedSearchResults(query))
          .map((model) => model.toEntity()).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<void> toggleFavorito(String contenidoId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.toggleFavorito(contenidoId);
        
        // Actualizar caché local
        final contenido = await _getCachedContenidoById(contenidoId);
        if (contenido != null) {
          final updatedContenido = contenido.copyWith(favorito: !contenido.favorito);
          await localDataSource.cacheContenido(ContenidoModel.fromEntity(updatedContenido));
        }
      } on ServerException {
        throw const ServerError('Error al alternar favorito en el servidor');
      }
    } else {
      // Si no hay conexión, registrar para sincronización posterior
      await localDataSource.queueToggleFavorito(contenidoId);
      
      // Actualizar localmente
      final contenido = await _getCachedContenidoById(contenidoId);
      if (contenido != null) {
        final updatedContenido = contenido.copyWith(favorito: !contenido.favorito);
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(updatedContenido));
      }
    }
  }

  @override
  Future<void> registrarVista(String contenidoId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.registrarVista(contenidoId);
      } on ServerException {
        // Si falla el servidor, registrar para sincronización posterior
        await localDataSource.queueRegistrarVista(contenidoId);
      }
    } else {
      // Si no hay conexión, registrar para sincronización posterior
      await localDataSource.queueRegistrarVista(contenidoId);
    }
  }

  @override
  Future<void> actualizarProgreso(
    String contenidoId, {
    int? tiempoVisualizado,
    double? porcentaje,
    bool? completado,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.actualizarProgreso(
          contenidoId,
          tiempoVisualizado: tiempoVisualizado,
          porcentaje: porcentaje,
          completado: completado,
        );
      } on ServerException {
        // Si falla el servidor, registrar para sincronización posterior
        await localDataSource.queueActualizarProgreso(
          contenidoId,
          tiempoVisualizado: tiempoVisualizado,
          porcentaje: porcentaje,
          completado: completado,
        );
      }
    } else {
      // Si no hay conexión, registrar para sincronización posterior
      await localDataSource.queueActualizarProgreso(
        contenidoId,
        tiempoVisualizado: tiempoVisualizado,
        porcentaje: porcentaje,
        completado: completado,
      );
      
      // Actualizar localmente
      final contenido = await _getCachedContenidoById(contenidoId);
      if (contenido != null) {
        final progreso = ProgresoUsuario(
          id: '${contenidoId}_user',
          contenidoId: contenidoId,
          usuarioId: 'current_user', // Debería obtenerse del auth
          tiempoVisualizado: tiempoVisualizado ?? contenido.progreso?.tiempoVisualizado ?? 0,
          porcentaje: porcentaje ?? contenido.progreso?.porcentaje ?? 0.0,
          estaCompletado: completado ?? contenido.progreso?.estaCompletado ?? false,
          createdAt: contenido.progreso?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        final updatedContenido = contenido.copyWith(progreso: progreso);
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(updatedContenido));
      }
    }
  }

  @override
  Future<List<Contenido>> getFavoritos(String usuarioId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContenidos = await remoteDataSource.getFavoritos(usuarioId);
        await localDataSource.cacheFavoritos(usuarioId, remoteContenidos);
        final list = remoteContenidos.map((model) => model.toEntity()).toList();
        return list;
      } on ServerException {
        final cached = await _getCachedFavoritos(usuarioId);
        return cached;
      }
    } else {
      final cached = await _getCachedFavoritos(usuarioId);
      return cached;
    }
  }

  Future<List<Contenido>> _getCachedFavoritos(String usuarioId) async {
    try {
      return (await localDataSource.getCachedFavoritos(usuarioId))
          .map((model) => model.toEntity()).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<List<Contenido>> getContenidosConProgreso(String usuarioId) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContenidos = await remoteDataSource.getContenidosConProgreso(usuarioId);
        await localDataSource.cacheContenidosConProgreso(usuarioId, remoteContenidos);
        final list = remoteContenidos.map((model) => model.toEntity()).toList();
        return list;
      } on ServerException {
        final cached = await _getCachedContenidosConProgreso(usuarioId);
        return cached;
      }
    } else {
      final cached = await _getCachedContenidosConProgreso(usuarioId);
      return cached;
    }
  }

  Future<List<Contenido>> _getCachedContenidosConProgreso(String usuarioId) async {
    try {
      return (await localDataSource.getCachedContenidosConProgreso(usuarioId))
          .map((model) => model.toEntity()).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<List<Categoria>> getCategorias() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategorias = await remoteDataSource.getCategorias();
        await localDataSource.cacheCategorias(remoteCategorias);
        final list = remoteCategorias.map((model) => model.toEntity()).toList();
        return list;
      } on ServerException {
        final cached = await _getCachedCategorias();
        return cached;
      }
    } else {
      final cached = await _getCachedCategorias();
      return cached;
    }
  }

  Future<List<Categoria>> _getCachedCategorias() async {
    try {
      return (await localDataSource.getCachedCategorias())
          .map((model) => model.toEntity()).toList();
    } on CacheException {
      return [];
    }
  }

  @override
  Future<void> clearCache({CategoriaContenido? categoria}) async {
    await localDataSource.clearCache(categoria: categoria);
  }
}
