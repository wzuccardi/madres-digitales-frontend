import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/gestante_model.dart';
import '../services/gestante_service.dart';
import '../services/location_service.dart';

class GestantesScreen extends ConsumerStatefulWidget {
  const GestantesScreen({super.key});

  @override
  ConsumerState<GestantesScreen> createState() => _GestantesScreenState();
}

class _GestantesScreenState extends ConsumerState<GestantesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final GestanteService _gestanteService = GestanteService();
  List<GestanteModel> _gestantes = [];
  List<GestanteModel> _filteredGestantes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadGestantes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGestantes() async {
    setState(() => _isLoading = true);
    try {
      final gestantes = await _gestanteService.obtenerGestantes();
      setState(() {
        _gestantes = gestantes;
        _filteredGestantes = gestantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar gestantes: $e')),
        );
      }
    }
  }

  void _filterGestantes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredGestantes = _gestantes;
      } else {
        _filteredGestantes = _gestantes.where((gestante) {
          return gestante.nombres.toLowerCase().contains(query.toLowerCase()) ||
              gestante.apellidos.toLowerCase().contains(query.toLowerCase()) ||
              gestante.numeroDocumento.contains(query);
        }).toList();
      }
    });
  }

  List<GestanteModel> get _gestantesAltoRiesgo {
    return _filteredGestantes.where((g) => g.esAltoRiesgo).toList();
  }

  List<GestanteModel> get _gestantesCercanas {
    // Simulated nearby gestantes - in real app, use location service
    return _filteredGestantes.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestantes'),
        backgroundColor: Colors.pink[100],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas', icon: Icon(Icons.people)),
            Tab(text: 'Alto Riesgo', icon: Icon(Icons.warning)),
            Tab(text: 'Cercanas', icon: Icon(Icons.location_on)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o documento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterGestantes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterGestantes,
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGestantesList(_filteredGestantes),
                _buildGestantesList(_gestantesAltoRiesgo),
                _buildGestantesList(_gestantesCercanas),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGestanteDialog(),
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGestantesList(List<GestanteModel> gestantes) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (gestantes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron gestantes',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGestantes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: gestantes.length,
        itemBuilder: (context, index) {
          final gestante = gestantes[index];
          return _buildGestanteCard(gestante);
        },
      ),
    );
  }

  Widget _buildGestanteCard(GestanteModel gestante) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showGestanteDetail(gestante),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.pink[100],
                    child: Text(
                      '${gestante.nombres[0]}${gestante.apellidos[0]}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${gestante.nombres} ${gestante.apellidos}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'CC: ${gestante.numeroDocumento}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (gestante.esAltoRiesgo)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Alto Riesgo',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    '${gestante.semanasGestacion} semanas',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.cake,
                    '${gestante.edad} años',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  if (gestante.telefono != null)
                    _buildInfoChip(
                      Icons.phone,
                      gestante.telefono!,
                      Colors.orange,
                    ),
                ],
              ),
              if (gestante.direccion != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        gestante.direccion!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showGestanteDetail(GestanteModel gestante) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GestanteDetailSheet(gestante: gestante),
    );
  }

  void _showAddGestanteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddGestanteDialog(),
    );
  }
}

class GestanteDetailSheet extends StatelessWidget {
  final GestanteModel gestante;

  const GestanteDetailSheet({super.key, required this.gestante});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.pink[100],
                  child: Text(
                    '${gestante.nombres[0]}${gestante.apellidos[0]}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${gestante.nombres} ${gestante.apellidos}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'CC: ${gestante.numeroDocumento}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                if (gestante.esAltoRiesgo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Alto Riesgo',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailSection('Información Personal', [
                    _buildDetailRow('Edad', '${gestante.edad} años'),
                    _buildDetailRow('Teléfono', gestante.telefono ?? 'No registrado'),
                    _buildDetailRow('Dirección', gestante.direccion ?? 'No registrada'),
                    _buildDetailRow('Fecha de Nacimiento', 
                        gestante.fechaNacimiento?.toString().split(' ')[0] ?? 'No registrada'),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Información Obstétrica', [
                    _buildDetailRow('Semanas de Gestación', '${gestante.semanasGestacion}'),
                    _buildDetailRow('Fecha Última Menstruación', 
                        gestante.fechaUltimaMenstruacion?.toString().split(' ')[0] ?? 'No registrada'),
                    _buildDetailRow('Fecha Probable de Parto', 
                        gestante.fechaProbableParto?.toString().split(' ')[0] ?? 'No calculada'),
                    _buildDetailRow('Peso Pregestacional', 
                        gestante.pesoPregestacional != null ? '${gestante.pesoPregestacional} kg' : 'No registrado'),
                    _buildDetailRow('IMC Pregestacional', 
                        gestante.imcPregestacional?.toStringAsFixed(1) ?? 'No calculado'),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Estado de Salud', [
                    _buildDetailRow('Alto Riesgo', gestante.esAltoRiesgo ? 'Sí' : 'No'),
                    _buildDetailRow('Factores de Riesgo', 
                        gestante.factoresRiesgo?.join(', ') ?? 'Ninguno'),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to controls
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Ver Controles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to alerts
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text('Ver Alertas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class AddGestanteDialog extends StatefulWidget {
  const AddGestanteDialog({super.key});

  @override
  State<AddGestanteDialog> createState() => _AddGestanteDialogState();
}

class _AddGestanteDialogState extends State<AddGestanteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _documentoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  DateTime? _fechaNacimiento;
  DateTime? _fechaUltimaMenstruacion;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agregar Nueva Gestante',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.pink,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombresController,
                        decoration: const InputDecoration(
                          labelText: 'Nombres',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese los nombres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _apellidosController,
                        decoration: const InputDecoration(
                          labelText: 'Apellidos',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese los apellidos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _documentoController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Documento',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el número de documento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _direccionController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveGestante,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveGestante() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the gestante using the service
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gestante agregada exitosamente')),
      );
    }
  }
}