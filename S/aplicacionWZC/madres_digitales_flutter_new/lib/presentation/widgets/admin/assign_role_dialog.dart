import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_service.dart';

class AssignRoleDialog extends ConsumerStatefulWidget {
  final String userId;
  final String userName;
  final String currentRole;

  const AssignRoleDialog({
    super.key,
    required this.userId,
    required this.userName,
    required this.currentRole,
  });

  @override
  ConsumerState<AssignRoleDialog> createState() => _AssignRoleDialogState();
}

class _AssignRoleDialogState extends ConsumerState<AssignRoleDialog> {
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentRole.toUpperCase();
  }

  Future<void> _assignRole() async {
    if (_selectedRole == null || _selectedRole == widget.currentRole.toUpperCase()) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      await apiService.patch<Map<String, dynamic>>('/usuarios/${widget.userId}/rol', data: {
        'rol': _selectedRole,
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol asignado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar rol: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Asignar Rol a ${widget.userName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rol actual: ${_getRoleLabel(widget.currentRole)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Selecciona el nuevo rol:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          _buildRoleOption('SUPER_ADMIN', 'Super Administrador', Icons.security, Colors.red),
          _buildRoleOption('ADMIN', 'Administrador', Icons.admin_panel_settings, Colors.purple),
          _buildRoleOption('COORDINADOR', 'Coordinador', Icons.supervisor_account, Colors.blue),
          _buildRoleOption('MADRINA', 'Madrina', Icons.favorite, Colors.orange),
          _buildRoleOption('MEDICO', 'Médico', Icons.medical_services, Colors.green),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _assignRole,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Asignar'),
        ),
      ],
    );
  }

  Widget _buildRoleOption(String value, String label, IconData icon, Color color) {
    final isSelected = _selectedRole == value;
    return InkWell(
      onTap: () => setState(() => _selectedRole = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? color.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'SUPER_ADMIN':
        return 'Super Administrador';
      case 'ADMIN':
        return 'Administrador';
      case 'COORDINADOR':
        return 'Coordinador';
      case 'MADRINA':
        return 'Madrina';
      case 'MEDICO':
        return 'Médico';
      case 'GESTANTE':
        return 'Gestante';
      default:
        return role;
    }
  }
}
