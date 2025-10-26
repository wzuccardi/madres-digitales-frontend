import '../datasources/contenido_remote_datasource.dart';
import '../datasources/contenido_local_datasource.dart';
import '../models/contenido_model.dart';
import '../../domain/entities/contenido.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/contenido_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

class ContenidoRepositoryImpl implements ContenidoRepository {
  final ContenidoRemoteDataSource remoteDataSource;
  final ContenidoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ContenidoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<List<Contenido>> getContenidos({
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
        
        // Guardar en caché local
        await localDataSource.cacheContenidos(remoteContenidos);
        return remoteContenidos.map((model) => model.toEntity()).toList();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedContenidos(categoria, tipo, nivel);
      }
    } else {
      return await _getCachedContenidos(categoria, tipo, nivel);
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
      throw const CacheFailure('No hay contenidos en caché');
    }
  }

  @override
  Future<Contenido?> getContenidoById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteContenido = await remoteDataSource.getContenidoById(id);
        
        // Actualizar caché local
        await localDataSource.cacheContenido(remoteContenido);
        return remoteContenido.toEntity();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedContenidoById(id);
      }
    } else {
      return await _getCachedContenidoById(id);
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
  Future<Contenido> createContenido({
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
        
        // Actualizar caché local
        final contenido = contenidoModel.toEntity();
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(contenido));
        return contenido;
      } on ServerException {
        throw const ServerFailure('Error al crear contenido en el servidor');
      }
    } else {
      throw const NetworkFailure('Sin conexión a internet');
    }
  }

  @override
  Future<Contenido> updateContenido(
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
        
        // Actualizar caché local
        final contenido = contenidoModel.toEntity();
        await localDataSource.cacheContenido(ContenidoModel.fromEntity(contenido));
        return contenido;
      } on ServerException {
        throw const ServerFailure('Error al actualizar contenido en el servidor');
      }
    } else {
      throw const NetworkFailure('Sin conexión a internet');
    }
  }

  @override
  Future<void> deleteContenido(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteContenido(id);
        
        // Eliminar de caché local
        await localDataSource.deleteCachedContenido(id);
      } on ServerException {
        throw const ServerFailure('Error al eliminar contenido en el servidor');
      }
    } else {
      throw const NetworkFailure('Sin conexión a internet');
    }
  }

  @override
  Future<List<Contenido>> searchContenidos(
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
        
        // Guardar en caché local
        await localDataSource.cacheSearchResults(query, remoteContenidos);
        return remoteContenidos.map((model) => model.toEntity()).toList();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedSearchResults(query);
      }
    } else {
      return await _getCachedSearchResults(query);
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
        throw const ServerFailure('Error al alternar favorito en el servidor');
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
        
        // Guardar en caché local
        await localDataSource.cacheFavoritos(usuarioId, remoteContenidos);
        return remoteContenidos.map((model) => model.toEntity()).toList();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedFavoritos(usuarioId);
      }
    } else {
      return await _getCachedFavoritos(usuarioId);
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
        
        // Guardar en caché local
        await localDataSource.cacheContenidosConProgreso(usuarioId, remoteContenidos);
        return remoteContenidos.map((model) => model.toEntity()).toList();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedContenidosConProgreso(usuarioId);
      }
    } else {
      return await _getCachedContenidosConProgreso(usuarioId);
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
        
        // Guardar en caché local
        await localDataSource.cacheCategorias(remoteCategorias);
        return remoteCategorias.map((model) => model.toEntity()).toList();
      } on ServerException {
        // Si falla el servidor, usar caché local
        return await _getCachedCategorias();
      }
    } else {
      return await _getCachedCategorias();
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