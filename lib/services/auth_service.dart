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

  /// Inicializar el servicio de autenticaciÃ³n
  Future<void> initialize() async {
    try {
      
      // Cargar datos existentes del storage
      await _loadAuthData();
      
      // Verificar si el token actual es vÃ¡lido
      if (_currentToken != null && !isTokenExpired(_currentToken!)) {
      } else {
        if (_currentToken != null) {
        }
        await clearAuth();
      }

    } catch (e) {
      await clearAuth();
    }
  }
  
  /// Cargar datos de autenticaciÃ³n desde storage
  Future<void> _loadAuthData() async {
    try {
      
      final prefs = await SharedPreferences.getInstance();
      
      _currentToken = prefs.getString(_tokenKey);
      _refreshToken = prefs.getString(_refreshTokenKey);
      final userJson = prefs.getString(_userKey);

      
      // Verificar tambiÃ©n en secure storage
      final secureToken = await _secureStorage.read(key: _tokenKey);
      final secureUser = await _secureStorage.read(key: 'user_data');

      if (userJson != null) {
        _currentUser = json.decode(userJson);
      }
      
    } catch (e) {
    }
  }

  /// Login con email y password
  Future<bool> login(String email, String password) async {
    try {

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


          // Guardar en storage
          await _saveAuthData();

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
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


      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          return true;
        } else {
          throw Exception(data['error'] ?? 'Error en el registro');
        }
      } else if (response.statusCode == 409) {
        throw Exception('El email ya estÃ¡ registrado');
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Error en el registro');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await clearAuth();
    } catch (e) {
    }
  }

  /// Limpiar datos de autenticaciÃ³n
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

  /// Verificar si el token estÃ¡ expirado
  bool isTokenExpired(String token) {
    try {
      // Para tokens demo, considerar vÃ¡lidos por 24 horas
      if (token.startsWith('demo-') || token.startsWith('eyJ')) {
        return false; // Token demo siempre vÃ¡lido
      }
      return JwtDecoder.isExpired(token);
    } catch (e) {
      // Para tokens demo, no considerar expirados
      if (token.startsWith('demo-') || token.startsWith('eyJ')) {
        return false;
      }
      return true;
    }
  }

  /// Verificar si necesita renovar el token
  bool needsRefresh() {
    if (_currentToken == null) return false;
    
    try {
      // Para tokens demo, no renovar
      if (_currentToken!.startsWith('demo-') || _currentToken!.startsWith('eyJ')) {
        return false;
      }
      
      final expiryDate = JwtDecoder.getExpirationDate(_currentToken!);
      final now = DateTime.now();
      final timeUntilExpiry = expiryDate.difference(now);
      
      // Renovar si expira en menos de 5 minutos
      return timeUntilExpiry.inMinutes < 5;
    } catch (e) {
      // Para tokens demo, no renovar
      if (_currentToken != null && (_currentToken!.startsWith('demo-') || _currentToken!.startsWith('eyJ'))) {
        return false;
      }
      return false; // No renovar si hay error
    }
  }

  /// Renovar token si es necesario
  Future<bool> _refreshTokenIfNeeded() async {
    if (_refreshToken == null) {
      await clearAuth();
      return false;
    }

    try {

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
          final responseData = data['data'];
          _currentToken = responseData['token'];
          _refreshToken = responseData['refreshToken'];
          _currentUser = responseData['user'];

          await _saveAuthData();

          return true;
        }
      }

      await clearAuth();
      return false;
    } catch (e) {
      await clearAuth();
      return false;
    }
  }

  /// Guardar datos de autenticaciÃ³n en storage
  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar en SharedPreferences
    if (_currentToken != null) {
      await prefs.setString(_tokenKey, _currentToken!);
      // TambiÃ©n guardar en secure storage para ApiService
      await _secureStorage.write(key: _tokenKey, value: _currentToken!);
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

  /// Verificar si el usuario tiene un rol especÃ­fico
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

  /// Verificar si el usuario es mÃ©dico o admin
  bool isMedico() {
    return hasAnyRole(['medico', 'admin', 'super_admin']);
  }

  /// Verificar si el usuario es gestante
  bool isGestante() {
    return hasRole('gestante');
  }



  /// Obtener headers de autenticaciÃ³n
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

  /// Hacer una peticiÃ³n HTTP autenticada con renovaciÃ³n automÃ¡tica de token
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

    // Debug mÃ­nimo para verificar conexiÃ³n y auth
    if (kDebugMode && body != null) {
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
        throw ArgumentError('MÃ©todo HTTP no soportado: $method');
    }

    return resp;
  }
}

