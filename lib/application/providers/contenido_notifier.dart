import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/search_contenidos.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/actualizar_progreso.dart' as up;
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_provider.dart' as legacy;
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';

final contenidoByIdProvider = FutureProvider.family<Result<Contenido?, AppError>, String>((ref, id) {
  final usecase = ref.watch(legacy.getContenidoByIdUseCaseProvider);
  return usecase(id);
});

final contenidosRelacionadosProvider = FutureProvider.family<Result<List<Contenido>, AppError>, GetContenidosParams>((ref, params) {
  final usecase = ref.watch(legacy.getContenidosUseCaseProvider);
  return usecase(params);
});

final contenidosProvider = FutureProvider.family<Result<List<Contenido>, AppError>, GetContenidosParams>((ref, params) {
  final usecase = ref.watch(legacy.getContenidosUseCaseProvider);
  return usecase(params);
});

final searchContenidosProvider = FutureProvider.family<Result<List<Contenido>, AppError>, SearchContenidosParams>((ref, params) {
  final usecase = ref.watch(legacy.searchContenidosUseCaseProvider);
  return usecase(params);
});

final favoritosProvider = FutureProvider.family<List<Contenido>, String>((ref, usuarioId) async {
  final usecase = ref.watch(legacy.getFavoritosUseCaseProvider);
  return await usecase(usuarioId);
});

final contenidosConProgresoProvider = FutureProvider.family<List<Contenido>, String>((ref, usuarioId) async {
  final usecase = ref.watch(legacy.getContenidosConProgresoUseCaseProvider);
  return await usecase(usuarioId);
});

extension ContenidoActions on WidgetRef {
  void registrarVista(String id) {
    final usecase = read(legacy.registrarVistaUseCaseProvider);
    usecase(id);
  }

  void toggleFavorito(String id) {
    final usecase = read(legacy.toggleFavoritoUseCaseProvider);
    usecase(id);
  }

  void actualizarProgreso(String id, {int? tiempoVisualizado, double? porcentaje, bool? completado}) {
    final usecase = read(legacy.actualizarProgresoUseCaseProvider);
    usecase(up.ActualizarProgresoParams(
      contenidoId: id,
      tiempoVisualizado: tiempoVisualizado,
      porcentaje: porcentaje,
      completado: completado,
    ));
  }
}