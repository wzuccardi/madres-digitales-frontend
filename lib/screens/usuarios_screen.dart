import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import '../shared/widgets/app_bar_with_logo.dart';
import '../providers/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsuariosScreen extends ConsumerStatefulWidget {
  const UsuariosScreen({super.key});

  @override
  ConsumerState<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends ConsumerState<UsuariosScreen> {
  late final UsuarioService _usuarioService;
  List<UsuarioModel> _usuarios = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usuarioService = ref.read(usuarioServiceProvider);
    _loadUsuarios();
  }


  Future<void> _loadUsuarios() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final usuarios = await _usuarioService.obtenerUsuarios();
      
      setState(() {
        _usuarios = usuarios;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleUsuarioActivo(UsuarioModel usuario) async {
    try {
      final usuarioActualizado = usuario.copyWith(activo: !usuario.activo);
      await _usuarioService.actualizarUsuario(usuario.id, usuarioActualizado);
      _loadUsuarios(); // Recargar la lista
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            usuario.activo
                ? 'Usuario desactivado exitosamente'
                : 'Usuario activado exitosamente'
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUsuario(UsuarioModel usuario) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminaciÃ³n'),
        content: Text('Â¿EstÃ¡ seguro de eliminar al usuario "${usuario.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _usuarioService.eliminarUsuario(usuario.id);
        _loadUsuarios(); // Recargar la lista
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'GestiÃ³n de Usuarios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsuarios,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          context.push('/usuarios/nuevo');
          
          // Recargar despuÃ©s de un delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _loadUsuarios();
            }
          });
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar usuarios',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUsuarios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay usuarios registrados',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsuarios,
      child: ListView.builder(
        itemCount: _usuarios.length,
        itemBuilder: (context, index) {
          final usuario = _usuarios[index];
          return _buildUsuarioCard(usuario);
        },
      ),
    );
  }

  Widget _buildUsuarioCard(UsuarioModel usuario) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRolColor(usuario.rol),
          child: Icon(
            _getRolIcon(usuario.rol),
            color: Colors.white,
          ),
        ),
        title: Text(
          usuario.nombreCompleto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email),
            Text(
              usuario.rol,
              style: TextStyle(
                color: _getRolColor(usuario.rol),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador de estado activo/inactivo
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: usuario.activo ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'toggle':
                    _toggleUsuarioActivo(usuario);
                    break;
                  case 'delete':
                    _deleteUsuario(usuario);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        usuario.activo ? Icons.block : Icons.check_circle,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(usuario.activo ? 'Desactivar' : 'Activar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol.toUpperCase()) {
      case 'ADMIN':
        return Colors.purple;
      case 'COORDINADOR':
        return Colors.blue;
      case 'MEDICO':
        return Colors.green;
      case 'MADRINA':
        return Colors.orange;
      case 'GESTANTE':
        return Colors.pink;
      case 'SUPER_ADMIN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRolIcon(String rol) {
    switch (rol.toUpperCase()) {
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'COORDINADOR':
        return Icons.supervisor_account;
      case 'MEDICO':
        return Icons.medical_services;
      case 'MADRINA':
        return Icons.favorite;
      case 'GESTANTE':
        return Icons.pregnant_woman;
      case 'SUPER_ADMIN':
        return Icons.security;
      default:
        return Icons.person;
    }
  }
}

