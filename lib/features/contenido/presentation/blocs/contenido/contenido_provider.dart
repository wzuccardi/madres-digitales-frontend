import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'contenido_bloc.dart';
import 'contenido_event.dart';
import 'contenido_state.dart';
import '../../../domain/entities/contenido.dart';
import '../../../domain/usecases/get_contenidos.dart';
import '../../../domain/usecases/get_contenido_by_id.dart';
import '../../../domain/usecases/create_contenido.dart';
import '../../../domain/usecases/search_contenidos.dart';
import '../../../domain/usecases/toggle_favorito.dart';
import '../../../domain/usecases/registrar_vista.dart';
import '../../../domain/usecases/actualizar_progreso.dart';
import '../../../domain/usecases/get_favoritos.dart';
import '../../../domain/usecases/get_contenidos_con_progreso.dart';
import '../../../domain/repositories/contenido_repository.dart';
import '../../../data/repositories/contenido_repository_impl.dart';
import '../../../data/datasources/contenido_remote_datasource.dart';
import '../../../data/datasources/contenido_local_datasource.dart';
import '../../../../../providers/service_providers.dart';
import '../../../../../core/network/network_info.dart';

// Provider para el datasource remoto
final contenidoRemoteDatasourceProvider = Provider<ContenidoRemoteDataSource>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ContenidoRemoteDataSourceImpl(apiService: apiService);
});

// Provider para el datasource local
final contenidoLocalDatasourceProvider = Provider<ContenidoLocalDataSource>((ref) {
  return ContenidoLocalDataSourceImpl();
});

// Provider para NetworkInfo
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = Connectivity();
  return NetworkInfoImpl(connectivity);
});

// Provider para el repositorio de contenido
final contenidoRepositoryProvider = Provider<ContenidoRepository>((ref) {
  return ContenidoRepositoryImpl(
    remoteDataSource: ref.watch(contenidoRemoteDatasourceProvider),
    localDataSource: ref.watch(contenidoLocalDatasourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// Providers para los casos de uso
final getContenidosUseCaseProvider = Provider<GetContenidosUseCase>((ref) {
  return GetContenidosUseCase(ref.watch(contenidoRepositoryProvider));
});

final getContenidoByIdUseCaseProvider = Provider<GetContenidoByIdUseCase>((ref) {
  return GetContenidoByIdUseCase(ref.watch(contenidoRepositoryProvider));
});

final createContenidoUseCaseProvider = Provider<CreateContenidoUseCase>((ref) {
  return CreateContenidoUseCase(ref.watch(contenidoRepositoryProvider));
});

final searchContenidosUseCaseProvider = Provider<SearchContenidosUseCase>((ref) {
  return SearchContenidosUseCase(ref.watch(contenidoRepositoryProvider));
});

final toggleFavoritoUseCaseProvider = Provider<ToggleFavoritoUseCase>((ref) {
  return ToggleFavoritoUseCase(ref.watch(contenidoRepositoryProvider));
});

final registrarVistaUseCaseProvider = Provider<RegistrarVistaUseCase>((ref) {
  return RegistrarVistaUseCase(ref.watch(contenidoRepositoryProvider));
});

final actualizarProgresoUseCaseProvider = Provider<ActualizarProgresoUseCase>((ref) {
  return ActualizarProgresoUseCase(ref.watch(contenidoRepositoryProvider));
});

final getFavoritosUseCaseProvider = Provider<GetFavoritosUseCase>((ref) {
  return GetFavoritosUseCase(ref.watch(contenidoRepositoryProvider));
});

final getContenidosConProgresoUseCaseProvider = Provider<GetContenidosConProgresoUseCase>((ref) {
  return GetContenidosConProgresoUseCase(ref.watch(contenidoRepositoryProvider));
});

// Provider para el BLoC de contenido
final contenidoBlocProvider = StateNotifierProvider<ContenidoBloc, ContenidoState>((ref) {
  return ContenidoBloc(
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

// Extension para facilitar el acceso a los eventos del BLoC
extension ContenidoBlocExtension on WidgetRef {
  void loadContenidos({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool useCache = true,
    bool forceRefresh = false,
  }) {
    read(contenidoBlocProvider.notifier).mapEventToState(
      LoadContenidosEvent(
        categoria: categoria,
        tipo: tipo,
        nivel: nivel,
        page: page,
        limit: limit,
        useCache: useCache,
        forceRefresh: forceRefresh,
      ),
    );
  }

  void loadContenidoById(String id) {
    read(contenidoBlocProvider.notifier).mapEventToState(LoadContenidoByIdEvent(id));
  }

  void createContenido(CreateContenidoParams params) {
    read(contenidoBlocProvider.notifier).mapEventToState(CreateContenidoEvent(params: params));
  }

  void updateContenido(String id, CreateContenidoParams params) {
    read(contenidoBlocProvider.notifier).mapEventToState(UpdateContenidoEvent(id: id, params: params));
  }

  void deleteContenido(String id) {
    read(contenidoBlocProvider.notifier).mapEventToState(DeleteContenidoEvent(id));
  }

  void searchContenidos(String query, {Map<String, dynamic>? filters}) {
    read(contenidoBlocProvider.notifier).mapEventToState(
      SearchContenidosEvent(
        query: query,
        filters: filters ?? {},
      ),
    );
  }

  void toggleFavorito(String id) {
    read(contenidoBlocProvider.notifier).mapEventToState(ToggleFavoritoEvent(id));
  }

  void registrarVista(String id) {
    read(contenidoBlocProvider.notifier).mapEventToState(RegistrarVistaEvent(id));
  }

  void actualizarProgreso(String id, Map<String, dynamic> params) {
    read(contenidoBlocProvider.notifier).mapEventToState(
      ActualizarProgresoEvent(
        id: id,
        tiempoVisualizado: params['tiempoVisualizado'],
        porcentaje: params['porcentaje'],
        completado: params['completado'],
      ),
    );
  }

  void getFavoritos(String usuarioId) {
    read(contenidoBlocProvider.notifier).mapEventToState(GetFavoritosEvent(usuarioId));
  }

  void getContenidosConProgreso(String usuarioId) {
    read(contenidoBlocProvider.notifier).mapEventToState(GetContenidosConProgresoEvent(usuarioId));
  }

  void clearContenido() {
    read(contenidoBlocProvider.notifier).mapEventToState(ClearContenidoEvent());
  }

  void refreshContenidos() {
    read(contenidoBlocProvider.notifier).mapEventToState(RefreshContenidosEvent());
  }

  void getCategorias() {
    read(contenidoBlocProvider.notifier).getCategorias();
  }
}