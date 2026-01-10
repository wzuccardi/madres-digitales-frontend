import '../../core/network/api_service.dart';
import '../../core/types/result.dart';
import '../../core/errors/app_error.dart';
import '../../core/utils/app_logger.dart';
import '../../domain/entities/gestante.dart';
import '../../core/converters/gestante_converter.dart';
import '../../domain/repositories/gestante_repository.dart';
import '../services/cache_service.dart';
import '../../core/network/websocket_service.dart';
import '../../config/app_config.dart';

/// Implementación concreta del repositorio de gestantes
/// Utiliza ApiService para comunicarse con el backend
class GestanteRepositoryImpl implements GestanteRepository {

  GestanteRepositoryImpl(
    this._apiService,
    this._cacheService,
    this._webSocketService,
  );
  final ApiService _apiService;
  final CacheService _cacheService;
  final WebSocketService _webSocketService;

  @override
  Future<Result<List<Gestante>, AppError>> getGestantes({
    String? madrinaId,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (madrinaId != null) {
        queryParams['madrinaId'] = madrinaId;
      }
      
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      
      if (offset != null) {
        queryParams['offset'] = offset;
      }

      final response = await _apiService.get<dynamic>('/api/gestantes', queryParameters: queryParams);

      if (!response.success) {
        AppLogger.error('Error obteniendo gestantes: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al obtener gestantes'),
        );
      }
      final fromList = _apiService.extractList(response.data);
      final List<dynamic> gestantesData = fromList.isNotEmpty
          ? fromList
          : (_apiService.extractObject(response.data)['gestantes'] is List
              ? List<dynamic>.from(_apiService.extractObject(response.data)['gestantes'] as List)
              : const []);
      final gestantes = gestantesData.map((json) => GestanteConverter.apiToGestante(json as Map<String, dynamic>)).toList();
      await _cacheService.setList('gestantes_list', gestantes.map((g) => g.toJson()).toList());
      await _cacheService.set('gestantes_list_meta', {
        'ts': DateTime.now().toIso8601String(),
      });
      
      AppLogger.info('Gestantes obtenidas: ${gestantes.length}');
      return Result.success(gestantes);
    } catch (e) {
      AppLogger.error('Error de red al obtener gestantes: $e');
      try {
        final cached = await _cacheService.getList('gestantes_list');
        final meta = await _cacheService.get('gestantes_list_meta');
        final tsString = meta?['ts'] as String?;
        final ts = tsString != null ? DateTime.tryParse(tsString) : null;
        final isFresh = ts != null && DateTime.now().difference(ts) <= AppConfig.getCacheDuration();
        if (cached != null && cached.isNotEmpty) {
          if (isFresh) {
            final gestantes = cached.map((json) => Gestante.fromJson(json as Map<String, dynamic>)).toList();
            AppLogger.info('Gestantes obtenidas desde caché offline (fresco): ${gestantes.length}');
            return Result.success(gestantes);
          }
        }
      } catch (_) {}
      return Result.failure(NetworkError('Error de red al obtener gestantes: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Gestante, AppError>> getGestanteById(String id) async {
    try {
      // Intentar obtener desde caché primero
      final cachedGestante = await _getCachedGestanteById(id);
      if (cachedGestante != null) {
        AppLogger.info('Gestante obtenida desde caché: $id');
        return Result.success(cachedGestante);
      }

      final response = await _apiService.get<dynamic>('/api/gestantes/$id');

      if (!response.success) {
        if (response.statusCode == 404) {
          return const Result.failure(
            NotFoundError('Gestante no encontrada'),
          );
        }
        
        AppLogger.error('Error obteniendo gestante: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al obtener gestante'),
        );
      }

      final gestanteData = _apiService.extractObject(response.data);
      final gestante = GestanteConverter.apiToGestante(gestanteData);
      
      // Actualizar caché
      await _cacheService.setList('gestante_$id', [gestante.toJson()]);
      
      AppLogger.info('Gestante obtenida desde API: $id');
      return Result.success(gestante);
    } catch (e) {
      AppLogger.error('Error de red al obtener gestante: $e');
      return Result.failure(
        NetworkError('Error de red al obtener gestante: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Gestante, AppError>> createGestante(Gestante gestante) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/gestantes',
        data: GestanteConverter.gestanteToApi(gestante),
      );

      if (!response.success) {
        AppLogger.error('Error creando gestante: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al crear gestante'),
        );
      }

      final gestanteData = response.data!;
      final newGestante = GestanteConverter.apiToGestante(gestanteData);
      
      // Actualizar caché
      await _cacheService.setList('gestante_${newGestante.id}', [newGestante.toJson()]);
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('gestante_creada', newGestante.toJson());
      
      AppLogger.info('Gestante creada: ${newGestante.id}');
      return Result.success(newGestante);
    } catch (e) {
      AppLogger.error('Error de red al crear gestante: $e');
      return Result.failure(
        NetworkError('Error de red al crear gestante: ${e.toString()}'),
      );
    }
  }

  Future<Result<Gestante, AppError>> createGestanteFromData(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/api/gestantes',
        data: data,
      );

      if (!response.success) {
        AppLogger.error('Error creando gestante (data): ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al crear gestante'),
        );
      }

      final gestanteData = _apiService.extractObject(response.data);
      final newGestante = GestanteConverter.apiToGestante(gestanteData);
      await _cacheService.setList('gestante_${newGestante.id}', [newGestante.toJson()]);
      await _webSocketService.emit('gestante_creada', newGestante.toJson());
      return Result.success(newGestante);
    } catch (e) {
      AppLogger.error('Error de red al crear gestante (data): $e');
      return Result.failure(
        NetworkError('Error de red al crear gestante: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Gestante, AppError>> updateGestante(Gestante gestante) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>(
        '/api/gestantes/${gestante.id}',
        data: GestanteConverter.gestanteToApi(gestante),
      );

      if (!response.success) {
        AppLogger.error('Error actualizando gestante: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al actualizar gestante'),
        );
      }

      final gestanteData = response.data!;
      final updatedGestante = GestanteConverter.apiToGestante(gestanteData);
      
      // Actualizar caché
      await _cacheService.setList('gestante_${updatedGestante.id}', [updatedGestante.toJson()]);
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('gestante_actualizada', updatedGestante.toJson());
      
      AppLogger.info('Gestante actualizada: ${updatedGestante.id}');
      return Result.success(updatedGestante);
    } catch (e) {
      AppLogger.error('Error de red al actualizar gestante: $e');
      return Result.failure(
        NetworkError('Error de red al actualizar gestante: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void, AppError>> deleteGestante(String id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>('/api/gestantes/$id');

      if (!response.success) {
        AppLogger.error('Error eliminando gestante: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al eliminar gestante'),
        );
      }

      // Eliminar de caché
      await _cacheService.setList('gestante_$id', []);
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('gestante_eliminada', {'id': id});
      
      AppLogger.info('Gestante eliminada: $id');
      return const Result.success(null);
    } catch (e) {
      AppLogger.error('Error de red al eliminar gestante: $e');
      return Result.failure(
        NetworkError('Error de red al eliminar gestante: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<bool, AppError>> assignGestanteToMadrina({
    required String gestanteId,
    required String madrinaId,
    String? asignadoPor,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        '/gestantes/$gestanteId/assign-madrina',
        data: {
          'madrinaId': madrinaId,
          if (asignadoPor != null) 'asignadoPor': asignadoPor,
        },
      );

      if (!response.success) {
        AppLogger.error('Error asignando gestante a madrina: ${response.error?.message}');
        return Result.failure(
          ServerError(response.error?.message ?? 'Error al asignar gestante a madrina'),
        );
      }

      // Invalidar caché de la gestante
      await _cacheService.setList('gestante_$gestanteId', []);
      
      // Notificar via WebSocket para actualización en tiempo real
      await _webSocketService.emit('gestante_asignada', {
        'gestanteId': gestanteId,
        'madrinaId': madrinaId,
        'asignadoPor': asignadoPor,
      });
      
      AppLogger.info('Gestante asignada a madrina: $gestanteId -> $madrinaId');
      return const Result.success(true);
    } catch (e) {
      AppLogger.error('Error de red al asignar gestante a madrina: $e');
      return Result.failure(
        NetworkError('Error de red al asignar gestante a madrina: ${e.toString()}'),
      );
    }
  }

  // Métodos auxiliares para manejo de caché
  Future<Gestante?> _getCachedGestanteById(String gestanteId) async {
    try {
      final cachedData = await _cacheService.getList('gestante_$gestanteId');
      if (cachedData == null || cachedData.isEmpty) return null;
      
      return Gestante.fromJson(cachedData.first as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error obteniendo gestante desde caché: $e');
      return null;
    }
  }
}

// Excepción específica para errores de gestante
class GestanteFailure extends AppError {
  const GestanteFailure(super.message, {super.code});
  
  @override
  String toString() => 'GestanteFailure: $message';
}
