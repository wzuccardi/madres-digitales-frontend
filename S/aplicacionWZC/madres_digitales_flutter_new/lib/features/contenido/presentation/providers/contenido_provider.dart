import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import '../../domain/entities/categoria.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
// import removido por no uso
import 'package:madres_digitales_flutter_new/features/contenido/data/repositories/contenido_repository_impl.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_remote_datasource.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_local_datasource.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/core/network/simple_network_info.dart';

enum ContenidoSimpleStatus {
  initial,
  loading,
  success,
  failure,
}

class ContenidoSimpleState extends Equatable {

  const ContenidoSimpleState({
    this.status = ContenidoSimpleStatus.initial,
    this.contenidos = const [],
    this.searchResults = const [],
    this.selectedContenido,
    this.error,
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.categorias = const [],
  });
  final ContenidoSimpleStatus status;
  final List<Contenido> contenidos;
  final List<Contenido> searchResults;
  final Contenido? selectedContenido;
  final String? error;
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
  final bool hasReachedMax;
  final bool isRefreshing;
  final List<Categoria> categorias;

  ContenidoSimpleState copyWith({
    ContenidoSimpleStatus? status,
    List<Contenido>? contenidos,
    List<Contenido>? searchResults,
    Contenido? selectedContenido,
    String? error,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int? page,
    int? limit,
    bool? hasReachedMax,
    bool? isRefreshing,
    List<Categoria>? categorias,
  }) {
    return ContenidoSimpleState(
      status: status ?? this.status,
      contenidos: contenidos ?? this.contenidos,
      searchResults: searchResults ?? this.searchResults,
      selectedContenido: selectedContenido ?? this.selectedContenido,
      error: error ?? this.error,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      categorias: categorias ?? this.categorias,
    );
  }

  @override
  List<Object?> get props => [
        status,
        contenidos,
        searchResults,
        selectedContenido,
        error,
        categoria,
        tipo,
        nivel,
        page,
        limit,
        hasReachedMax,
        isRefreshing,
        categorias,
      ];
}

class ContenidoSimpleNotifier extends StateNotifier<ContenidoSimpleState> {

  ContenidoSimpleNotifier({
    required GetContenidosUseCase getContenidosUseCase,
  })  : _getContenidosUseCase = getContenidosUseCase,
        super(const ContenidoSimpleState());
  final GetContenidosUseCase _getContenidosUseCase;

  Future<void> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    if (page == 1) {
      state = state.copyWith(
        status: ContenidoSimpleStatus.loading,
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
        page: page,
        limit: limit,
        hasReachedMax: false,
      );
    } else {
      state = state.copyWith(
        status: ContenidoSimpleStatus.loading,
        isRefreshing: true,
      );
    }

    try {
      final params = GetContenidosParams(
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
        page: page,
        limit: limit,
        forceRefresh: forceRefresh,
      );

      final result = await _getContenidosUseCase(params);
      if (result.isFailure) {
        state = state.copyWith(
          status: ContenidoSimpleStatus.failure,
          error: result.errorOrThrow.message,
          isRefreshing: false,
        );
        return;
      }
      final contenidos = result.dataOrThrow;

      if (page == 1) {
        state = state.copyWith(
          status: ContenidoSimpleStatus.success,
          contenidos: contenidos,
          hasReachedMax: contenidos.length < limit,
          isRefreshing: false,
        );
      } else {
        final updatedContenidos = [...state.contenidos, ...contenidos];
        state = state.copyWith(
          status: ContenidoSimpleStatus.success,
          contenidos: updatedContenidos,
          hasReachedMax: contenidos.length < limit,
          isRefreshing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ContenidoSimpleStatus.failure,
        error: e.toString(),
        isRefreshing: false,
      );
    }
  }

  Future<void> searchContenidos({
    required String query,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(status: ContenidoSimpleStatus.loading);

    try {
      final params = GetContenidosParams(
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
        page: page,
        limit: limit,
        forceRefresh: true,
      );

      final result = await _getContenidosUseCase(params);
      if (result.isFailure) {
        state = state.copyWith(
          status: ContenidoSimpleStatus.failure,
          error: result.errorOrThrow.message,
        );
        return;
      }
      final contenidos = result.dataOrThrow;
      
      // Filtrar por query
      final filteredContenidos = contenidos
          .where((contenido) => contenido.titulo.toLowerCase().contains(query.toLowerCase()) ||
              contenido.descripcion.toLowerCase().contains(query.toLowerCase()))
          .toList();

      state = state.copyWith(
        status: ContenidoSimpleStatus.success,
        searchResults: filteredContenidos,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoSimpleStatus.failure,
        error: e.toString(),
      );
    }
  }

  void selectContenido(Contenido contenido) {
    state = state.copyWith(selectedContenido: contenido);
  }

  void clearSelectedContenido() {
    state = state.copyWith(selectedContenido: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await getContenidos(
      categoria: state.categoria,
      tipo: state.tipo,
      nivel: state.nivel,
      page: 1,
      limit: state.limit,
      forceRefresh: true,
    );
  }

  Future<void> getCategorias() async {
    try {
      // Simulación de categorías
      final categorias = [
        Categoria(
          id: '1',
          nombre: 'Matemáticas',
          descripcion: 'Contenido de matemáticas',
          icono: 'math',
          color: '#FF5722',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Categoria(
          id: '2',
          nombre: 'Ciencias',
          descripcion: 'Contenido de ciencias',
          icono: 'science',
          color: '#2196F3',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      state = state.copyWith(categorias: categorias);
    } catch (e) {
      state = state.copyWith(
        status: ContenidoSimpleStatus.failure,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = const ContenidoSimpleState();
  }
}

// Provider para el ContenidoSimpleNotifier
final contenidoSimpleProvider = StateNotifierProvider<ContenidoSimpleNotifier, ContenidoSimpleState>((ref) {
  final repo = ContenidoRepositoryImpl(
    remoteDataSource: ContenidoRemoteDataSourceImpl(apiService: ref.watch(apiServiceProvider)),
    localDataSource: ContenidoLocalDataSourceImpl(),
    networkInfo: NetworkInfoImpl(),
  );
  final usecase = GetContenidosUseCase(repo);
  return ContenidoSimpleNotifier(getContenidosUseCase: usecase);
});

// Provider para el repositorio
//
