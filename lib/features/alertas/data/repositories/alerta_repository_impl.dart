import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/core/network/websocket_service.dart';
import 'package:madres_digitales_flutter_new/data/services/cache_service.dart';
import 'package:madres_digitales_flutter_new/config/app_config.dart';
import 'package:madres_digitales_flutter_new/data/services/sync_service.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/features/alertas/domain/repositories/alerta_repository.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';

class AlertaRepositoryImpl implements AlertaRepository {
  AlertaRepositoryImpl({required ApiService apiService, required CacheService cacheService, required SyncService syncService, WebSocketService? webSocketService})
      : _apiService = apiService,
        _cacheService = cacheService,
        _syncService = syncService,
        _ws = webSocketService ?? WebSocketService();
  final ApiService _apiService;
  final CacheService _cacheService;
  final SyncService _syncService;
  final WebSocketService _ws;

  @override
  Future<Result<List<Alerta>, AppError>> fetchAlertas() async {
    try {
      final response = await _apiService.get<dynamic>('/api/alertas');
      if (!response.success) {
        final error = ServerError(response.error?.message ?? 'Error al obtener alertas');
        return Result.failure(error);
      }
      final data = _apiService.extractData(response.data);
      final raw = (data is Map<String, dynamic> && data['alertas'] is List)
          ? List<dynamic>.from(data['alertas'] as List)
          : (data is List ? data : const []);
      
      final List<Alerta> list = [];
      for (var i = 0; i < raw.length; i++) {
        try {
          final alerta = Alerta.fromJson(raw[i] as Map<String, dynamic>);
          list.add(alerta);
        } catch (e) {
          // Log individual parsing errors but continue processing other alerts
          AppLogger.error('Error parseando alerta en índice $i: $e');
          continue;
        }
      }
      await _cacheService.cacheAlertas(list);
      await _cacheService.set('cache_alertas_meta', {'ts': DateTime.now().toIso8601String()});
      
      return Result.success(list);
    } catch (e) {
      try {
        final cached = await _cacheService.getCachedAlertas();
        final meta = await _cacheService.get('cache_alertas_meta');
        final tsString = meta?['ts'] as String?;
        final ts = tsString != null ? DateTime.tryParse(tsString) : null;
        final isFresh = ts != null && DateTime.now().difference(ts) <= AppConfig.getCacheDuration();
        if (cached != null && cached.isNotEmpty && isFresh) {
          return Result.success(cached);
        }
      } catch (_) {}
      final error = e is AppError ? e : NetworkError('Error de red al obtener alertas: ${e.toString()}');
      return Result.failure(error);
    }
  }

  @override
  Future<Result<Alerta, AppError>> createAlerta(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas', data: data);
      if (!response.success) {
        final error = ServerError(response.error?.message ?? 'Error al crear alerta');
        return Result.failure(error);
      }
      final alerta = Alerta.fromJson((_apiService.extractObject(response.data)['alerta'] ?? _apiService.extractObject(response.data)) as Map<String, dynamic>);
      await _cacheService.cacheAlerta(alerta);
      await _ws.emit('alerta:created', alerta.toJson());
      return Result.success(alerta);
    } catch (e) {
      await _syncService.markForSync('alertas_create', data);
      final error = e is AppError ? e : NetworkError('Error de red al crear alerta: ${e.toString()}');
      return Result.failure(error);
    }
  }

  @override
  Future<Result<void, AppError>> resolverAlerta(String id) async {
    try {
      final response = await _apiService.put<Map<String, dynamic>>('/api/alertas/$id/resolver');
      if (!response.success) {
        final error = ServerError(response.error?.message ?? 'Error al resolver alerta');
        return Result.failure(error);
      }
      await _cacheService.updateAlertaStatus(id, AlertaEstado.resuelta);
      await _ws.emit('alerta:status', {'id': id, 'estado': 'resuelta'});
      return const Result.success(null);
    } catch (e) {
      await _syncService.markForSync('alertas_resolver', {'id': id});
      final error = e is AppError ? e : NetworkError('Error de red al resolver alerta: ${e.toString()}');
      return Result.failure(error);
    }
  }

  @override
  Future<Result<void, AppError>> marcarComoLeida(String id) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>('/api/alertas/$id/leida');
      if (!response.success) {
        final error = ServerError(response.error?.message ?? 'Error al marcar alerta como leída');
        return Result.failure(error);
      }
      await _cacheService.updateAlertaStatus(id, AlertaEstado.enProgreso);
      await _ws.emit('alerta:read', {'id': id});
      return const Result.success(null);
    } catch (e) {
      await _syncService.markForSync('alertas_leida', {'id': id});
      final error = e is AppError ? e : NetworkError('Error de red al marcar como leída: ${e.toString()}');
      return Result.failure(error);
    }
  }
}
