import 'dart:async';
import 'package:madres_digitales_flutter_new/core/utils/app_logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/app_config.dart';
import 'api_service.dart';


/// Servicio básico de WebSocket para comunicación en tiempo real
class WebSocketService {
  final Map<String, StreamController<dynamic>> _streams = {};
  final Map<String, dynamic> _lastData = {};
  io.Socket? _socket;
  bool _connecting = false;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  String _lastPath = '/socket.io';

  /// Emitir un evento a un stream específico
  Future<void> emit(String event, [dynamic data]) async {
    try {
      if (_socket?.connected == true) {
        _socket!.emit(event, data);
      }
      final controller = _streams[event];
      if (controller != null) {
        controller.add(data);
        _lastData[event] = data;
      }
    } catch (e) {
      AppLogger.error('Error emitiendo evento $event', error: e);
    }
  }

  /// Suscribirse a un stream específico
  Stream<T> stream<T>(String event) {
    try {
      final controller = _streams[event];
      if (controller != null) {
        return controller.stream.cast<T>();
      }

      // Crear un nuevo controller si no existe
      final newController = StreamController<dynamic>.broadcast();
      _streams[event] = newController;

      // Vincular evento del socket si está conectado
      if (_socket != null) {
        _socket!.on(event, (data) {
          try {
            newController.add(data);
            _lastData[event] = data;
          } catch (e) {
            AppLogger.error('Error en stream $event', error: e);
          }
        });
      }

      return newController.stream.cast<T>();
    } catch (e) {
      AppLogger.error('Error creando stream para $event', error: e);
      return Stream.empty();
    }
  }

  /// Obtener el último dato emitido a un stream
  T? getLastData<T>(String event) {
    return _lastData[event] as T?;
  }

  /// Cerrar todos los streams
  void dispose() {
    for (final controller in _streams.values) {
      controller.close();
    }
    _streams.clear();
    _lastData.clear();
    disconnect();
  }

  /// Conectar al servidor de WebSocket derivado de AppConfig
  Future<void> connect({String path = '/socket.io'}) async {
    if (_socket?.connected == true || _connecting) return;
    _connecting = true;
    try {
      _lastPath = path;
      final base = AppConfig.apiBaseUrl;
      final server = base.endsWith('/api') ? base.substring(0, base.length - 4) : base;
      final protocol = server.startsWith('https') ? 'wss' : 'ws';
      final url = server.replaceFirst(RegExp(r'^https?'), protocol);
      final parsed = Uri.tryParse(url);
      final wsUrl = url;
      final token = await ApiService().getAccessToken();

      final opts = io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(token != null ? {'Authorization': 'Bearer $token'} : {})
          .enableAutoConnect()
          .build();

      _socket = io.io('$wsUrl$path', opts);

      _socket!.onConnect((_) {
        AppLogger.info('WebSocket conectado');
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
      });
      _socket!.onDisconnect((_) {
        AppLogger.warning('WebSocket desconectado');
        _scheduleReconnect();
      });
      _socket!.onError((e) {
        AppLogger.error('WebSocket error', error: e);
        _scheduleReconnect();
      });

      _socket!.connect();
    } catch (e) {
      AppLogger.error('Error conectando WebSocket', error: e);
    } finally {
      _connecting = false;
    }
  }

  /// Desconectar del servidor de WebSocket
  void disconnect() {
    try {
      _reconnectTimer?.cancel();
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
    } catch (e) {
      AppLogger.error('Error desconectando WebSocket', error: e);
    }
  }

  bool get isConnected => _socket?.connected == true;

  void _scheduleReconnect() {
    if (_connecting) return;
    if (_socket == null) return;
    final attempt = (_reconnectAttempts + 1).clamp(1, 10);
    _reconnectAttempts = attempt;
    final seconds = [1, 2, 4, 8, 16, 30].elementAt(((attempt - 1)).clamp(0, 5));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: seconds), () {
      try {
        if (_socket != null && _socket!.disconnected) {
          _socket!.connect();
        } else if (_socket == null) {
          connect(path: _lastPath);
        }
      } catch (e) {
        AppLogger.error('Error en intento de reconexión WebSocket', error: e);
      }
    });
  }
}
