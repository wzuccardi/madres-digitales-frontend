import 'package:dartz/dartz.dart';
import '../../domain/entities/gestante.dart';
import '../../domain/entities/asignacion.dart';
import '../../domain/repositories/gestante_repository.interface.dart';
import '../datasources/gestante_remote_datasource.dart';
import '../datasources/gestante_local_datasource.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';

class GestanteRepositoryImpl implements GestanteRepository {
  final GestanteRemoteDataSource _remoteDataSource;
  final GestanteLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  GestanteRepositoryImpl({
    required GestanteRemoteDataSource remoteDataSource,
    required GestanteLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, Gestante>> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final gestanteModel = await _remoteDataSource.createGestante(
          gestante: gestante,
          madrinaId: madrinaId,
          permisosAdicionales: permisosAdicionales,
        );
        
        // Cachear localmente
        await _localDataSource.cacheGestante(gestanteModel);
        
        return Right(gestanteModel);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      // Modo offline: guardar localmente para sincronizar después
      try {
        final gestanteModel = await _localDataSource.createGestanteForSync(
          gestante: gestante,
          madrinaId: madrinaId,
          permisosAdicionales: permisosAdicionales,
        );
        return Right(gestanteModel);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Gestante>> getGestanteById(String id) async {
    try {
      // Primero intentar desde caché local
      final cachedGestante = await _localDataSource.getGestanteById(id);
      
      if (cachedGestante != null) {
        return Right(cachedGestante);
      }
      
      // Si no está en caché y hay conexión, obtener del servidor
      if (await _networkInfo.isConnected) {
        final gestanteModel = await _remoteDataSource.getGestanteById(id);
        
        // Cachear para uso futuro
        await _localDataSource.cacheGestante(gestanteModel);
        
        return Right(gestanteModel);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, List<Gestante>>> getGestantesAsignadas({
    required String madrinaId,
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
    bool? soloPropias,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final gestantes = await _remoteDataSource.getGestantesAsignadas(
          madrinaId: madrinaId,
          page: page,
          limit: limit,
          search: search,
          soloActivas: soloActivas,
          soloPropias: soloPropias,
          sortBy: sortBy,
          ascending: ascending,
        );
        
        // Cachear resultados
        await _localDataSource.cacheGestantesList(gestantes, madrinaId);
        
        return Right(gestantes);
      } else {
        // Modo offline: obtener desde caché local
        final cachedGestantes = await _localDataSource.getCachedGestantesList(
          madrinaId: madrinaId,
          page: page,
          limit: limit,
        );
        
        if (cachedGestantes.isNotEmpty) {
          return Right(cachedGestantes);
        } else {
          return const Left(NetworkFailure());
        }
      }
    } on ServerException {
      return const Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, Asignacion>> createAsignacion(Asignacion asignacion) async {
    if (await _networkInfo.isConnected) {
      try {
        final asignacionModel = await _remoteDataSource.createAsignacion(asignacion);
        
        // Cachear localmente
        await _localDataSource.cacheAsignacion(asignacionModel);
        
        return Right(asignacionModel);
      } on ServerException {
        return const Left(ServerFailure());
      }
    } else {
      // Modo offline: guardar localmente para sincronizar después
      try {
        final asignacionModel = await _localDataSource.createAsignacionForSync(asignacion);
        return Right(asignacionModel);
      } on CacheException {
        return const Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Asignacion?>> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  }) async {
    try {
      // Primero intentar desde caché local
      final cachedAsignacion = await _localDataSource.getActiveAsignation(
        gestanteId: gestanteId,
        madrinaId: madrinaId,
      );
      
      if (cachedAsignacion != null) {
        return Right(cachedAsignacion);
      }
      
      // Si no está en caché y hay conexión, obtener del servidor
      if (await _networkInfo.isConnected) {
        final asignacion = await _remoteDataSource.getActiveAsignation(
          gestanteId: gestanteId,
          madrinaId: madrinaId,
        );
        
        // Cachear para uso futuro
        if (asignacion != null) {
          await _localDataSource.cacheAsignacion(asignacion);
        }
        
        return Right(asignacion);
      } else {
        return const Right(null);
      }
    } on ServerException {
      return const Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        return await _remoteDataSource.verifyMadrinaPermission(
          madrinaId: madrinaId,
          gestanteId: gestanteId,
          permiso: permiso,
        );
      } else {
        // Modo offline: verificar desde caché local
        return await _localDataSource.verifyMadrinaPermission(
          madrinaId: madrinaId,
          gestanteId: gestanteId,
          permiso: permiso,
        );
      }
    } catch (e) {
      // En caso de error, denegar permiso por seguridad
      return false;
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMadrinaById(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        final madrina = await _remoteDataSource.getMadrinaById(id);
        return Right(madrina);
      } else {
        // Modo offline: obtener desde caché local
        final madrina = await _localDataSource.getMadrinaById(id);
        if (madrina != null) {
          return Right(madrina);
        } else {
          return const Left(NetworkFailure());
        }
      }
    } on ServerException {
      return const Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  // Implementación de los demás métodos...
  @override
  Future<Either<Failure, List<Gestante>>> getAllGestantes({
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final gestantes = await _remoteDataSource.getAllGestantes(
          page: page,
          limit: limit,
          search: search,
          soloActivas: soloActivas,
        );
        return Right(gestantes);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Gestante>> updateGestante(Gestante gestante) async {
    try {
      if (await _networkInfo.isConnected) {
        final gestanteActualizada = await _remoteDataSource.updateGestante(gestante);
        
        // Actualizar caché
        await _localDataSource.cacheGestante(gestanteActualizada);
        
        return Right(gestanteActualizada);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deleteGestante(String id) async {
    try {
      if (await _networkInfo.isConnected) {
        final resultado = await _remoteDataSource.deleteGestante(id);
        
        if (resultado) {
          // Eliminar de caché local
          // Aquí iría la implementación para eliminar de la caché local
        }
        
        return Right(resultado);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByGestante(String gestanteId) async {
    try {
      if (await _networkInfo.isConnected) {
        final asignaciones = await _remoteDataSource.getAsignacionesByGestante(gestanteId);
        return Right(asignaciones);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByMadrina(String madrinaId) async {
    try {
      if (await _networkInfo.isConnected) {
        final asignaciones = await _remoteDataSource.getAsignacionesByMadrina(madrinaId);
        return Right(asignaciones);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> deactivatePrincipalAssignments(String gestanteId) async {
    try {
      if (await _networkInfo.isConnected) {
        final resultado = await _remoteDataSource.deactivatePrincipalAssignments(gestanteId);
        return Right(resultado);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<bool> verifyMadrinaPermissions({
    required String madrinaId,
    required String permiso,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        return await _remoteDataSource.verifyMadrinaPermissions(
          madrinaId: madrinaId,
          permiso: permiso,
        );
      } else {
        // Modo offline: verificar desde caché local
        // Aquí iría la implementación para verificar desde caché local
        return false;
      }
    } catch (e) {
      // En caso de error, denegar permiso por seguridad
      return false;
    }
  }

  @override
  Future<bool> verifyUserPermissions({
    required String userId,
    required String permiso,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        return await _remoteDataSource.verifyUserPermissions(
          userId: userId,
          permiso: permiso,
        );
      } else {
        // Modo offline: verificar desde caché local
        // Aquí iría la implementación para verificar desde caché local
        return false;
      }
    } catch (e) {
      // En caso de error, denegar permiso por seguridad
      return false;
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableMadrinas() async {
    try {
      if (await _networkInfo.isConnected) {
        final madrinas = await _remoteDataSource.getAvailableMadrinas();
        return Right(madrinas);
      } else {
        return const Left(NetworkFailure());
      }
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}

// Excepciones personalizadas
class ServerException implements Exception {}

class CacheException implements Exception {}

class NetworkException implements Exception {}