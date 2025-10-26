import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:madres_digitales_flutter_new/utils/logger.dart';

/// Modelo para información de sesión concurrente
class ConcurrentSessionInfo {
  final String sessionId;
  final String userId;
  final String deviceId;
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;
  final DateTime lastActivity;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  ConcurrentSessionInfo({
    required this.sessionId,
    required this.userId,
    required this.deviceId,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
    required this.lastActivity,
    required this.isActive,
    this.metadata,
  });

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userId': userId,
      'deviceId': deviceId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createdAt': createdAt.toIso8601String(),
      'lastActivity': lastActivity.toIso8601String(),
      'isActive': isActive,
      'metadata': metadata,
    };
  }

  /// Crear desde JSON
  factory ConcurrentSessionInfo.fromJson(Map<String, dynamic> json) {
    return ConcurrentSessionInfo(
      sessionId: json['sessionId'],
      userId: json['userId'],
      deviceId: json['deviceId'],
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      createdAt: DateTime.parse(json['createdAt']),
      lastActivity: DateTime.parse(json['lastActivity']),
      isActive: json['isActive'],
      metadata: json['metadata'],
    );
  }

  /// Verificar si la sesión está activa (actividad en últimos 15 minutos)
  bool get isRecentlyActive {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inMinutes < 15;
  }

  /// Verificar si la sesión ha expirado (más de 24 horas sin actividad)
  bool get isExpired {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);
    return difference.inHours > 24;
  }

  @override
  String toString() {
    return 'ConcurrentSessionInfo{sessionId: $sessionId, deviceId: $deviceId, isActive: $isActive, lastActivity: $lastActivity}';
  }
}

/// Eventos de sesión concurrente
enum ConcurrentSessionEventType {
  sessionCreated,
  sessionUpdated,
  sessionRevoked,
  sessionExpired,
  conflictDetected,
  maxSessionsExceeded,
}

/// Evento de sesión concurrente
class ConcurrentSessionEvent {
  final ConcurrentSessionEventType type;
  final String userId;
  final ConcurrentSessionInfo? sessionInfo;
  final DateTime timestamp;
  final String? message;

  ConcurrentSessionEvent({
    required this.type,
    required this.userId,
    this.sessionInfo,
    this.message,
  }) : timestamp = DateTime.now();

  @override
  String toString() {
    return 'ConcurrentSessionEvent{type: $type, userId: $userId, timestamp: $timestamp}';
  }
}

/// Servicio para manejo de sesiones concurrentes
class ConcurrentSessionService {
  static const String _sessionKeyPrefix = 'concurrent_session_';
  static const String _userSessionsKeyPrefix = 'user_sessions_';
  static const String _conflictKeyPrefix = 'session_conflict_';
  
  // NUEVO: Límite máximo de sesiones concurrentes por usuario
  static const int _maxConcurrentSessions = 3;
  
  // NUEVO: Tiempo de vida de la sesión (24 horas)
  static const Duration _sessionLifetime = Duration(hours: 24);
  
  // NUEVO: Tiempo para considerar sesión inactiva (15 minutos)
  static const Duration _inactiveTimeout = Duration(minutes: 15);
  
  // NUEVO: Stream para notificar eventos de sesión
  final StreamController<ConcurrentSessionEvent> _eventController = 
      StreamController<ConcurrentSessionEvent>.broadcast();
  
  Stream<ConcurrentSessionEvent> get events => _eventController.stream;
  
  // NUEVO: Cache local de sesiones para mejor rendimiento
  final Map<String, ConcurrentSessionInfo> _sessionCache = {};
  
  // NUEVO: Mapa para control de locks por usuario
  final Map<String, Completer<bool>> _sessionLocks = {};

  /// NUEVO: Crear nueva sesión concurrente
  Future<ConcurrentSessionInfo?> createSession({
    required String userId,
    required String deviceId,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      'ConcurrentSessionService: Creando nueva sesión'.debug(context: {
        'userId': userId,
        'deviceId': deviceId,
      });
      
      // Verificar si ya existe un lock para este usuario
      if (_sessionLocks.containsKey(userId)) {
        'ConcurrentSessionService: Esperando lock de sesión existente'.debug(context: {
          'userId': userId,
        });
        
        try {
          await _sessionLocks[userId]!.future;
        } catch (e) {
          'Error esperando lock de sesión'.error(error: e, context: {
            'userId': userId,
          });
        }
      }
      
      // Crear nuevo lock
      final lockCompleter = Completer<bool>();
      _sessionLocks[userId] = lockCompleter;
      
      try {
        // Obtener sesiones activas del usuario
        final activeSessions = await getUserActiveSessions(userId);
        
        // Verificar límite de sesiones concurrentes
        if (activeSessions.length >= _maxConcurrentSessions) {
          'ConcurrentSessionService: Límite de sesiones concurrentes excedido'.warn(context: {
            'userId': userId,
            'activeSessions': activeSessions.length,
            'maxSessions': _maxConcurrentSessions,
          });
          
          // Emitir evento de límite excedido
          _eventController.add(ConcurrentSessionEvent(
            type: ConcurrentSessionEventType.maxSessionsExceeded,
            userId: userId,
            message: 'Límite de sesiones concurrentes excedido',
          ));
          
          // Revocar la sesión más antigua
          await _revokeOldestSession(userId);
        }
        
        // Verificar si ya existe una sesión para este dispositivo
        final existingDeviceSession = activeSessions.firstWhere(
          (session) => session.deviceId == deviceId,
          orElse: () => null as ConcurrentSessionInfo,
        );
        
        'ConcurrentSessionService: Sesión existente para dispositivo, actualizando'.debug(context: {
          'userId': userId,
          'deviceId': deviceId,
          'sessionId': existingDeviceSession.sessionId,
        });
        
        // Actualizar sesión existente
        return await _updateSession(
          existingDeviceSession.sessionId,
          lastActivity: DateTime.now(),
          isActive: true,
        );
              
        // Crear nueva sesión
        final sessionId = _generateSessionId(userId, deviceId);
        final now = DateTime.now();
        
        final sessionInfo = ConcurrentSessionInfo(
          sessionId: sessionId,
          userId: userId,
          deviceId: deviceId,
          ipAddress: ipAddress,
          userAgent: userAgent,
          createdAt: now,
          lastActivity: now,
          isActive: true,
          metadata: metadata,
        );
        
        // Guardar en cache local
        _sessionCache[sessionId] = sessionInfo;
        
        // Guardar en SharedPreferences
        await _saveSession(sessionInfo);
        
        // Actualizar lista de sesiones del usuario
        await _updateUserSessions(userId, sessionId);
        
        'ConcurrentSessionService: Sesión creada exitosamente'.debug(context: {
          'userId': userId,
          'sessionId': sessionId,
          'deviceId': deviceId,
        });
        
        // Emitir evento de sesión creada
        _eventController.add(ConcurrentSessionEvent(
          type: ConcurrentSessionEventType.sessionCreated,
          userId: userId,
          sessionInfo: sessionInfo,
        ));
        
        return sessionInfo;
      } finally {
        // Liberar lock
        _sessionLocks.remove(userId);
        lockCompleter.complete(true);
      }
    } catch (e) {
      'Error creando sesión concurrente'.error(error: e, context: {
        'userId': userId,
        'deviceId': deviceId,
      });
      return null;
    }
  }

  /// NUEVO: Actualizar actividad de sesión
  Future<bool> updateSessionActivity(String sessionId) async {
    try {
      'ConcurrentSessionService: Actualizando actividad de sesión'.debug(context: {
        'sessionId': sessionId,
      });
      
      // Verificar en cache local primero
      final cachedSession = _sessionCache[sessionId];
      if (cachedSession != null) {
        // Actualizar en cache
        final updatedSession = ConcurrentSessionInfo(
          sessionId: cachedSession.sessionId,
          userId: cachedSession.userId,
          deviceId: cachedSession.deviceId,
          ipAddress: cachedSession.ipAddress,
          userAgent: cachedSession.userAgent,
          createdAt: cachedSession.createdAt,
          lastActivity: DateTime.now(),
          isActive: true,
          metadata: cachedSession.metadata,
        );
        
        _sessionCache[sessionId] = updatedSession;
        
        // Guardar en SharedPreferences
        await _saveSession(updatedSession);
        
        'ConcurrentSessionService: Actividad de sesión actualizada en cache'.debug(context: {
          'sessionId': sessionId,
          'lastActivity': updatedSession.lastActivity.toIso8601String(),
        });
        
        return true;
      }
      
      // Si no está en cache, buscar en SharedPreferences
      final sessionInfo = await _getSession(sessionId);
      if (sessionInfo != null) {
        // Actualizar en cache
        final updatedSession = ConcurrentSessionInfo(
          sessionId: sessionInfo.sessionId,
          userId: sessionInfo.userId,
          deviceId: sessionInfo.deviceId,
          ipAddress: sessionInfo.ipAddress,
          userAgent: sessionInfo.userAgent,
          createdAt: sessionInfo.createdAt,
          lastActivity: DateTime.now(),
          isActive: true,
          metadata: sessionInfo.metadata,
        );
        
        _sessionCache[sessionId] = updatedSession;
        
        // Guardar en SharedPreferences
        await _saveSession(updatedSession);
        
        'ConcurrentSessionService: Actividad de sesión actualizada desde storage'.debug(context: {
          'sessionId': sessionId,
          'lastActivity': updatedSession.lastActivity.toIso8601String(),
        });
        
        return true;
      }
      
      'ConcurrentSessionService: Sesión no encontrada para actualizar actividad'.warn(context: {
        'sessionId': sessionId,
      });
      
      return false;
    } catch (e) {
      'Error actualizando actividad de sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
      return false;
    }
  }

  /// NUEVO: Verificar si una sesión es válida
  Future<bool> isSessionValid(String sessionId) async {
    try {
      'ConcurrentSessionService: Verificando validez de sesión'.debug(context: {
        'sessionId': sessionId,
      });
      
      // Verificar en cache local primero
      final cachedSession = _sessionCache[sessionId];
      if (cachedSession != null) {
        final isValid = cachedSession.isActive && !cachedSession.isExpired;
        
        'ConcurrentSessionService: Validez de sesión verificada en cache'.debug(context: {
          'sessionId': sessionId,
          'isValid': isValid,
          'isActive': cachedSession.isActive,
          'isExpired': cachedSession.isExpired,
        });
        
        return isValid;
      }
      
      // Si no está en cache, buscar en SharedPreferences
      final sessionInfo = await _getSession(sessionId);
      if (sessionInfo != null) {
        // Actualizar en cache
        _sessionCache[sessionId] = sessionInfo;
        
        final isValid = sessionInfo.isActive && !sessionInfo.isExpired;
        
        'ConcurrentSessionService: Validez de sesión verificada desde storage'.debug(context: {
          'sessionId': sessionId,
          'isValid': isValid,
          'isActive': sessionInfo.isActive,
          'isExpired': sessionInfo.isExpired,
        });
        
        return isValid;
      }
      
      'ConcurrentSessionService: Sesión no encontrada para verificar validez'.warn(context: {
        'sessionId': sessionId,
      });
      
      return false;
    } catch (e) {
      'Error verificando validez de sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
      return false;
    }
  }

  /// NUEVO: Revocar sesión
  Future<bool> revokeSession(String sessionId, {String? reason}) async {
    try {
      'ConcurrentSessionService: Revocando sesión'.debug(context: {
        'sessionId': sessionId,
        'reason': reason,
      });
      
      // Obtener información de la sesión
      final sessionInfo = await _getSession(sessionId) ?? _sessionCache[sessionId];
      if (sessionInfo == null) {
        'ConcurrentSessionService: Sesión no encontrada para revocar'.warn(context: {
          'sessionId': sessionId,
        });
        return false;
      }
      
      // Actualizar estado de la sesión
      final revokedSession = await _updateSession(
        sessionId,
        isActive: false,
      );
      
      if (revokedSession != null) {
        // Emitir evento de sesión revocada
        _eventController.add(ConcurrentSessionEvent(
          type: ConcurrentSessionEventType.sessionRevoked,
          userId: sessionInfo.userId,
          sessionInfo: revokedSession,
          message: reason,
        ));
        
        'ConcurrentSessionService: Sesión revocada exitosamente'.debug(context: {
          'sessionId': sessionId,
          'userId': sessionInfo.userId,
        });
        
        return true;
      }
      
      return false;
    } catch (e) {
      'Error revocando sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
      return false;
    }
  }

  /// NUEVO: Revocar todas las sesiones de un usuario
  Future<int> revokeAllUserSessions(String userId, {String? excludeSessionId, String? reason}) async {
    try {
      'ConcurrentSessionService: Revocando todas las sesiones del usuario'.debug(context: {
        'userId': userId,
        'excludeSessionId': excludeSessionId,
      });
      
      final activeSessions = await getUserActiveSessions(userId);
      int revokedCount = 0;
      
      for (final session in activeSessions) {
        if (excludeSessionId != null && session.sessionId == excludeSessionId) {
          continue;  // Omitir sesión excluida
        }
        
        final success = await revokeSession(session.sessionId, reason: reason);
        if (success) {
          revokedCount++;
        }
      }
      
      'ConcurrentSessionService: Sesiones del usuario revocadas'.debug(context: {
        'userId': userId,
        'revokedCount': revokedCount,
        'totalSessions': activeSessions.length,
      });
      
      return revokedCount;
    } catch (e) {
      'Error revocando todas las sesiones del usuario'.error(error: e, context: {
        'userId': userId,
      });
      return 0;
    }
  }

  /// NUEVO: Obtener sesiones activas de un usuario
  Future<List<ConcurrentSessionInfo>> getUserActiveSessions(String userId) async {
    try {
      'ConcurrentSessionService: Obteniendo sesiones activas del usuario'.debug(context: {
        'userId': userId,
      });
      
      final prefs = await SharedPreferences.getInstance();
      final userSessionsKey = _userSessionsKeyPrefix + userId;
      final sessionIdsJson = prefs.getString(userSessionsKey);
      
      if (sessionIdsJson == null) {
        return [];
      }
      
      final List<String> sessionIds = List<String>.from(jsonDecode(sessionIdsJson));
      final List<ConcurrentSessionInfo> activeSessions = [];
      
      for (final sessionId in sessionIds) {
        final sessionInfo = await _getSession(sessionId) ?? _sessionCache[sessionId];
        if (sessionInfo != null && sessionInfo.isActive && !sessionInfo.isExpired) {
          activeSessions.add(sessionInfo);
        } else if (sessionInfo != null && sessionInfo.isExpired) {
          // Limpiar sesión expirada
          await _cleanupSession(sessionId);
        }
      }
      
      'ConcurrentSessionService: Sesiones activas del usuario obtenidas'.debug(context: {
        'userId': userId,
        'activeSessions': activeSessions.length,
      });
      
      return activeSessions;
    } catch (e) {
      'Error obteniendo sesiones activas del usuario'.error(error: e, context: {
        'userId': userId,
      });
      return [];
    }
  }

  /// NUEVO: Detectar conflictos de sesión
  Future<List<ConcurrentSessionInfo>> detectSessionConflicts(String userId) async {
    try {
      'ConcurrentSessionService: Detectando conflictos de sesión'.debug(context: {
        'userId': userId,
      });
      
      final activeSessions = await getUserActiveSessions(userId);
      final List<ConcurrentSessionInfo> conflictingSessions = [];
      
      // Verificar sesiones con misma dirección IP pero diferentes dispositivos
      final Map<String, List<ConcurrentSessionInfo>> ipSessions = {};
      
      for (final session in activeSessions) {
        if (session.ipAddress != null) {
          if (!ipSessions.containsKey(session.ipAddress)) {
            ipSessions[session.ipAddress!] = [];
          }
          ipSessions[session.ipAddress]!.add(session);
        }
      }
      
      // Identificar conflictos
      for (final entry in ipSessions.entries) {
        if (entry.value.length > 1) {
          // Múltiples sesiones desde la misma IP
          conflictingSessions.addAll(entry.value);
          
          'ConcurrentSessionService: Conflicto detectado - múltiples sesiones desde misma IP'.warn(context: {
            'userId': userId,
            'ipAddress': entry.key,
            'sessionCount': entry.value.length,
          });
          
          // Emitir evento de conflicto
          _eventController.add(ConcurrentSessionEvent(
            type: ConcurrentSessionEventType.conflictDetected,
            userId: userId,
            message: 'Múltiples sesiones desde la misma IP: ${entry.key}',
          ));
        }
      }
      
      // Verificar sesiones con actividad sospechosa
      final now = DateTime.now();
      for (final session in activeSessions) {
        final timeSinceLastActivity = now.difference(session.lastActivity);
        
        // Sesión con mucha actividad en poco tiempo (posible bot)
        if (timeSinceLastActivity.inSeconds < 5 && session.metadata != null) {
          final activityCount = session.metadata!['activityCount'] ?? 0;
          if (activityCount > 50) {
            conflictingSessions.add(session);
            
            'ConcurrentSessionService: Conflicto detectado - actividad sospechosa'.warn(context: {
              'userId': userId,
              'sessionId': session.sessionId,
              'activityCount': activityCount,
            });
            
            // Emitir evento de conflicto
            _eventController.add(ConcurrentSessionEvent(
              type: ConcurrentSessionEventType.conflictDetected,
              userId: userId,
              sessionInfo: session,
              message: 'Actividad sospechosa detectada',
            ));
          }
        }
      }
      
      return conflictingSessions;
    } catch (e) {
      'Error detectando conflictos de sesión'.error(error: e, context: {
        'userId': userId,
      });
      return [];
    }
  }

  /// NUEVO: Limpiar sesiones expiradas
  Future<int> cleanupExpiredSessions() async {
    try {
      'ConcurrentSessionService: Limpiando sesiones expiradas';
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final sessionKeys = keys.where((key) => key.startsWith(_sessionKeyPrefix));
      
      int cleanedCount = 0;
      
      for (final key in sessionKeys) {
        try {
          final sessionJson = prefs.getString(key);
          if (sessionJson != null) {
            final sessionData = jsonDecode(sessionJson);
            final sessionInfo = ConcurrentSessionInfo.fromJson(sessionData);
            
            // Si la sesión está expirada o inactiva, eliminarla
            if (sessionInfo.isExpired || !sessionInfo.isRecentlyActive) {
              await _cleanupSession(sessionInfo.sessionId);
              cleanedCount++;
            }
          }
        } catch (e) {
          // Si hay error al procesar una sesión, eliminarla
          final sessionId = key.substring(_sessionKeyPrefix.length);
          await _cleanupSession(sessionId);
          cleanedCount++;
        }
      }
      
      'ConcurrentSessionService: Sesiones expiradas limpiadas'.debug(context: {
        'cleanedCount': cleanedCount,
      });
      
      return cleanedCount;
    } catch (e) {
      'Error limpiando sesiones expiradas'.error(error: e);
      return 0;
    }
  }

  /// NUEVO: Obtener estadísticas de sesiones
  Future<Map<String, dynamic>> getSessionStats() async {
    try {
      'ConcurrentSessionService: Obteniendo estadísticas de sesiones';
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final sessionKeys = keys.where((key) => key.startsWith(_sessionKeyPrefix));
      
      int totalSessions = 0;
      int activeSessions = 0;
      int expiredSessions = 0;
      int inactiveSessions = 0;
      
      for (final key in sessionKeys) {
        try {
          final sessionJson = prefs.getString(key);
          if (sessionJson != null) {
            final sessionData = jsonDecode(sessionJson);
            final sessionInfo = ConcurrentSessionInfo.fromJson(sessionData);
            
            totalSessions++;
            
            if (sessionInfo.isExpired) {
              expiredSessions++;
            } else if (sessionInfo.isRecentlyActive) {
              activeSessions++;
            } else {
              inactiveSessions++;
            }
          }
        } catch (e) {
          // Error al procesar sesión, contar como expirada
          expiredSessions++;
        }
      }
      
      return {
        'totalSessions': totalSessions,
        'activeSessions': activeSessions,
        'expiredSessions': expiredSessions,
        'inactiveSessions': inactiveSessions,
        'maxConcurrentSessions': _maxConcurrentSessions,
        'sessionLifetime': _sessionLifetime.inHours,
        'inactiveTimeout': _inactiveTimeout.inMinutes,
      };
    } catch (e) {
      'Error obteniendo estadísticas de sesiones'.error(error: e);
      return {};
    }
  }

  /// NUEVO: Generar ID de sesión único
  String _generateSessionId(String userId, String deviceId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return '${userId}_${deviceId}_${timestamp}_$random';
  }

  /// NUEVO: Guardar sesión en SharedPreferences
  Future<void> _saveSession(ConcurrentSessionInfo sessionInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _sessionKeyPrefix + sessionInfo.sessionId;
      await prefs.setString(sessionKey, jsonEncode(sessionInfo.toJson()));
    } catch (e) {
      'Error guardando sesión'.error(error: e, context: {
        'sessionId': sessionInfo.sessionId,
      });
    }
  }

  /// NUEVO: Obtener sesión desde SharedPreferences
  Future<ConcurrentSessionInfo?> _getSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _sessionKeyPrefix + sessionId;
      final sessionJson = prefs.getString(sessionKey);
      
      if (sessionJson == null) {
        return null;
      }
      
      final sessionData = jsonDecode(sessionJson);
      return ConcurrentSessionInfo.fromJson(sessionData);
    } catch (e) {
      'Error obteniendo sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
      return null;
    }
  }

  /// NUEVO: Actualizar sesión
  Future<ConcurrentSessionInfo?> _updateSession(
    String sessionId, {
    DateTime? lastActivity,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final sessionInfo = await _getSession(sessionId) ?? _sessionCache[sessionId];
      if (sessionInfo == null) {
        return null;
      }
      
      final updatedSession = ConcurrentSessionInfo(
        sessionId: sessionInfo.sessionId,
        userId: sessionInfo.userId,
        deviceId: sessionInfo.deviceId,
        ipAddress: sessionInfo.ipAddress,
        userAgent: sessionInfo.userAgent,
        createdAt: sessionInfo.createdAt,
        lastActivity: lastActivity ?? sessionInfo.lastActivity,
        isActive: isActive ?? sessionInfo.isActive,
        metadata: metadata ?? sessionInfo.metadata,
      );
      
      // Actualizar en cache
      _sessionCache[sessionId] = updatedSession;
      
      // Guardar en SharedPreferences
      await _saveSession(updatedSession);
      
      // Emitir evento de sesión actualizada
      _eventController.add(ConcurrentSessionEvent(
        type: ConcurrentSessionEventType.sessionUpdated,
        userId: updatedSession.userId,
        sessionInfo: updatedSession,
      ));
      
      return updatedSession;
    } catch (e) {
      'Error actualizando sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
      return null;
    }
  }

  /// NUEVO: Actualizar lista de sesiones del usuario
  Future<void> _updateUserSessions(String userId, String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userSessionsKey = _userSessionsKeyPrefix + userId;
      
      // Obtener sesiones actuales del usuario
      final sessionIdsJson = prefs.getString(userSessionsKey);
      List<String> sessionIds = [];
      
      if (sessionIdsJson != null) {
        sessionIds = List<String>.from(jsonDecode(sessionIdsJson));
      }
      
      // Agregar nueva sesión si no existe
      if (!sessionIds.contains(sessionId)) {
        sessionIds.add(sessionId);
        
        // Guardar lista actualizada
        await prefs.setString(userSessionsKey, jsonEncode(sessionIds));
      }
    } catch (e) {
      'Error actualizando lista de sesiones del usuario'.error(error: e, context: {
        'userId': userId,
        'sessionId': sessionId,
      });
    }
  }

  /// NUEVO: Revocar la sesión más antigua de un usuario
  Future<void> _revokeOldestSession(String userId) async {
    try {
      final activeSessions = await getUserActiveSessions(userId);
      if (activeSessions.isEmpty) {
        return;
      }
      
      // Ordenar por fecha de creación (más antigua primero)
      activeSessions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      final oldestSession = activeSessions.first;
      await revokeSession(oldestSession.sessionId, reason: 'Límite de sesiones concurrentes excedido');
    } catch (e) {
      'Error revocando sesión más antigua'.error(error: e, context: {
        'userId': userId,
      });
    }
  }

  /// NUEVO: Limpiar sesión
  Future<void> _cleanupSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _sessionKeyPrefix + sessionId;
      
      // Eliminar sesión
      await prefs.remove(sessionKey);
      
      // Eliminar de cache
      _sessionCache.remove(sessionId);
      
      // Eliminar de lista de sesiones del usuario
      final sessionInfo = await _getSession(sessionId);
      if (sessionInfo != null) {
        final userSessionsKey = _userSessionsKeyPrefix + sessionInfo.userId;
        final sessionIdsJson = prefs.getString(userSessionsKey);
        
        if (sessionIdsJson != null) {
          final sessionIds = List<String>.from(jsonDecode(sessionIdsJson));
          sessionIds.remove(sessionId);
          await prefs.setString(userSessionsKey, jsonEncode(sessionIds));
        }
      }
    } catch (e) {
      'Error limpiando sesión'.error(error: e, context: {
        'sessionId': sessionId,
      });
    }
  }

  /// NUEVO: Liberar recursos
  void dispose() {
    _eventController.close();
    _sessionCache.clear();
    _sessionLocks.clear();
  }
}

/// NUEVO: Provider para manejo de sesiones concurrentes
class ConcurrentSessionProvider extends ChangeNotifier {
  final ConcurrentSessionService _sessionService;
  
  // Estado de sesiones
  ConcurrentSessionInfo? _currentSession;
  List<ConcurrentSessionInfo> _userSessions = [];
  bool _isLoading = false;
  String? _error;
  
  // Stream subscription para eventos de sesión
  StreamSubscription<ConcurrentSessionEvent>? _eventSubscription;

  ConcurrentSessionProvider(this._sessionService) {
    // Escuchar eventos de sesión
    _eventSubscription = _sessionService.events.listen((event) {
      _handleSessionEvent(event);
    });
  }

  // Getters para UI
  ConcurrentSessionInfo? get currentSession => _currentSession;
  List<ConcurrentSessionInfo> get userSessions => _userSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSession => _currentSession != null;
  bool get hasMultipleSessions => _userSessions.length > 1;

  /// NUEVO: Crear nueva sesión
  Future<bool> createSession({
    required String userId,
    required String deviceId,
    String? ipAddress,
    String? userAgent,
    Map<String, dynamic>? metadata,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      'ConcurrentSessionProvider: Creando nueva sesión'.debug(context: {
        'userId': userId,
        'deviceId': deviceId,
      });
      
      _currentSession = await _sessionService.createSession(
        userId: userId,
        deviceId: deviceId,
        ipAddress: ipAddress,
        userAgent: userAgent,
        metadata: metadata,
      );
      
      if (_currentSession != null) {
        await _loadUserSessions(userId);
        
        'ConcurrentSessionProvider: Sesión creada exitosamente'.debug(context: {
          'sessionId': _currentSession!.sessionId,
          'userId': userId,
        });
        
        return true;
      } else {
        _error = 'Error creando sesión';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      'Error creando sesión en provider'.error(error: e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// NUEVO: Actualizar actividad de sesión actual
  Future<void> updateSessionActivity() async {
    if (_currentSession == null) return;
    
    try {
      final success = await _sessionService.updateSessionActivity(_currentSession!.sessionId);
      
      if (success) {
        // Actualizar última actividad en sesión actual
        _currentSession = ConcurrentSessionInfo(
          sessionId: _currentSession!.sessionId,
          userId: _currentSession!.userId,
          deviceId: _currentSession!.deviceId,
          ipAddress: _currentSession!.ipAddress,
          userAgent: _currentSession!.userAgent,
          createdAt: _currentSession!.createdAt,
          lastActivity: DateTime.now(),
          isActive: _currentSession!.isActive,
          metadata: _currentSession!.metadata,
        );
        
        notifyListeners();
      }
    } catch (e) {
      'Error actualizando actividad de sesión en provider'.error(error: e);
    }
  }

  /// NUEVO: Verificar si la sesión actual es válida
  Future<bool> isSessionValid() async {
    if (_currentSession == null) return false;
    
    try {
      return await _sessionService.isSessionValid(_currentSession!.sessionId);
    } catch (e) {
      'Error verificando validez de sesión en provider'.error(error: e);
      return false;
    }
  }

  /// NUEVO: Revocar sesión actual
  Future<bool> revokeCurrentSession({String? reason}) async {
    if (_currentSession == null) return false;
    
    try {
      final success = await _sessionService.revokeSession(
        _currentSession!.sessionId,
        reason: reason,
      );
      
      if (success) {
        _currentSession = null;
        _userSessions = [];
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      'Error revocando sesión actual en provider'.error(error: e);
      return false;
    }
  }

  /// NUEVO: Cargar sesiones del usuario
  Future<void> _loadUserSessions(String userId) async {
    try {
      _userSessions = await _sessionService.getUserActiveSessions(userId);
      notifyListeners();
    } catch (e) {
      'Error cargando sesiones del usuario en provider'.error(error: e);
    }
  }

  /// NUEVO: Manejar eventos de sesión
  void _handleSessionEvent(ConcurrentSessionEvent event) {
    switch (event.type) {
      case ConcurrentSessionEventType.sessionCreated:
        if (event.sessionInfo != null && 
            _currentSession != null && 
            event.sessionInfo!.sessionId == _currentSession!.sessionId) {
          _currentSession = event.sessionInfo!;
          notifyListeners();
        }
        break;
        
      case ConcurrentSessionEventType.sessionRevoked:
        if (event.sessionInfo != null && 
            _currentSession != null && 
            event.sessionInfo!.sessionId == _currentSession!.sessionId) {
          _currentSession = null;
          _userSessions = [];
          notifyListeners();
        }
        break;
        
      case ConcurrentSessionEventType.sessionUpdated:
        if (event.sessionInfo != null && 
            _currentSession != null && 
            event.sessionInfo!.sessionId == _currentSession!.sessionId) {
          _currentSession = event.sessionInfo!;
          notifyListeners();
        }
        break;
        
      case ConcurrentSessionEventType.conflictDetected:
        'Conflicto de sesión detectado en provider'.warn(context: {
          'userId': event.userId,
          'message': event.message,
        });
        break;
        
      case ConcurrentSessionEventType.maxSessionsExceeded:
        'Límite de sesiones concurrentes excedido en provider'.warn(context: {
          'userId': event.userId,
        });
        break;
        
      default:
        break;
    }
  }

  /// NUEVO: Limpiar errores
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// NUEVO: Liberar recursos
  @override
  void dispose() {
    _eventSubscription?.cancel();
    _sessionService.dispose();
    super.dispose();
  }
}

/// NUEVO: Singleton del servicio
final concurrentSessionService = ConcurrentSessionService();