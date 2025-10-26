import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simple_models.dart';

class SimpleUsuarioService {
  static const String baseUrl = 'http://localhost:54112/api';

  // Obtener todos los usuarios
  Future<List<SimpleUsuario>> getUsuarios() async {
    try {
      print('🔍 UsuarioService: Fetching usuarios...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 UsuarioService: Response status: ${response.statusCode}');
      print('🔍 UsuarioService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final usuarios = jsonList.map((json) => SimpleUsuario.fromJson(json)).toList();
        
        print('✅ UsuarioService: Successfully loaded ${usuarios.length} usuarios');
        return usuarios;
      } else {
        print('❌ UsuarioService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ UsuarioService: Exception: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Crear nuevo usuario
  Future<SimpleUsuario> createUsuario(SimpleUsuario usuario, String password) async {
    try {
      print('📝 UsuarioService: Creating usuario...');
      
      final createData = usuario.toCreateJson();
      createData['password'] = password; // Agregar password para creación
      
      print('📝 UsuarioService: Data to send: $createData');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(createData),
      );

      print('📝 UsuarioService: Response status: ${response.statusCode}');
      print('📝 UsuarioService: Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final usuarioCreado = SimpleUsuario.fromJson(responseData['user']);
        
        print('✅ UsuarioService: Usuario created with ID: ${usuarioCreado.id}');
        return usuarioCreado;
      } else {
        print('❌ UsuarioService: Error ${response.statusCode}: ${response.body}');
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      print('❌ UsuarioService: Exception: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar usuario
  Future<SimpleUsuario> updateUsuario(String id, SimpleUsuario usuario) async {
    try {
      print('📝 UsuarioService: Updating usuario $id...');
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );

      print('📝 UsuarioService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final usuarioActualizado = SimpleUsuario.fromJson(json.decode(response.body));
        print('✅ UsuarioService: Usuario updated successfully');
        return usuarioActualizado;
      } else {
        print('❌ UsuarioService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ UsuarioService: Exception: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Eliminar usuario
  Future<void> deleteUsuario(String id) async {
    try {
      print('🗑️ UsuarioService: Deleting usuario $id...');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🗑️ UsuarioService: Response status: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        print('❌ UsuarioService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
      
      print('✅ UsuarioService: Usuario deleted successfully');
    } catch (e) {
      print('❌ UsuarioService: Exception: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Activar/Desactivar usuario
  Future<SimpleUsuario> toggleUsuarioActivo(String id, bool activo) async {
    try {
      print('🔄 UsuarioService: Toggling usuario $id to ${activo ? "active" : "inactive"}...');
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id/${activo ? "activate" : "deactivate"}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔄 UsuarioService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final usuarioActualizado = SimpleUsuario.fromJson(json.decode(response.body));
        print('✅ UsuarioService: Usuario status updated successfully');
        return usuarioActualizado;
      } else {
        print('❌ UsuarioService: Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al cambiar estado del usuario: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ UsuarioService: Exception: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
