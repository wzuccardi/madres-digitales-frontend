import 'package:equatable/equatable.dart';
import '../../../domain/entities/contenido.dart';
import '../../../domain/usecases/create_contenido.dart';

abstract class ContenidoEvent extends Equatable {
  const ContenidoEvent();

  @override
  List<Object?> get props => [];
}

class LoadContenidosEvent extends ContenidoEvent {
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final int page;
  final int limit;
  final bool useCache;
  final bool forceRefresh;

  const LoadContenidosEvent({
    this.categoria,
    this.tipo,
    this.nivel,
    this.page = 1,
    this.limit = 20,
    this.useCache = true,
    this.forceRefresh = false,
  });

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
  final String id;

  const LoadContenidoByIdEvent(this.id);

  @override
  List<Object> get props => [id];
}

class CreateContenidoEvent extends ContenidoEvent {
  final CreateContenidoParams params;

  const CreateContenidoEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class UpdateContenidoEvent extends ContenidoEvent {
  final String id;
  final CreateContenidoParams params;

  const UpdateContenidoEvent({
    required this.id,
    required this.params,
  });

  @override
  List<Object> get props => [id, params];
}

class DeleteContenidoEvent extends ContenidoEvent {
  final String id;

  const DeleteContenidoEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SearchContenidosEvent extends ContenidoEvent {
  final String query;
  final Map<String, dynamic>? filters;

  const SearchContenidosEvent({
    required this.query,
    this.filters,
  });

  @override
  List<Object?> get props => [query, filters];
}

class ToggleFavoritoEvent extends ContenidoEvent {
  final String id;

  const ToggleFavoritoEvent(this.id);

  @override
  List<Object> get props => [id];
}

class RegistrarVistaEvent extends ContenidoEvent {
  final String id;

  const RegistrarVistaEvent(this.id);

  @override
  List<Object> get props => [id];
}

class ActualizarProgresoEvent extends ContenidoEvent {
  final String id;
  final int? tiempoVisualizado;
  final double? porcentaje;
  final bool? completado;

  const ActualizarProgresoEvent({
    required this.id,
    this.tiempoVisualizado,
    this.porcentaje,
    this.completado,
  });

  @override
  List<Object?> get props => [
        id,
        tiempoVisualizado,
        porcentaje,
        completado,
      ];
}

class GetFavoritosEvent extends ContenidoEvent {
  final String usuarioId;

  const GetFavoritosEvent(this.usuarioId);

  @override
  List<Object> get props => [usuarioId];
}

class GetContenidosConProgresoEvent extends ContenidoEvent {
  final String usuarioId;

  const GetContenidosConProgresoEvent(this.usuarioId);

  @override
  List<Object> get props => [usuarioId];
}

class RefreshContenidosEvent extends ContenidoEvent {}

class ClearContenidoEvent extends ContenidoEvent {}

class GetContenidosByCategoriaEvent extends ContenidoEvent {
  final CategoriaContenido categoria;
  final int page;
  final int limit;

  const GetContenidosByCategoriaEvent({
    required this.categoria,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [categoria, page, limit];
}

class GetContenidosByTipoEvent extends ContenidoEvent {
  final TipoContenido tipo;
  final int page;
  final int limit;

  const GetContenidosByTipoEvent({
    required this.tipo,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [tipo, page, limit];
}

class GetContenidosByNivelEvent extends ContenidoEvent {
  final NivelDificultad nivel;
  final int page;
  final int limit;

  const GetContenidosByNivelEvent({
    required this.nivel,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [nivel, page, limit];
}

class GetContenidosBySemanaGestacionEvent extends ContenidoEvent {
  final int semana;
  final int page;
  final int limit;

  const GetContenidosBySemanaGestacionEvent({
    required this.semana,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [semana, page, limit];
}

class GetContenidosRecomendadosEvent extends ContenidoEvent {
  final String usuarioId;
  final int limit;

  const GetContenidosRecomendadosEvent({
    required this.usuarioId,
    this.limit = 10,
  });

  @override
  List<Object> get props => [usuarioId, limit];
}

class GetContenidosRecientesEvent extends ContenidoEvent {
  final int limit;

  const GetContenidosRecientesEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

class GetContenidosPopularesEvent extends ContenidoEvent {
  final int limit;

  const GetContenidosPopularesEvent({this.limit = 10});

  @override
  List<Object> get props => [limit];
}

class GetContenidosByEtiquetasEvent extends ContenidoEvent {
  final List<String> etiquetas;
  final int page;
  final int limit;

  const GetContenidosByEtiquetasEvent({
    required this.etiquetas,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [etiquetas, page, limit];
}

class GetContenidosByRangoSemanasEvent extends ContenidoEvent {
  final int semanaInicio;
  final int semanaFin;
  final int page;
  final int limit;

  const GetContenidosByRangoSemanasEvent({
    required this.semanaInicio,
    required this.semanaFin,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [
        semanaInicio,
        semanaFin,
        page,
        limit,
      ];
}

class GetContenidosNoVistosEvent extends ContenidoEvent {
  final String usuarioId;
  final int limit;

  const GetContenidosNoVistosEvent({
    required this.usuarioId,
    this.limit = 10,
  });

  @override
  List<Object> get props => [usuarioId, limit];
}

class GetContenidosIncompletosEvent extends ContenidoEvent {
  final String usuarioId;
  final int limit;

  const GetContenidosIncompletosEvent({
    required this.usuarioId,
    this.limit = 10,
  });

  @override
  List<Object> get props => [usuarioId, limit];
}

class MarcarComoCompletadoEvent extends ContenidoEvent {
  final String id;
  final String usuarioId;

  const MarcarComoCompletadoEvent({
    required this.id,
    required this.usuarioId,
  });

  @override
  List<Object> get props => [id, usuarioId];
}

class ResetearProgresoEvent extends ContenidoEvent {
  final String id;
  final String usuarioId;

  const ResetearProgresoEvent({
    required this.id,
    required this.usuarioId,
  });

  @override
  List<Object> get props => [id, usuarioId];
}

class GetContenidosByMultipleFiltersEvent extends ContenidoEvent {
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final List<String>? etiquetas;
  final int? semanaGestacion;
  final int page;
  final int limit;

  const GetContenidosByMultipleFiltersEvent({
    this.categoria,
    this.tipo,
    this.nivel,
    this.etiquetas,
    this.semanaGestacion,
    this.page = 1,
    this.limit = 20,
  });

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
