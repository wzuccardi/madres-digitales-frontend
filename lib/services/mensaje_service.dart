import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/mensaje.dart';
import 'logger_service.dart';
import 'api_service.dart';

/// Servicio de mensajería
class MensajeService {
  static final MensajeService _instance = MensajeService._internal();
  factory MensajeService() => _instance;
  MensajeService._internal();

  final _logger = LoggerService();
  Dio? _dio;
  IO.Socket? _socket;
  String? _currentUserId;

  // Stream controllers
  final _mensajesController = StreamController<Mensaje>.broadcast();
  final _conversacionesController = StreamController<List<Conversacion>>.broadcast();
  final _typingController = StreamController<TypingEvent>.broadcast();
  final _onlineUsersController = StreamController<List<String>>.broadcast();

  Stream<Mensaje> get mensajesStream => _mensajesController.stream;
  Stream<List<Conversacion>> get conversacionesStream => _conversacionesController.stream;
  Stream<TypingEvent> get typingStream => _typingController.stream;
  Stream<List<String>> get onlineUsersStream => _onlineUsersController.stream;

  /// Inicializar servicio
  void initialize(Dio dio, String userId, String token) {
    _dio = dio;
    _currentUserId = userId;
    _initializeWebSocket(token);
  }
  
  /// Inicializar servicio usando ApiService (para heredar token)
  void initializeWithApiService(String userId) {
    final apiService = ApiService();
    _dio = apiService.dioInstance;
    _currentUserId = userId;
    // Obtener token del storage para WebSocket
    _initializeWebSocketWithStoredToken();
  }
  
  /// Inicializar WebSocket con token almacenado
  void _initializeWebSocketWithStoredToken() async {
    final apiService = ApiService();
    final token = await apiService.getToken();
    if (token != null) {
      _initializeWebSocket(token);
    }
  }

  /// Inicializar WebSocket
  void _initializeWebSocket(String token) {
    try {
      final baseUrl = _dio?.options.baseUrl ?? 'http://localhost:54112';
      final wsUrl = baseUrl.replaceFirst('http', 'ws');

      _socket = IO.io(
        wsUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableAutoConnect()
            .build(),
      );

      _socket!.onConnect((_) {
        _logger.info('WebSocket conectado');
      });

      _socket!.onDisconnect((_) {
        _logger.warning('WebSocket desconectado');
      });

      _socket!.onError((error) {
        _logger.error('Error en WebSocket', error: error);
      });

      // Escuchar mensajes nuevos
      _socket!.on('message:new', (data) {
        try {
          final mensaje = Mensaje.fromJson(data);
          _mensajesController.add(mensaje);
          _logger.info('Mensaje nuevo recibido', data: {'id': mensaje.id});
        } catch (e) {
          _logger.error('Error procesando mensaje nuevo', error: e);
        }
      });

      // Escuchar usuario escribiendo
      _socket!.on('typing:start', (data) {
        _typingController.add(TypingEvent(
          userId: data['userId'],
          userName: data['userName'],
          conversationId: data['conversationId'],
          isTyping: true,
        ));
      });

      _socket!.on('typing:stop', (data) {
        _typingController.add(TypingEvent(
          userId: data['userId'],
          userName: '',
          conversationId: data['conversationId'],
          isTyping: false,
        ));
      });

      // Escuchar usuarios online
      _socket!.on('user:online', (data) {
        _logger.info('Usuario online', data: data);
      });

      _socket!.on('user:offline', (data) {
        _logger.info('Usuario offline', data: data);
      });

      _socket!.connect();
    } catch (e, stackTrace) {
      _logger.error('Error inicializando WebSocket', error: e, stackTrace: stackTrace);
    }
  }

  /// Crear conversación
  Future<Conversacion> crearConversacion({
    String? titulo,
    required String tipo,
    required List<String> participantes,
    String? gestanteId,
  }) async {
    try {
      final response = await _dio!.post(
        '/mensajes/conversaciones',
        data: {
          'titulo': titulo,
          'tipo': tipo,
          'participantes': participantes,
          'gestanteId': gestanteId,
        },
      );

      final conversacion = Conversacion.fromJson(response.data['data']);
      _logger.info('Conversación creada', data: {'id': conversacion.id});
      
      return conversacion;
    } catch (e, stackTrace) {
      _logger.error('Error creando conversación', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener conversaciones
  Future<List<Conversacion>> obtenerConversaciones({
    String? query,
    String? tipo,
    String? gestanteId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio!.get(
        '/mensajes/conversaciones',
        queryParameters: {
          if (query != null) 'query': query,
          if (tipo != null) 'tipo': tipo,
          if (gestanteId != null) 'gestanteId': gestanteId,
          'limit': limit,
          'offset': offset,
        },
      );

      final conversaciones = (response.data['data'] as List)
          .map((c) => Conversacion.fromJson(c))
          .toList();

      _conversacionesController.add(conversaciones);
      
      return conversaciones;
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo conversaciones', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Obtener mensajes de conversación
  Future<List<Mensaje>> obtenerMensajes({
    required String conversacionId,
    int limit = 50,
    int offset = 0,
    String? antes,
  }) async {
    try {
      final response = await _dio!.get(
        '/mensajes/conversaciones/$conversacionId/mensajes',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (antes != null) 'antes': antes,
        },
      );

      final mensajes = (response.data['data'] as List)
          .map((m) => Mensaje.fromJson(m))
          .toList();

      return mensajes;
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo mensajes', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Enviar mensaje
  Future<Mensaje> enviarMensaje({
    required String conversacionId,
    required String contenido,
    String tipo = 'texto',
    String? archivoUrl,
    String? archivoNombre,
    String? respondiendoA,
  }) async {
    try {
      final response = await _dio!.post(
        '/mensajes/conversaciones/$conversacionId/mensajes',
        data: {
          'tipo': tipo,
          'contenido': contenido,
          if (archivoUrl != null) 'archivoUrl': archivoUrl,
          if (archivoNombre != null) 'archivoNombre': archivoNombre,
          if (respondiendoA != null) 'respondiendoA': respondiendoA,
        },
      );

      final mensaje = Mensaje.fromJson(response.data['data']);
      _logger.info('Mensaje enviado', data: {'id': mensaje.id});
      
      return mensaje;
    } catch (e, stackTrace) {
      _logger.error('Error enviando mensaje', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Marcar mensaje como leído
  Future<void> marcarComoLeido(String mensajeId) async {
    try {
      await _dio!.post('/mensajes/$mensajeId/leer');
      
      // Notificar via WebSocket
      _socket?.emit('message:read', {'messageId': mensajeId});
      
      _logger.info('Mensaje marcado como leído', data: {'id': mensajeId});
    } catch (e, stackTrace) {
      _logger.error('Error marcando mensaje como leído', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Unirse a conversación (WebSocket)
  void unirseAConversacion(String conversacionId) {
    _socket?.emit('conversation:join', conversacionId);
    _logger.info('Unido a conversación', data: {'id': conversacionId});
  }

  /// Salir de conversación (WebSocket)
  void salirDeConversacion(String conversacionId) {
    _socket?.emit('conversation:leave', conversacionId);
    _logger.info('Salido de conversación', data: {'id': conversacionId});
  }

  /// Notificar que está escribiendo
  void notificarEscribiendo(String conversacionId) {
    _socket?.emit('typing:start', {'conversationId': conversacionId});
  }

  /// Notificar que dejó de escribir
  void notificarDejoDeEscribir(String conversacionId) {
    _socket?.emit('typing:stop', {'conversationId': conversacionId});
  }

  /// Obtener estadísticas
  Future<EstadisticasMensajeria> obtenerEstadisticas() async {
    try {
      final response = await _dio!.get('/mensajes/estadisticas');
      return EstadisticasMensajeria.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      _logger.error('Error obteniendo estadísticas', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Limpiar recursos
  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _mensajesController.close();
    _conversacionesController.close();
    _typingController.close();
    _onlineUsersController.close();
  }
}

/// Evento de usuario escribiendo
class TypingEvent {
  final String userId;
  final String userName;
  final String conversationId;
  final bool isTyping;

  TypingEvent({
    required this.userId,
    required this.userName,
    required this.conversationId,
    required this.isTyping,
  });
}

