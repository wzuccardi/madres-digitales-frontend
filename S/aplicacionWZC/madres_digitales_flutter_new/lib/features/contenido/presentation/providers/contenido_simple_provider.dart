import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_provider.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/search_contenidos.dart';

enum ContenidoStatus { initial, loading, success, failure }

class ContenidoSimpleState {
  const ContenidoSimpleState({
    this.status = ContenidoStatus.initial,
    this.contenidos = const [],
    this.error,
    this.hasReachedMax = false,
    this.page = 1,
    this.limit = 20,
    this.categoria,
    this.tipo,
    this.nivel,
    this.selected,
  });
  final ContenidoStatus status;
  final List<Contenido> contenidos;
  final String? error;
  final bool hasReachedMax;
  final int page;
  final int limit;
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final Contenido? selected;

  ContenidoSimpleState copyWith({
    ContenidoStatus? status,
    List<Contenido>? contenidos,
    String? error,
    bool? hasReachedMax,
    int? page,
    int? limit,
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    Contenido? selected,
  }) {
    return ContenidoSimpleState(
      status: status ?? this.status,
      contenidos: contenidos ?? this.contenidos,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      categoria: categoria ?? this.categoria,
      tipo: tipo ?? this.tipo,
      nivel: nivel ?? this.nivel,
      selected: selected ?? this.selected,
    );
  }
}

class ContenidoSimpleNotifier extends StateNotifier<ContenidoSimpleState> {
  ContenidoSimpleNotifier(this._getContenidos, this._searchContenidos)
      : super(const ContenidoSimpleState());
  final GetContenidosUseCase _getContenidos;
  final SearchContenidosUseCase _searchContenidos;

  Future<void> getContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
  }) async {
    state = state.copyWith(status: ContenidoStatus.loading, page: page, limit: limit, categoria: categoria, tipo: tipo, nivel: nivel);
    final params = GetContenidosParams(categoria: categoria, tipo: tipo, nivel: nivel, page: page, limit: limit, forceRefresh: false);
    final result = await _getContenidos(params);
    if (result.isFailure) {
      state = state.copyWith(status: ContenidoStatus.failure, error: result.errorOrThrow.message);
      return;
    }
    final list = result.dataOrThrow;
    final merged = page == 1 ? list : [...state.contenidos, ...list];
    state = state.copyWith(
      status: ContenidoStatus.success,
      contenidos: merged,
      hasReachedMax: list.length < limit,
    );
  }

  Future<void> refresh() async {
    await getContenidos(page: 1, limit: state.limit, categoria: state.categoria, tipo: state.tipo, nivel: state.nivel);
  }

  void selectContenido(Contenido contenido) {
    state = state.copyWith(selected: contenido);
  }

  Future<void> searchContenidos({required String query}) async {
    state = state.copyWith(status: ContenidoStatus.loading);
    final params = SearchContenidosParams(query: query, page: 1, limit: state.limit, categoria: state.categoria, tipo: state.tipo, nivel: state.nivel);
    final result = await _searchContenidos(params);
    if (result.isFailure) {
      state = state.copyWith(status: ContenidoStatus.failure, error: result.errorOrThrow.message);
      return;
    }
    state = state.copyWith(status: ContenidoStatus.success, contenidos: result.dataOrThrow, page: 1);
  }
}

final contenidoSimpleProvider = StateNotifierProvider<ContenidoSimpleNotifier, ContenidoSimpleState>((ref) {
  final getContenidos = ref.watch(getContenidosUseCaseProvider);
  final searchContenidos = ref.watch(searchContenidosUseCaseProvider);
  return ContenidoSimpleNotifier(getContenidos, searchContenidos);
});