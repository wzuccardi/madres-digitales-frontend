import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gestante.dart';
import '../providers/gestante_provider.dart';
import '../widgets/assignment_confirmation_dialog.dart';
import '../../../../services/auth_service.dart';

class AssignGestantePage extends ConsumerStatefulWidget {
  const AssignGestantePage({super.key});

  @override
  ConsumerState<AssignGestantePage> createState() => _AssignGestantePageState();
}

class _AssignGestantePageState extends ConsumerState<AssignGestantePage> {
  final _searchController = TextEditingController();
  final _madrinaSearchController = TextEditingController();
  
  String? _selectedGestanteId;
  String? _selectedMadrinaId;
  String? _selectedMadrinaNombre;
  bool _esPrincipal = false;
  int _prioridad = 3;
  String _motivoAsignacion = '';
  
  List<Gestante> _gestantesDisponibles = [];
  List<Map<String, dynamic>> _madrinasDisponibles = [];
  bool _isLoadingGestantes = false;
  bool _isLoadingMadrinas = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadGestantesDisponibles();
    _loadMadrinasDisponibles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _madrinaSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadGestantesDisponibles() async {
    setState(() {
      _isLoadingGestantes = true;
      _errorMessage = null;
    });

    try {
      // Aquí iría la lógica para obtener gestantes disponibles
      // Por ahora, usamos datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _gestantesDisponibles = [
          Gestante(
            id: '1',
            nombres: 'María',
            apellidos: 'González',
            tipoDocumento: 'CC',
            numeroDocumento: '12345678',
            telefono: '3001234567',
            fechaNacimiento: DateTime(1990, 5, 15),
            direccion: 'Calle 123 #45-67',
            eps: 'SURA',
            regimen: 'Contributivo',
            fechaCreacion: DateTime.now(),
            activa: true,
            creadaPor: 'system',
          ),
          Gestante(
            id: '2',
            nombres: 'Ana',
            apellidos: 'López',
            tipoDocumento: 'CC',
            numeroDocumento: '87654321',
            telefono: '3012345678',
            fechaNacimiento: DateTime(1985, 8, 22),
            direccion: 'Carrera 45 #67-89',
            eps: 'Nueva EPS',
            regimen: 'Subsidiado',
            fechaCreacion: DateTime.now(),
            activa: true,
            creadaPor: 'system',
          ),
        ];
        _isLoadingGestantes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGestantes = false;
        _errorMessage = 'Error al cargar gestantes: $e';
      });
    }
  }

  Future<void> _loadMadrinasDisponibles() async {
    setState(() {
      _isLoadingMadrinas = true;
      _errorMessage = null;
    });

    try {
      // Aquí iría la lógica para obtener madrinas disponibles
      // Por ahora, usamos datos de ejemplo
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _madrinasDisponibles = [
          {'id': 'm1', 'nombre': 'Carmen Rodríguez', 'cantidadGestantes': 5},
          {'id': 'm2', 'nombre': 'Laura Martínez', 'cantidadGestantes': 3},
          {'id': 'm3', 'nombre': 'Patricia Gómez', 'cantidadGestantes': 7},
          {'id': 'm4', 'nombre': 'Sofía Hernández', 'cantidadGestantes': 2},
        ];
        _isLoadingMadrinas = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMadrinas = false;
        _errorMessage = 'Error al cargar madrinas: $e';
      });
    }
  }

  Future<void> _submitAssignment() async {
    if (_selectedGestanteId == null || _selectedMadrinaId == null) {
      setState(() {
        _errorMessage = 'Por favor selecciona una gestante y una madrina';
      });
      return;
    }

    final authService = AuthService();
    if (!authService.isAuthenticated || authService.userId == null) {
      setState(() {
        _errorMessage = 'Usuario no autenticado';
      });
      return;
    }

    final gestante = _gestantesDisponibles.firstWhere((g) => g.id == _selectedGestanteId);
    
    // Mostrar diálogo de confirmación
    showAssignmentConfirmationDialog(
      context: context,
      gestante: gestante,
      madrinaNombre: _selectedMadrinaNombre!,
      esPrincipal: _esPrincipal,
      prioridad: _prioridad,
      motivoAsignacion: _motivoAsignacion,
      onConfirm: () async {
        setState(() {
          _isSubmitting = true;
          _errorMessage = null;
        });

        try {
          final success = await ref.read(gestanteProvider.notifier).assignGestanteToMadrina(
            gestanteId: _selectedGestanteId!,
            madrinaId: _selectedMadrinaId!,
            asignadoPor: authService.userId!,
            tipo: TipoAsignacion.manual,
            esPrincipal: _esPrincipal,
            prioridad: _prioridad,
          );

          if (success) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gestante asignada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          } else {
            setState(() {
              _isSubmitting = false;
              _errorMessage = 'Error al asignar gestante';
            });
          }
        } catch (e) {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'Error: $e';
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Gestante'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selección de gestante
                  _buildSectionTitle('Seleccionar Gestante'),
                  _buildGestanteSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Selección de madrina
                  _buildSectionTitle('Seleccionar Madrina'),
                  _buildMadrinaSelection(),
                  
                  const SizedBox(height: 24),
                  
                  // Opciones de asignación
                  _buildSectionTitle('Opciones de Asignación'),
                  _buildAssignmentOptions(),
                  
                  const SizedBox(height: 24),
                  
                  // Motivo de asignación
                  _buildSectionTitle('Motivo de Asignación'),
                  _buildMotivoField(),
                  
                  const SizedBox(height: 32),
                  
                  // Mensaje de error
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Botón de asignar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAssignment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Asignar Gestante',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink,
        ),
      ),
    );
  }

  Widget _buildGestanteSelection() {
    if (_isLoadingGestantes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar gestante...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // Aquí iría la lógica de búsqueda
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _gestantesDisponibles.length,
              itemBuilder: (context, index) {
                final gestante = _gestantesDisponibles[index];
                final isSelected = gestante.id == _selectedGestanteId;
                
                return Card(
                  color: isSelected ? Colors.pink.withValues(alpha: 0.1) : Colors.white,
                  elevation: isSelected ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: isSelected 
                        ? BorderSide(color: Colors.pink.withValues(alpha: 0.5))
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.pink,
                      child: Text(
                        gestante.nombres.substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(gestante.nombreCompleto),
                    subtitle: Text(
                      '${gestante.tipoDocumento}: ${gestante.numeroDocumento}',
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.pink)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedGestanteId = gestante.id;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMadrinaSelection() {
    if (_isLoadingMadrinas) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: _madrinaSearchController,
            decoration: InputDecoration(
              hintText: 'Buscar madrina...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // Aquí iría la lógica de búsqueda
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _madrinasDisponibles.length,
              itemBuilder: (context, index) {
                final madrina = _madrinasDisponibles[index];
                final isSelected = madrina['id'] == _selectedMadrinaId;
                
                return Card(
                  color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.white,
                  elevation: isSelected ? 3 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: isSelected 
                        ? BorderSide(color: Colors.blue.withValues(alpha: 0.5))
                        : BorderSide.none,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        madrina['nombre'].substring(0, 1),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(madrina['nombre']),
                    subtitle: Text(
                      'Gestantes asignadas: ${madrina['cantidadGestantes']}',
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedMadrinaId = madrina['id'];
                        _selectedMadrinaNombre = madrina['nombre'];
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Asignación Principal'),
            subtitle: const Text('La madrina será responsable principal de la gestante'),
            value: _esPrincipal,
            onChanged: (value) {
              setState(() {
                _esPrincipal = value;
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Prioridad'),
            subtitle: Text('Prioridad: $_prioridad'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _prioridad > 1
                      ? () => setState(() => _prioridad--)
                      : null,
                ),
                Text(
                  '$_prioridad',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _prioridad < 5
                      ? () => setState(() => _prioridad++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivoField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Motivo de la asignación (opcional)',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            _motivoAsignacion = value;
          });
        },
      ),
    );
  }
}