import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenido_by_id.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/create_contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/search_contenidos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/toggle_favorito.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/registrar_vista.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/actualizar_progreso.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_favoritos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos_con_progreso.dart';
import '../blocs/contenido/contenido_state.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_provider.dart';

class ContenidoController extends StateNotifier<ContenidoState> {
  ContenidoController({
    required this.getContenidosUseCase,
    required this.getContenidoByIdUseCase,
    required this.createContenidoUseCase,
    required this.searchContenidosUseCase,
    required this.toggleFavoritoUseCase,
    required this.registrarVistaUseCase,
    required this.actualizarProgresoUseCase,
    required this.getFavoritosUseCase,
    required this.getContenidosConProgresoUseCase,
  }) : super(const ContenidoState());

  final GetContenidosUseCase getContenidosUseCase;
  final GetContenidoByIdUseCase getContenidoByIdUseCase;
  final CreateContenidoUseCase createContenidoUseCase;
  final SearchContenidosUseCase searchContenidosUseCase;
  final ToggleFavoritoUseCase toggleFavoritoUseCase;
  final RegistrarVistaUseCase registrarVistaUseCase;
  final ActualizarProgresoUseCase actualizarProgresoUseCase;
  final GetFavoritosUseCase getFavoritosUseCase;
  final GetContenidosConProgresoUseCase getContenidosConProgresoUseCase;

  Future<void> loadContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    if (page == 1) {
      state = state.copyWith(
        status: ContenidoStatus.loading,
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
        page: page,
        limit: limit,
        hasReachedMax: false,
      );
    } else {
      state = state.copyWith(status: ContenidoStatus.loading, isRefreshing: true);
    }
    final params = GetContenidosParams(
      categoria: categoria,
      tipo: tipo,
      nivel: nivel,
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
    final result = await getContenidosUseCase(params);
    if (result.isFailure) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: result.errorOrThrow.message,
        isRefreshing: false,
      );
      return;
    }
    final contenidos = result.dataOrThrow;
    if (page == 1) {
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: contenidos,
        hasReachedMax: contenidos.length < limit,
        isRefreshing: false,
      );
    } else {
      final updated = [...state.contenidos, ...contenidos];
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: updated,
        hasReachedMax: contenidos.length < limit,
        isRefreshing: false,
      );
    }
  }

  Future<void> loadContenidoById(String id) async {
    state = state.copyWith(status: ContenidoStatus.loading);
    final result = await getContenidoByIdUseCase(id);
    if (result.isFailure) {
      state = state.copyWith(status: ContenidoStatus.failure, error: result.errorOrThrow.message);
      return;
    }
    state = state.copyWith(status: ContenidoStatus.success, selectedContenido: result.dataOrThrow);
  }

  Future<void> createContenido(CreateContenidoParams params) async {
    state = state.copyWith(status: ContenidoStatus.loading);
    final result = await createContenidoUseCase(params);
    if (result.isFailure) {
      state = state.copyWith(status: ContenidoStatus.failure, error: result.errorOrThrow.message);
      return;
    }
    final contenido = result.dataOrThrow;
    final updated = [contenido, ...state.contenidos];
    state = state.copyWith(status: ContenidoStatus.success, contenidos: updated, selectedContenido: contenido);
  }

  Future<void> searchContenidos(String query, {Map<String, dynamic>? filters}) async {
    state = state.copyWith(status: ContenidoStatus.loading);
    final params = SearchContenidosParams(
      query: query,
      categoria: filters?['categoria'],
      tipo: filters?['tipo'],
      nivel: filters?['nivel'],
      page: filters?['page'] ?? 1,
      limit: filters?['limit'] ?? 20,
    );
    final result = await searchContenidosUseCase(params);
    if (result.isFailure) {
      state = state.copyWith(status: ContenidoStatus.failure, error: result.errorOrThrow.message);
      return;
    }
    state = state.copyWith(
      status: ContenidoStatus.success,
      searchResults: result.dataOrThrow,
      searchQuery: query,
    );
  }

  Future<void> toggleFavorito(String id) async {
    await toggleFavoritoUseCase(id);
    final updated = state.contenidos.map((c) => c.id == id ? c.copyWith(favorito: !c.favorito) : c).toList();
    Contenido? selected = state.selectedContenido;
    if (selected?.id == id) {
      selected = selected!.copyWith(favorito: !selected.favorito);
    }
    state = state.copyWith(contenidos: updated, selectedContenido: selected);
  }

  Future<void> registrarVista(String id) async {
    await registrarVistaUseCase(id);
  }

  Future<void> actualizarProgreso(String id, Map<String, dynamic> params) async {
    final ap = ActualizarProgresoParams(
      contenidoId: id,
      tiempoVisualizado: params['tiempoVisualizado'],
      porcentaje: params['porcentaje'],
      completado: params['completado'],
    );
    await actualizarProgresoUseCase(ap);
  }

  Future<void> getFavoritos(String usuarioId) async {
    final contenidos = await getFavoritosUseCase(usuarioId);
    state = state.copyWith(status: ContenidoStatus.success, contenidos: contenidos);
  }

  Future<void> getContenidosConProgreso(String usuarioId) async {
    final contenidos = await getContenidosConProgresoUseCase(usuarioId);
    state = state.copyWith(status: ContenidoStatus.success, contenidos: contenidos);
  }
}

final contenidoControllerProvider = StateNotifierProvider<ContenidoController, ContenidoState>((ref) {
  return ContenidoController(
    getContenidosUseCase: ref.watch(getContenidosUseCaseProvider),
    getContenidoByIdUseCase: ref.watch(getContenidoByIdUseCaseProvider),
    createContenidoUseCase: ref.watch(createContenidoUseCaseProvider),
    searchContenidosUseCase: ref.watch(searchContenidosUseCaseProvider),
    toggleFavoritoUseCase: ref.watch(toggleFavoritoUseCaseProvider),
    registrarVistaUseCase: ref.watch(registrarVistaUseCaseProvider),
    actualizarProgresoUseCase: ref.watch(actualizarProgresoUseCaseProvider),
    getFavoritosUseCase: ref.watch(getFavoritosUseCaseProvider),
    getContenidosConProgresoUseCase: ref.watch(getContenidosConProgresoUseCaseProvider),
  );
});