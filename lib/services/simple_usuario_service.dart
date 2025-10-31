import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/simple_models.dart';

class SimpleUsuarioService {
  static const String baseUrl = 'http://localhost:54112/api';

  // Obtener todos los usuarios
  Future<List<SimpleUsuario>> getUsuarios() async {
    try {
      
      final response = await http.get(
        Uri.parse('$baseUrl/auth/users'),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final usuarios = jsonList.map((json) => SimpleUsuario.fromJson(json)).toList();
        
        return usuarios;
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  // Crear nuevo usuario
  Future<SimpleUsuario> createUsuario(SimpleUsuario usuario, String password) async {
    try {
      
      final createData = usuario.toCreateJson();
      createData['password'] = password; // Agregar password para creaciÃ³n
      

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(createData),
      );


      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final usuarioCreado = SimpleUsuario.fromJson(responseData['user']);
        
        return usuarioCreado;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? 'Error al crear usuario');
      }
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  // Actualizar usuario
  Future<SimpleUsuario> updateUsuario(String id, SimpleUsuario usuario) async {
    try {
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(usuario.toJson()),
      );


      if (response.statusCode == 200) {
        final usuarioActualizado = SimpleUsuario.fromJson(json.decode(response.body));
        return usuarioActualizado;
      } else {
        throw Exception('Error al actualizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  // Eliminar usuario
  Future<void> deleteUsuario(String id) async {
    try {
      
      final response = await http.delete(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar usuario: ${response.statusCode}');
      }
      
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }

  // Activar/Desactivar usuario
  Future<SimpleUsuario> toggleUsuarioActivo(String id, bool activo) async {
    try {
      
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id/${activo ? "activate" : "deactivate"}'),
        headers: {'Content-Type': 'application/json'},
      );


      if (response.statusCode == 200) {
        final usuarioActualizado = SimpleUsuario.fromJson(json.decode(response.body));
        return usuarioActualizado;
      } else {
        throw Exception('Error al cambiar estado del usuario: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexiÃ³n: $e');
    }
  }
}

