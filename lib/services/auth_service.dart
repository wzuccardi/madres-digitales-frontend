import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class AuthService {
  static final String baseUrl = AppConfig.getApiUrl();
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Secure storage para tokens
  final _secureStorage = const FlutterSecureStorage();

  String? _currentToken;
  String? _refreshToken;
  Map<String, dynamic>? _currentUser;

  // Getters
  String? get currentToken => _currentToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _currentToken != null && !isTokenExpired(_currentToken!);
  String? get userRole => _currentUser?['rol'];
  String? get userId => _currentUser?['id'];
  String? get userName => _currentUser?['nombre'];
  String? get userEmail => _currentUser?['email'];

  /// Inicializar el servicio de autenticación
  Future<void> initialize() async {
    try {
      debugPrint('🔄 AuthService: Initializing...');
      
      // Cargar datos existentes del storage
      await _loadAuthData();
      
      // Verificar si el token actual es válido
      if (_currentToken != null && !isTokenExpired(_currentToken!)) {
        debugPrint('✅ AuthService: Token válido encontrado');
      } else {
        debugPrint('⚠️ AuthService: Token inválido o expirado, requiere login manual');
        await clearAuth();
      }

      debugPrint('🔐 AuthService: Inicializado - Autenticado: $isAuthenticated');
    } catch (e) {
      debugPrint('❌ AuthService: Error al inicializar: $e');
      await clearAuth();
    }
  }
  
  /// Cargar datos de autenticación desde storage
  Future<void> _loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentToken = prefs.getString(_tokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      final userJson = prefs.getString(_userKey);

      debugPrint('🔍 AuthService: Token exists: ${_currentToken != null}');
      debugPrint('🔍 AuthService: User JSON: $userJson');

      if (userJson != null) {
        _currentUser = json.decode(userJson);
        debugPrint('✅ AuthService: User loaded from storage');
        debugPrint('   - ID: ${_currentUser?['id']}');
        debugPrint('   - Email: ${_currentUser?['email']}');
        debugPrint('   - Nombre: ${_currentUser?['nombre']}');
        debugPrint('   - ROL: ${_currentUser?['rol']}');
        debugPrint('   - isAdmin(): ${isAdmin()}');
        debugPrint('   - isSuperAdmin(): ${isSuperAdmin()}');
      }
    } catch (e) {
      debugPrint('❌ AuthService: Error cargando datos de autenticación: $e');
    }
  }

  /// Login con email y password
  Future<bool> login(String email, String password) async {
    try {
      debugPrint('🔐 AuthService: Intentando login para $email');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final responseData = data['data'];
          _currentToken = responseData['token'];
          _refreshToken = responseData['refreshToken'];
          _currentUser = responseData['usuario'];

          debugPrint('📦 AuthService: Datos recibidos del backend:');
          debugPrint('   - Token: ${_currentToken != null ? "✅" : "❌"}');
          debugPrint('   - RefreshToken: ${_refreshToken != null ? "✅" : "❌"}');
          debugPrint('   - User data: $_currentUser');
          debugPrint('   - ROL recibido: ${_currentUser?['rol']}');

          // Guardar en storage
          await _saveAuthData();

          debugPrint('✅ AuthService: Login exitoso para ${_currentUser?['nombre']}');
          debugPrint('   - isAdmin(): ${isAdmin()}');
          debugPrint('   - isSuperAdmin(): ${isSuperAdmin()}');
          return true;
        } else {
          debugPrint('❌ AuthService: Login fallido - ${data['message']}');
          return false;
        }
      } else {
        debugPrint('❌ AuthService: Error HTTP ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ AuthService: Error en login: $e');
      return false;
    }
  }

  /// Registro de nuevo usuario
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? documento,
    String? telefono,
  }) async {
    try {
      debugPrint('🔐 AuthService: Intentando registro para $email con rol $rol');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'nombre': nombre,
          'email': email,
          'password': password,
          'rol': rol,
          if (documento != null) 'documento': documento,
          if (telefono != null) 'telefono': telefono,
        }),
      );

      debugPrint('🔍 AuthService: Respuesta de registro - Status: ${response.statusCode}');
      debugPrint('🔍 AuthService: Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          debugPrint('✅ AuthService: Registro exitoso para $email');
          return true;
        } else {
          debugPrint('❌ AuthService: Registro falló - ${data['error']}');
          throw Exception(data['error'] ?? 'Error en el registro');
        }
      } else if (response.statusCode == 409) {
        debugPrint('❌ AuthService: Email ya registrado');
        throw Exception('El email ya está registrado');
      } else {
        final data = json.decode(response.body);
        debugPrint('❌ AuthService: Error HTTP ${response.statusCode}');
        throw Exception(data['error'] ?? 'Error en el registro');
      }
    } catch (e) {
      debugPrint('❌ AuthService: Error en registro: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      debugPrint('🔐 AuthService: Cerrando sesión...');
      await clearAuth();
      debugPrint('✅ AuthService: Sesión cerrada exitosamente');
    } catch (e) {
      debugPrint('❌ AuthService: Error al cerrar sesión: $e');
    }
  }

  /// Limpiar datos de autenticación
  Future<void> clearAuth() async {
    _currentToken = null;
    _refreshToken = null;
    _currentUser = null;

    // Limpiar SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userKey);

    // Limpiar secure storage
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: 'user_data');
  }

  /// Verificar si el token está expirado
  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      debugPrint('❌ AuthService: Error al verificar expiración del token: $e');
      return true;
    }
  }

  /// Verificar si necesita renovar el token
  bool needsRefresh() {
    if (_currentToken == null) return false;
    
    try {
      final expiryDate = JwtDecoder.getExpirationDate(_currentToken!);
      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);
      
      // Renovar si expira en menos de 5 minutos
      return timeUntilExpiry.inMinutes < 5;
    } catch (e) {
      debugPrint('❌ AuthService: Error al verificar necesidad de renovación: $e');
      return true;
    }
  }

  /// Renovar token si es necesario
  Future<bool> _refreshTokenIfNeeded() async {
    if (_refreshToken == null) {
      debugPrint('❌ AuthService: No hay refresh token disponible');
      await clearAuth();
      return false;
    }

    try {
      debugPrint('🔄 AuthService: Renovando token...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'refreshToken': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          _currentToken = data['token'];
          _refreshToken = data['refreshToken'];
          _currentUser = data['user'];

          await _saveAuthData();

          debugPrint('✅ AuthService: Token renovado exitosamente');
          return true;
        }
      }

      debugPrint('❌ AuthService: Error al renovar token');
      await clearAuth();
      return false;
    } catch (e) {
      debugPrint('❌ AuthService: Error al renovar token: $e');
      await clearAuth();
      return false;
    }
  }

  /// Guardar datos de autenticación en storage
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar en SharedPreferences
    if (_currentToken != null) {
      await prefs.setString(_tokenKey, _currentToken!);
      // También guardar en secure storage para ApiService
      await _secureStorage.write(key: _tokenKey, value: _currentToken!);
      debugPrint('🔐 AuthService: Token guardado en secure storage con clave: $_tokenKey');
      debugPrint('🔐 AuthService: Token guardado: ${_currentToken!.substring(0, 20)}...');
    }
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
      await _secureStorage.write(key: _refreshTokenKey, value: _refreshToken!);
    }
    if (_currentUser != null) {
      await prefs.setString(_userKey, json.encode(_currentUser!));
      await _secureStorage.write(key: 'user_data', value: json.encode(_currentUser!));
    }
  }

  /// Verificar si el usuario tiene un rol específico
  bool hasRole(String role) {
    return userRole == role;
  }

  /// Verificar si el usuario tiene alguno de los roles especificados
  bool hasAnyRole(List<String> roles) {
    return roles.contains(userRole);
  }

  /// Verificar si el usuario es super admin
  bool isSuperAdmin() {
    return hasRole('super_admin');
  }

  /// Verificar si el usuario es admin o super admin
  bool isAdmin() {
    return hasAnyRole(['admin', 'super_admin']);
  }

  /// Verificar si el usuario es coordinador, admin o super admin
  bool isCoordinador() {
    return hasAnyRole(['coordinador', 'admin', 'super_admin']);
  }

  /// Verificar si el usuario es madrina o superior
  bool isMadrina() {
    return hasAnyRole(['madrina', 'coordinador', 'admin', 'super_admin']);
  }

  /// Verificar si el usuario es médico o admin
  bool isMedico() {
    return hasAnyRole(['medico', 'admin', 'super_admin']);
  }

  /// Verificar si el usuario es gestante
  bool isGestante() {
    return hasRole('gestante');
  }



  /// Obtener headers de autenticación
  Map<String, String> getAuthHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_currentToken != null) {
      headers['Authorization'] = 'Bearer $_currentToken';
    }

    return headers;
  }

  /// Hacer una petición HTTP autenticada con renovación automática de token
  Future<http.Response> authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    // Renovar token si es necesario
    if (needsRefresh()) {
      await _refreshTokenIfNeeded();
    }

    final headers = getAuthHeaders();
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    final uri = Uri.parse('$baseUrl$endpoint');

    // Debug mínimo para verificar conexión y auth
    debugPrint('🔗 [AuthRequest] ${method.toUpperCase()} $uri');
    debugPrint('🔗 [AuthRequest] Bearer present: ${headers.containsKey('Authorization')}');
    if (kDebugMode && body != null) {
      debugPrint('📝 [AuthRequest] body keys: ${body.keys.toList()}');
    }

    http.Response resp;
    switch (method.toUpperCase()) {
      case 'GET':
        resp = await http.get(uri, headers: headers);
        break;
      case 'POST':
        resp = await http.post(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        resp = await http.put(
          uri,
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        resp = await http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError('Método HTTP no soportado: $method');
    }

    debugPrint('✅ [AuthRequest] Status: ${resp.statusCode} for $uri');
    return resp;
  }
}
