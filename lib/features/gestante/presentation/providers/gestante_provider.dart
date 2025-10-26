import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/gestante.dart';
import '../../domain/entities/asignacion.dart';
import '../../domain/usecases/create_gestante.dart';
import '../../domain/usecases/assign_gestante_to_madrina.dart';
import '../../domain/usecases/get_gestantes_asignadas.dart';
import '../../domain/repositories/gestante_repository.interface.dart';
import '../../../../core/error/failures.dart';

class GestanteState {
  final List<Gestante> gestantes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final Map<String, bool> permisosCache; // gestanteId -> tienePermiso

  const GestanteState({
    this.gestantes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.permisosCache = const {},
  });

  GestanteState copyWith({
    List<Gestante>? gestantes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    String? error,
    Map<String, bool>? permisosCache,
  }) {
    return GestanteState(
      gestantes: gestantes ?? this.gestantes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      permisosCache: permisosCache ?? this.permisosCache,
    );
  }
}

class GestanteNotifier extends StateNotifier<GestanteState> {
  final GestanteRepository _repository;
  final CreateGestante _createGestante;
  final AssignGestanteToMadrina _assignGestanteToMadrina;
  final GetGestantesAsignadas _getGestantesAsignadas;

  GestanteNotifier(
    this._repository,
    this._createGestante,
    this._assignGestanteToMadrina,
    this._getGestantesAsignadas,
  ) : super(const GestanteState());

  Future<void> getGestantesAsignadas({
    required String madrinaId,
    int? page,
    int? limit,
    String? search,
    bool? soloActivas,
    bool? soloPropias,
    String? sortBy,
    bool? ascending,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        gestantes: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    } else if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: refresh ? true : state.isLoading,
      isLoadingMore: !refresh,
    );

    try {
      final result = await _getGestantesAsignadas(
        madrinaId: madrinaId,
        page: page,
        limit: limit ?? 20,
        search: search,
        soloActivas: soloActivas,
        soloPropias: soloPropias,
        sortBy: sortBy,
        ascending: ascending ?? true,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            error: failure.toString(),
          );
        },
        (nuevasGestantes) {
          final gestantesActualizadas = refresh 
              ? nuevasGestantes 
              : [...state.gestantes, ...nuevasGestantes];
          
          state = state.copyWith(
            isLoading: false,
            isLoadingMore: false,
            gestantes: gestantesActualizadas,
            currentPage: page + 1,
            hasMore: nuevasGestantes.length == (limit ?? 20),
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    try {
      final result = await _createGestante(
        gestante: gestante,
        madrinaId: madrinaId,
        permisosAdicionales: permisosAdicionales,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.toString());
          return false;
        },
        (gestanteCreada) {
          // Agregar a la lista local
          final gestantesActualizadas = [gestanteCreada, ...state.gestantes];
          
          // Actualizar caché de permisos
          final nuevosPermisos = Map<String, bool>.from(state.permisosCache);
          nuevosPermisos[gestanteCreada.id] = true; // La propietaria tiene todos los permisos
          
          state = state.copyWith(
            gestantes: gestantesActualizadas,
            permisosCache: nuevosPermisos,
          );
          
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> assignGestanteToMadrina({
    required String gestanteId,
    required String madrinaId,
    required String asignadoPor,
    TipoAsignacion tipo = TipoAsignacion.manual,
    bool esPrincipal = false,
    int prioridad = 3,
  }) async {
    try {
      final result = await _assignGestanteToMadrina(
        gestanteId: gestanteId,
        madrinaId: madrinaId,
        asignadoPor: asignadoPor,
        tipo: tipo,
        esPrincipal: esPrincipal,
        prioridad: prioridad,
      );

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.toString());
          return false;
        },
        (_) {
          // Actualizar la lista local si es necesario
          _refreshGestantes(madrinaId);
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateGestante({
    required Gestante gestante,
    required String madrinaId,
  }) async {
    try {
      // Verificar permisos
      final tienePermiso = await _repository.verifyMadrinaPermission(
        madrinaId: madrinaId,
        gestanteId: gestante.id,
        permiso: 'editar',
      );

      if (!tienePermiso) {
        return false;
      }

      final result = await _repository.updateGestante(gestante);

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.toString());
          return false;
        },
        (_) {
          // Actualizar en la lista local
          final index = state.gestantes.indexWhere((g) => g.id == gestante.id);
          if (index != -1) {
            final gestantesActualizadas = List<Gestante>.from(state.gestantes);
            gestantesActualizadas[index] = gestante;
            state = state.copyWith(gestantes: gestantesActualizadas);
          }
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteGestante({
    required String gestanteId,
    required String madrinaId,
  }) async {
    try {
      // Verificar permisos
      final tienePermiso = await _repository.verifyMadrinaPermission(
        madrinaId: madrinaId,
        gestanteId: gestanteId,
        permiso: 'eliminar',
      );

      if (!tienePermiso) {
        return false;
      }

      final result = await _repository.deleteGestante(gestanteId);

      return result.fold(
        (failure) {
          state = state.copyWith(error: failure.toString());
          return false;
        },
        (_) {
          // Eliminar de la lista local
          final gestantesActualizadas = state.gestantes
              .where((g) => g.id != gestanteId)
              .toList();
          
          // Eliminar del caché de permisos
          final nuevosPermisos = Map<String, bool>.from(state.permisosCache);
          nuevosPermisos.remove(gestanteId);
          
          state = state.copyWith(
            gestantes: gestantesActualizadas,
            permisosCache: nuevosPermisos,
          );
          
          return true;
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<List<Gestante>> searchGestantes(String query) async {
    try {
      // Aquí iría la lógica de búsqueda
      // Por ahora, filtrado simple
      final resultados = state.gestantes.where((gestante) {
        final queryLower = query.toLowerCase();
        return gestante.nombreCompleto.toLowerCase().contains(queryLower) ||
               gestante.numeroDocumento.toLowerCase().contains(queryLower);
      }).toList();

      return resultados;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<void> _refreshGestantes(String madrinaId) async {
    await getGestantesAsignadas(
      madrinaId: madrinaId,
      refresh: true,
    );
  }

  void limpiarError() {
    state = state.copyWith(error: null);
  }
}

// Providers
// Implementación temporal para evitar errores
class MockGestanteRepository implements GestanteRepository {
  @override
  Future<Either<Failure, Gestante>> createGestante({
    required Gestante gestante,
    required String madrinaId,
    Set<TipoPermiso>? permisosAdicionales,
  }) async {
    return Right(gestante);
  }

  @override
  Future<Either<Failure, Gestante>> getGestanteById(String id) async {
    // Implementación temporal
    return const Left(ServerFailure());
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
    return const Right([]);
  }

  @override
  Future<Either<Failure, Asignacion>> createAsignacion(Asignacion asignacion) async {
    return Right(asignacion);
  }

  @override
  Future<Either<Failure, Asignacion?>> getActiveAsignation({
    required String gestanteId,
    required String madrinaId,
  }) async {
    return const Right(null);
  }

  @override
  Future<bool> verifyMadrinaPermission({
    required String madrinaId,
    required String gestanteId,
    required String permiso,
  }) async {
    return true;
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMadrinaById(String id) async {
    return const Right({});
  }

  @override
  Future<Either<Failure, List<Gestante>>> getAllGestantes({
    int page = 1,
    int limit = 20,
    String? search,
    bool? soloActivas,
  }) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Gestante>> updateGestante(Gestante gestante) async {
    return Right(gestante);
  }

  @override
  Future<Either<Failure, bool>> deleteGestante(String id) async {
    return const Right(true);
  }

  @override
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByGestante(String gestanteId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Asignacion>>> getAsignacionesByMadrina(String madrinaId) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, bool>> deactivatePrincipalAssignments(String gestanteId) async {
    return const Right(true);
  }

  @override
  Future<bool> verifyMadrinaPermissions({
    required String madrinaId,
    required String permiso,
  }) async {
    return true;
  }

  @override
  Future<bool> verifyUserPermissions({
    required String userId,
    required String permiso,
  }) async {
    return true;
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAvailableMadrinas() async {
    return const Right([]);
  }
}

final gestanteRepositoryProvider = Provider<GestanteRepository>((ref) {
  // Implementación temporal para evitar errores
  return MockGestanteRepository();
});

final createGestanteProvider = Provider<CreateGestante>((ref) {
  final repository = ref.read(gestanteRepositoryProvider);
  return CreateGestante(repository);
});

final assignGestanteToMadrinaProvider = Provider<AssignGestanteToMadrina>((ref) {
  final repository = ref.read(gestanteRepositoryProvider);
  return AssignGestanteToMadrina(repository);
});

final getGestantesAsignadasProvider = Provider<GetGestantesAsignadas>((ref) {
  final repository = ref.read(gestanteRepositoryProvider);
  return GetGestantesAsignadas(repository);
});

final gestanteProvider = StateNotifierProvider<GestanteNotifier, GestanteState>((ref) {
  final repository = ref.read(gestanteRepositoryProvider);
  final createGestante = ref.read(createGestanteProvider);
  final assignGestanteToMadrina = ref.read(assignGestanteToMadrinaProvider);
  final getGestantesAsignadas = ref.read(getGestantesAsignadasProvider);
  
  return GestanteNotifier(
    repository,
    createGestante,
    assignGestanteToMadrina,
    getGestantesAsignadas,
  );
});