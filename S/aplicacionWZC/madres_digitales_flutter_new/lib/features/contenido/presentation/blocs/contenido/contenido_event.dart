import 'package:equatable/equatable.dart';
import '../../../domain/entities/contenido.dart';
import '../../../domain/usecases/create_contenido.dart';

abstract class ContenidoEvent extends Equatable {
  const ContenidoEvent();

  @override
  List<Object?> get props => [];
}

class LoadContenidosEvent extends ContenidoEvent {

  const LoadContenidosEvent({
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
    this.useCache = true,
    this.forceRefresh = false,
  });
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
  final bool useCache;
  final bool forceRefresh;

  @override
  List<Object?> get props => [
        categoria,
        tipo,
        nivel,
        page,
        limit,
        useCache,
        forceRefresh,
      ];
}

class LoadContenidoByIdEvent extends ContenidoEvent {

  const LoadContenidoByIdEvent(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class CreateContenidoEvent extends ContenidoEvent {

  const CreateContenidoEvent({required this.params});
  final CreateContenidoParams params;

  @override
  List<Object> get props => [params];
}

class UpdateContenidoEvent extends ContenidoEvent {

  const UpdateContenidoEvent({
    required this.id,
    required this.params,
  });
  final String id;
  final CreateContenidoParams params;

  @override
  List<Object> get props => [id, params];
}

class DeleteContenidoEvent extends ContenidoEvent {

  const DeleteContenidoEvent(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class SearchContenidosEvent extends ContenidoEvent {

  const SearchContenidosEvent({
    required this.query,
    this.filters,
  });
  final String query;
  final Map<String, dynamic>? filters;

  @override
  List<Object?> get props => [query, filters];
}

class ToggleFavoritoEvent extends ContenidoEvent {

  const ToggleFavoritoEvent(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class RegistrarVistaEvent extends ContenidoEvent {

  const RegistrarVistaEvent(this.id);
  final String id;

  @override
  List<Object> get props => [id];
}

class ActualizarProgresoEvent extends ContenidoEvent {

  const ActualizarProgresoEvent({
    required this.id,
    this.tiempoVisualizado,
    this.porcentaje,
    this.completado,
  });
  final String id;
  final int? tiempoVisualizado;
  final double? porcentaje;
  final bool? completado;

  @override
  List<Object?> get props => [
        id,
        tiempoVisualizado,
        porcentaje,
        completado,
      ];
}

class GetFavoritosEvent extends ContenidoEvent {

  const GetFavoritosEvent(this.usuarioId);
  final String usuarioId;

  @override
  List<Object> get props => [usuarioId];
}

class GetContenidosConProgresoEvent extends ContenidoEvent {

  const GetContenidosConProgresoEvent(this.usuarioId);
  final String usuarioId;

  @override
  List<Object> get props => [usuarioId];
}

class RefreshContenidosEvent extends ContenidoEvent {}

class ClearContenidoEvent extends ContenidoEvent {}

class GetContenidosByCategoriaEvent extends ContenidoEvent {

  const GetContenidosByCategoriaEvent({
    required this.categoria,
    this.page = 1,
    this.limit = 20,
  });
  final CategoriaContenido categoria;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [categoria, page, limit];
}

class GetContenidosByTipoEvent extends ContenidoEvent {

  const GetContenidosByTipoEvent({
    required this.tipo,
    this.page = 1,
    this.limit = 20,
  });
  final TipoContenido tipo;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [tipo, page, limit];
}

class GetContenidosByNivelEvent extends ContenidoEvent {

  const GetContenidosByNivelEvent({
    required this.nivel,
    this.page = 1,
    this.limit = 20,
  });
  final NivelDificultad nivel;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [nivel, page, limit];
}

class GetContenidosBySemanaGestacionEvent extends ContenidoEvent {

  const GetContenidosBySemanaGestacionEvent({
    required this.semana,
    this.page = 1,
    this.limit = 20,
  });
  final int semana;
  final int page;
  final int limit;

  @override
  List<Object> get props => [semana, page, limit];
}

class GetContenidosRecomendadosEvent extends ContenidoEvent {

  const GetContenidosRecomendadosEvent({
    required this.usuarioId,
    this.limit = 10,
  });
  final String usuarioId;
  final int limit;

  @override
  List<Object> get props => [usuarioId, limit];
}

class GetContenidosRecientesEvent extends ContenidoEvent {

  const GetContenidosRecientesEvent({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

class GetContenidosPopularesEvent extends ContenidoEvent {

  const GetContenidosPopularesEvent({this.limit = 10});
  final int limit;

  @override
  List<Object> get props => [limit];
}

class GetContenidosByEtiquetasEvent extends ContenidoEvent {

  const GetContenidosByEtiquetasEvent({
    required this.etiquetas,
    this.page = 1,
    this.limit = 20,
  });
  final List<String> etiquetas;
  final int page;
  final int limit;

  @override
  List<Object> get props => [etiquetas, page, limit];
}

class GetContenidosByRangoSemanasEvent extends ContenidoEvent {

  const GetContenidosByRangoSemanasEvent({
    required this.semanaInicio,
    required this.semanaFin,
    this.page = 1,
    this.limit = 20,
  });
  final int semanaInicio;
  final int semanaFin;
  final int page;
  final int limit;

  @override
  List<Object> get props => [
        semanaInicio,
        semanaFin,
        page,
        limit,
      ];
}

class GetContenidosNoVistosEvent extends ContenidoEvent {

  const GetContenidosNoVistosEvent({
    required this.usuarioId,
    this.limit = 10,
  });
  final String usuarioId;
  final int limit;

  @override
  List<Object> get props => [usuarioId, limit];
}

class GetContenidosIncompletosEvent extends ContenidoEvent {

  const GetContenidosIncompletosEvent({
    required this.usuarioId,
    this.limit = 10,
  });
  final String usuarioId;
  final int limit;

  @override
  List<Object> get props => [usuarioId, limit];
}

class MarcarComoCompletadoEvent extends ContenidoEvent {

  const MarcarComoCompletadoEvent({
    required this.id,
    required this.usuarioId,
  });
  final String id;
  final String usuarioId;

  @override
  List<Object> get props => [id, usuarioId];
}

class ResetearProgresoEvent extends ContenidoEvent {

  const ResetearProgresoEvent({
    required this.id,
    required this.usuarioId,
  });
  final String id;
  final String usuarioId;

  @override
  List<Object> get props => [id, usuarioId];
}

class GetContenidosByMultipleFiltersEvent extends ContenidoEvent {

  const GetContenidosByMultipleFiltersEvent({
    this.categoria,
    this.tipo,
    this.nivel,
    this.etiquetas,
    this.semanaGestacion,
    this.page = 1,
    this.limit = 20,
  });
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final List<String>? etiquetas;
  final int? semanaGestacion;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [
        categoria,
        tipo,
        nivel,
        etiquetas,
        semanaGestacion,
        page,
        limit,
      ];
}
