import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'contenido_event.dart';
import 'contenido_state.dart';
import '../../../domain/entities/contenido.dart';
import '../../../domain/entities/categoria.dart';

// Importar todos los casos de uso
import '../../../domain/usecases/get_contenidos.dart';
import '../../../domain/usecases/get_contenido_by_id.dart';
import '../../../domain/usecases/create_contenido.dart';
import '../../../domain/usecases/search_contenidos.dart';
import '../../../domain/usecases/toggle_favorito.dart';
import '../../../domain/usecases/registrar_vista.dart';
import '../../../domain/usecases/actualizar_progreso.dart';
import '../../../domain/usecases/get_favoritos.dart';
import '../../../domain/usecases/get_contenidos_con_progreso.dart';

class ContenidoBloc extends StateNotifier<ContenidoState> {
  // Casos de uso
  final GetContenidosUseCase _getContenidosUseCase;
  final GetContenidoByIdUseCase _getContenidoByIdUseCase;
  final CreateContenidoUseCase _createContenidoUseCase;
  final SearchContenidosUseCase _searchContenidosUseCase;
  final ToggleFavoritoUseCase _toggleFavoritoUseCase;
  final RegistrarVistaUseCase _registrarVistaUseCase;
  final ActualizarProgresoUseCase _actualizarProgresoUseCase;
  final GetFavoritosUseCase _getFavoritosUseCase;
  final GetContenidosConProgresoUseCase _getContenidosConProgresoUseCase;

  ContenidoBloc({
    required GetContenidosUseCase getContenidosUseCase,
    required GetContenidoByIdUseCase getContenidoByIdUseCase,
    required CreateContenidoUseCase createContenidoUseCase,
    required SearchContenidosUseCase searchContenidosUseCase,
    required ToggleFavoritoUseCase toggleFavoritoUseCase,
    required RegistrarVistaUseCase registrarVistaUseCase,
    required ActualizarProgresoUseCase actualizarProgresoUseCase,
    required GetFavoritosUseCase getFavoritosUseCase,
    required GetContenidosConProgresoUseCase getContenidosConProgresoUseCase,
  })  : _getContenidosUseCase = getContenidosUseCase,
        _getContenidoByIdUseCase = getContenidoByIdUseCase,
        _createContenidoUseCase = createContenidoUseCase,
        _searchContenidosUseCase = searchContenidosUseCase,
        _toggleFavoritoUseCase = toggleFavoritoUseCase,
        _registrarVistaUseCase = registrarVistaUseCase,
        _actualizarProgresoUseCase = actualizarProgresoUseCase,
        _getFavoritosUseCase = getFavoritosUseCase,
        _getContenidosConProgresoUseCase = getContenidosConProgresoUseCase,
        super(const ContenidoState());

  Future<void> mapEventToState(ContenidoEvent event) async {
    if (event is LoadContenidosEvent) {
      await _mapGetContenidosToState(
        categoria: event.categoria,
        tipo: event.tipo,
        nivel: event.nivel,
        page: event.page,
        limit: event.limit,
        useCache: event.useCache,
        forceRefresh: event.forceRefresh,
      );
    } else if (event is LoadContenidoByIdEvent) {
      await _mapGetContenidoByIdToState(event.id);
    } else if (event is CreateContenidoEvent) {
      await _mapCreateContenidoToState(event.params);
    } else if (event is UpdateContenidoEvent) {
      await _mapUpdateContenidoToState(event.id, event.params);
    } else if (event is DeleteContenidoEvent) {
      await _mapDeleteContenidoToState(event.id);
    } else if (event is SearchContenidosEvent) {
      await _mapSearchContenidosToState(event.query, event.filters ?? {});
    } else if (event is ToggleFavoritoEvent) {
      await _mapToggleFavoritoToState(event.id);
    } else if (event is RegistrarVistaEvent) {
      await _mapRegistrarVistaToState(event.id);
    } else if (event is ActualizarProgresoEvent) {
      await _mapActualizarProgresoToState(event.id, {
        'tiempoVisualizado': event.tiempoVisualizado,
        'porcentaje': event.porcentaje,
        'completado': event.completado,
      });
    } else if (event is GetFavoritosEvent) {
      await _mapGetFavoritosToState(event.usuarioId);
    } else if (event is GetContenidosConProgresoEvent) {
      await _mapGetContenidosConProgresoToState(event.usuarioId);
    } else if (event is ClearContenidoEvent) {
      await _mapClearContenidoToState();
    } else if (event is RefreshContenidosEvent) {
      await _mapRefreshContenidosToState();
    }
  }

  Future<void> _mapGetContenidosToState({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
    int page = 1,
    int limit = 20,
    bool useCache = true,
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
      state = state.copyWith(
        status: ContenidoStatus.loading,
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

      final contenidos = await _getContenidosUseCase(params);

      if (page == 1) {
        state = state.copyWith(
          status: ContenidoStatus.success,
          contenidos: contenidos,
          hasReachedMax: contenidos.length < limit,
          isRefreshing: false,
        );
      } else {
        final updatedContenidos = [...state.contenidos, ...contenidos];
        state = state.copyWith(
          status: ContenidoStatus.success,
          contenidos: updatedContenidos,
          hasReachedMax: contenidos.length < limit,
          isRefreshing: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
        isRefreshing: false,
      );
    }
  }

  Future<void> _mapGetContenidoByIdToState(String id) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      final contenido = await _getContenidoByIdUseCase(id);
      state = state.copyWith(
        status: ContenidoStatus.success,
        selectedContenido: contenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapCreateContenidoToState(CreateContenidoParams params) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      final contenido = await _createContenidoUseCase(params);
      
      // Agregar el nuevo contenido a la lista
      final updatedContenidos = [contenido, ...state.contenidos];
      
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: updatedContenidos,
        selectedContenido: contenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapUpdateContenidoToState(String id, CreateContenidoParams params) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      // Nota: Necesitaríamos implementar un caso de uso para actualizar contenido
      // Por ahora, solo actualizamos el estado local
      final updatedContenidos = state.contenidos.map((contenido) {
        if (contenido.id == id) {
          return contenido.copyWith(
            titulo: params.titulo,
            descripcion: params.descripcion,
            categoria: params.categoria,
            tipo: params.tipo,
            url: params.url,
            thumbnailUrl: params.thumbnailUrl,
            duracion: params.duracion,
            nivel: params.nivel,
            etiquetas: params.etiquetas,
            semanaGestacionInicio: params.semanaGestacionInicio,
            semanaGestacionFin: params.semanaGestacionFin,
            updatedAt: DateTime.now(),
          );
        }
        return contenido;
      }).toList();

      // Actualizar también el contenido seleccionado si es el mismo
      Contenido? updatedSelectedContenido = state.selectedContenido;
      if (state.selectedContenido?.id == id) {
        updatedSelectedContenido = state.selectedContenido!.copyWith(
          titulo: params.titulo,
          descripcion: params.descripcion,
          categoria: params.categoria,
          tipo: params.tipo,
          url: params.url,
          thumbnailUrl: params.thumbnailUrl,
          duracion: params.duracion,
          nivel: params.nivel,
          etiquetas: params.etiquetas,
          semanaGestacionInicio: params.semanaGestacionInicio,
          semanaGestacionFin: params.semanaGestacionFin,
          updatedAt: DateTime.now(),
        );
      }

      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: updatedContenidos,
        selectedContenido: updatedSelectedContenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapDeleteContenidoToState(String id) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      // Nota: Necesitaríamos implementar un caso de uso para eliminar contenido
      // Por ahora, solo actualizamos el estado local
      final updatedContenidos = state.contenidos.where((contenido) => contenido.id != id).toList();
      
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: updatedContenidos,
        selectedContenido: state.selectedContenido?.id == id ? null : state.selectedContenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapSearchContenidosToState(String query, Map<String, dynamic> filters) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      final params = SearchContenidosParams(
        query: query,
        categoria: filters['categoria'],
        tipo: filters['tipo'],
        nivel: filters['nivel'],
        page: filters['page'] ?? 1,
        limit: filters['limit'] ?? 20,
      );

      final contenidos = await _searchContenidosUseCase(params);
      state = state.copyWith(
        status: ContenidoStatus.success,
        searchResults: contenidos,
        searchQuery: query,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapToggleFavoritoToState(String id) async {
    try {
      await _toggleFavoritoUseCase(id);
      
      // Actualizar el contenido en la lista si existe
      final updatedContenidos = state.contenidos.map((contenido) {
        if (contenido.id == id) {
          return contenido.copyWith(favorito: !contenido.favorito);
        }
        return contenido;
      }).toList();

      // Actualizar el contenido seleccionado si es el mismo
      Contenido? updatedSelectedContenido = state.selectedContenido;
      if (state.selectedContenido?.id == id) {
        updatedSelectedContenido = state.selectedContenido!.copyWith(
          favorito: !state.selectedContenido!.favorito,
        );
      }

      state = state.copyWith(
        contenidos: updatedContenidos,
        selectedContenido: updatedSelectedContenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapRegistrarVistaToState(String id) async {
    try {
      await _registrarVistaUseCase(id);
      // Esta acción no actualiza el estado, solo registra la vista
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapActualizarProgresoToState(String id, Map<String, dynamic> params) async {
    try {
      final actualizarProgresoParams = ActualizarProgresoParams(
        contenidoId: id,
        tiempoVisualizado: params['tiempoVisualizado'],
        porcentaje: params['porcentaje'],
        completado: params['completado'],
      );

      await _actualizarProgresoUseCase(actualizarProgresoParams);
      
      // Actualizar el progreso del contenido en la lista si existe
      final updatedContenidos = state.contenidos.map((contenido) {
        if (contenido.id == id) {
          final progreso = contenido.progreso?.copyWith(
            tiempoVisualizado: params['tiempoVisualizado'] ?? contenido.progreso?.tiempoVisualizado,
            porcentaje: params['porcentaje'] ?? contenido.progreso?.porcentaje,
            estaCompletado: params['completado'] ?? contenido.progreso?.estaCompletado,
            updatedAt: DateTime.now(),
          ) ?? ProgresoUsuario(
            id: '${id}_user',
            contenidoId: id,
            usuarioId: 'current_user', // Debería obtenerse del auth
            tiempoVisualizado: params['tiempoVisualizado'] ?? 0,
            porcentaje: params['porcentaje'] ?? 0.0,
            estaCompletado: params['completado'] ?? false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          return contenido.copyWith(progreso: progreso);
        }
        return contenido;
      }).toList();

      // Actualizar también el contenido seleccionado si es el mismo
      Contenido? updatedSelectedContenido = state.selectedContenido;
      if (state.selectedContenido?.id == id) {
        final progreso = state.selectedContenido!.progreso?.copyWith(
          tiempoVisualizado: params['tiempoVisualizado'] ?? state.selectedContenido!.progreso?.tiempoVisualizado,
          porcentaje: params['porcentaje'] ?? state.selectedContenido!.progreso?.porcentaje,
          estaCompletado: params['completado'] ?? state.selectedContenido!.progreso?.estaCompletado,
          updatedAt: DateTime.now(),
        ) ?? ProgresoUsuario(
          id: '${id}_user',
          contenidoId: id,
          usuarioId: 'current_user', // Debería obtenerse del auth
          tiempoVisualizado: params['tiempoVisualizado'] ?? 0,
          porcentaje: params['porcentaje'] ?? 0.0,
          estaCompletado: params['completado'] ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        updatedSelectedContenido = state.selectedContenido!.copyWith(progreso: progreso);
      }

      state = state.copyWith(
        contenidos: updatedContenidos,
        selectedContenido: updatedSelectedContenido,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapGetFavoritosToState(String usuarioId) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      final contenidos = await _getFavoritosUseCase(usuarioId);
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: contenidos,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapGetContenidosConProgresoToState(String usuarioId) async {
    state = state.copyWith(status: ContenidoStatus.loading);

    try {
      final contenidos = await _getContenidosConProgresoUseCase(usuarioId);
      state = state.copyWith(
        status: ContenidoStatus.success,
        contenidos: contenidos,
      );
    } catch (e) {
      state = state.copyWith(
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }

  Future<void> _mapClearContenidoToState() async {
    state = const ContenidoState();
  }

  Future<void> _mapRefreshContenidosToState() async {
    await _mapGetContenidosToState(
      categoria: state.categoria,
      tipo: state.tipo,
      nivel: state.nivel,
      page: 1,
      limit: state.limit,
      useCache: false,
      forceRefresh: true,
    );
  }

  // Método para obtener categorías
  Future<void> getCategorias() async {
    try {
      // Nota: Necesitaríamos implementar un caso de uso para obtener categorías
      // Por ahora, simulamos categorías
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
        status: ContenidoStatus.failure,
        error: e.toString(),
      );
    }
  }
}