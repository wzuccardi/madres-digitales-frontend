import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/create_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/update_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/delete_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/assign_gestante_to_madrina_usecase.dart';
import 'package:madres_digitales_flutter_new/application/di/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';


// Estado de gestantes
class GestanteState {

  const GestanteState({
    required this.gestantes,
    this.isLoading = false,
    this.error,
    this.searchQuery,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });
  final List<Gestante> gestantes;
  final bool isLoading;
  final AppError? error;
  final String? searchQuery;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  GestanteState copyWith({
    List<Gestante>? gestantes,
    bool? isLoading,
    AppError? error,
    String? searchQuery,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return GestanteState(
      gestantes: gestantes ?? this.gestantes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GestanteState &&
        other.gestantes == gestantes &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.searchQuery == searchQuery &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalItems == totalItems;
  }

  @override
  int get hashCode => Object.hash(
        gestantes,
        isLoading,
        error,
        searchQuery,
        currentPage,
        totalPages,
        totalItems,
      );

  @override
  String toString() {
    return 'GestanteState(gestantes: ${gestantes.length}, isLoading: $isLoading, error: $error, searchQuery: $searchQuery, currentPage: $currentPage, totalPages: $totalPages, totalItems: $totalItems)';
  }
}

// Provider de gestantes consolidado usando casos de uso
class GestanteProvider extends StateNotifier<GestanteState> {

  GestanteProvider({
    required GetGestantesUseCase getGestantesUseCase,
    required CreateGestanteUseCase createGestanteUseCase,
    required UpdateGestanteUseCase updateGestanteUseCase,
    required DeleteGestanteUseCase deleteGestanteUseCase,
    required AssignGestanteToMadrinaUseCase assignGestanteToMadrinaUseCase,
  })  : _getGestantesUseCase = getGestantesUseCase,
        _createGestanteUseCase = createGestanteUseCase,
        _updateGestanteUseCase = updateGestanteUseCase,
        _deleteGestanteUseCase = deleteGestanteUseCase,
        _assignGestanteToMadrinaUseCase = assignGestanteToMadrinaUseCase,
        super(const GestanteState(
          gestantes: [],
          isLoading: false,
        ));
  final GetGestantesUseCase _getGestantesUseCase;
  final CreateGestanteUseCase _createGestanteUseCase;
  final UpdateGestanteUseCase _updateGestanteUseCase;
  final DeleteGestanteUseCase _deleteGestanteUseCase;
  final AssignGestanteToMadrinaUseCase _assignGestanteToMadrinaUseCase;

  // Obtener todas las gestantes
  Future<void> getGestantes({
    String? madrinaId,
    int limit = AppConstants.defaultPageSize,
    int offset = 0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = GetGestantesParams(
        madrinaId: madrinaId,
        limit: limit,
        offset: offset,
      );
      final result = await _getGestantesUseCase(params);
      if (result.isSuccess) {
        final gestantes = result.data ?? const <Gestante>[];
        state = state.copyWith(
          isLoading: false,
          gestantes: gestantes,
          currentPage: (offset ~/ limit) + 1,
          totalPages: (gestantes.length / limit).ceil(),
          totalItems: gestantes.length,
        );
        AppLogger.info('Gestantes obtenidas: ${gestantes.length}');
      } else {
        final e = result.error!;
        state = state.copyWith(isLoading: false, error: e);
        AppLogger.error('Error obteniendo gestantes: ${e.message}');
      }
      
      AppLogger.info('Gestantes obtenidas: ${gestantes.length}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error obteniendo gestantes: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción obteniendo gestantes: $e');
    }
  }

  // Crear una nueva gestante
  Future<bool> createGestante(Gestante gestante) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = CreateGestanteParams(
        nombre: gestante.nombre,
        apellido: gestante.apellido,
        telefono: gestante.telefono,
        email: gestante.email,
        documento: gestante.documento,
        direccion: gestante.direccion,
        eps: gestante.eps,
        activa: gestante.activa,
        riesgoAlto: gestante.riesgoAlto,
        fechaNacimiento: gestante.fechaNacimiento,
        fechaProbableParto: gestante.fechaProbableParto,
        creadaPor: gestante.creadaPor,
      );
      final result = await _createGestanteUseCase(params);
      final newGestante = result.dataOrThrow;
      
      // Actualizar la lista local
      final updatedGestantes = [...state.gestantes, newGestante];
      
      state = state.copyWith(
        isLoading: false,
        gestantes: updatedGestantes,
        totalItems: updatedGestantes.length,
      );
      
      AppLogger.info('Gestante creada: ${newGestante.nombreCompleto}');
      return true;
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error creando gestante: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción creando gestante: $e');
      return false;
    }
  }

  // Actualizar una gestante existente
  Future<void> updateGestante(Gestante gestante) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = UpdateGestanteParams(
        id: gestante.id,
        nombre: gestante.nombre,
        apellido: gestante.apellido,
        telefono: gestante.telefono,
        email: gestante.email,
        documento: gestante.documento,
        direccion: gestante.direccion,
        eps: gestante.eps,
        activa: gestante.activa,
        riesgoAlto: gestante.riesgoAlto,
        fechaNacimiento: gestante.fechaNacimiento,
        fechaProbableParto: gestante.fechaProbableParto,
      );
      final result = await _updateGestanteUseCase(params);
      final updatedGestante = result.dataOrThrow;
      
      // Actualizar la gestante en la lista local
      final updatedGestantes = state.gestantes.map((g) => g.id == gestante.id ? updatedGestante : g).toList();
      
      state = state.copyWith(
        isLoading: false,
        gestantes: updatedGestantes,
      );
      
      AppLogger.info('Gestante actualizada: ${updatedGestante.nombreCompleto}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error actualizando gestante: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción actualizando gestante: $e');
    }
  }

  // Eliminar una gestante
  Future<void> deleteGestante(String gestanteId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = DeleteGestanteParams(id: gestanteId);
      
      final result = await _deleteGestanteUseCase(params);
      result.dataOrThrow;
      
      // Actualizar la lista local
      final updatedGestantes = state.gestantes.where((g) => g.id != gestanteId).toList();
      
      state = state.copyWith(
        isLoading: false,
        gestantes: updatedGestantes,
        totalItems: updatedGestantes.length,
      );
      
      AppLogger.info('Gestante eliminada: $gestanteId');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error eliminando gestante: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción eliminando gestante: $e');
    }
  }

  // Asignar una gestante a una madrina
  Future<bool> assignGestanteToMadrina({required String gestanteId, required String madrinaId}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final params = AssignGestanteToMadrinaParams(
        gestanteId: gestanteId,
        madrinaId: madrinaId,
      );
      
      final result = await _assignGestanteToMadrinaUseCase(params);
      result.dataOrThrow;
      
      // Actualizar la lista local
      final updatedGestantes = state.gestantes.map((g) => g.id == gestanteId ? g.copyWith(madrinaId: madrinaId) : g).toList();
      
      state = state.copyWith(
        isLoading: false,
        gestantes: updatedGestantes,
      );
      
      AppLogger.info('Gestante $gestanteId asignada a madrina $madrinaId');
      return true;
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error asignando gestante: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción asignando gestante: $e');
      return false;
    }
  }

  // Buscar gestantes
  Future<void> searchGestantes(String query, {String? madrinaId}) async {
    state = state.copyWith(
      isLoading: true,
      searchQuery: query,
      error: null,
    );
    
    try {
      final params = GetGestantesParams(
        madrinaId: madrinaId,
        limit: AppConstants.defaultPageSize,
        offset: 0,
      );
      final result = await _getGestantesUseCase(params);
      if (result.isSuccess) {
        final gestantes = result.data ?? const <Gestante>[];
        state = state.copyWith(
          isLoading: false,
          gestantes: gestantes,
          searchQuery: query,
          currentPage: 1,
          totalPages: (gestantes.length / AppConstants.defaultPageSize).ceil(),
          totalItems: gestantes.length,
        );
        AppLogger.info('Búsqueda realizada: $query, resultados: ${gestantes.length}');
      } else {
        final e = result.error!;
        state = state.copyWith(isLoading: false, error: e);
        AppLogger.error('Error en búsqueda: ${e.message}');
      }
      
      AppLogger.info('Búsqueda realizada: $query, resultados: ${gestantes.length}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error en búsqueda: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción en búsqueda: $e');
    }
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Obtener gestantes paginadas
  Future<void> getGestantesPaginated(int page, {String? madrinaId}) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final params = GetGestantesParams(
        madrinaId: madrinaId,
        limit: AppConstants.defaultPageSize,
        offset: (page - 1) * AppConstants.defaultPageSize,
      );
      final result = await _getGestantesUseCase(params);
      if (result.isSuccess) {
        final gestantes = result.data ?? const <Gestante>[];
        state = state.copyWith(
          isLoading: false,
          gestantes: gestantes,
          currentPage: page,
          totalPages: (gestantes.length / AppConstants.defaultPageSize).ceil(),
          totalItems: gestantes.length,
        );
        AppLogger.info('Gestantes página $page obtenidas: ${gestantes.length}');
      } else {
        final e = result.error!;
        state = state.copyWith(isLoading: false, error: e);
        AppLogger.error('Error obteniendo gestantes página $page: ${e.message}');
      }
      
      AppLogger.info('Gestantes página $page obtenidas: ${gestantes.length}');
    } on AppError catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      
      AppLogger.error('Error obteniendo gestantes página $page: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: NetworkError(e.toString()),
      );
      
      AppLogger.error('Excepción obteniendo gestantes página $page: $e');
    }
  }

  // Getters
  List<Gestante> get gestantes => state.gestantes;
  bool get isLoading => state.isLoading;
  AppError? get error => state.error;
  String? get searchQuery => state.searchQuery;
  int get currentPage => state.currentPage;
  int get totalPages => state.totalPages;
  int get totalItems => state.totalItems;
}

// Providers
final gestanteProvider = StateNotifierProvider<GestanteProvider, GestanteState>((ref) {
  final getGestantesUseCase = ref.read(getGestantesUseCaseProvider);
  final createGestanteUseCase = ref.read(createGestanteUseCaseProvider);
  final updateGestanteUseCase = ref.read(updateGestanteUseCaseProvider);
  final deleteGestanteUseCase = ref.read(deleteGestanteUseCaseProvider);
  final assignGestanteToMadrinaUseCase = ref.read(assignGestanteToMadrinaUseCaseProvider);

  return GestanteProvider(
    getGestantesUseCase: getGestantesUseCase,
    createGestanteUseCase: createGestanteUseCase,
    updateGestanteUseCase: updateGestanteUseCase,
    deleteGestanteUseCase: deleteGestanteUseCase,
    assignGestanteToMadrinaUseCase: assignGestanteToMadrinaUseCase,
  );
});

// Provider combinado que obtiene las gestantes filtradas por la madrina logueada
final gestantesByMadrinaProvider = Provider<Future<void> Function()>((ref) {
  final gestanteNotifier = ref.read(gestanteProvider.notifier);
  final authState = ref.watch(authProvider);
  
  return () async {
    final madrinaId = authState.user?.id;
    if (madrinaId != null) {
      await gestanteNotifier.getGestantes(madrinaId: madrinaId);
    } else {
      await gestanteNotifier.getGestantes();
    }
  };
});
