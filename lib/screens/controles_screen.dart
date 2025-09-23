import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/gestante_model.dart';
import '../services/control_prenatal_service.dart';
import '../services/gestante_service.dart';

class ControlesScreen extends ConsumerStatefulWidget {
  const ControlesScreen({super.key});

  @override
  ConsumerState<ControlesScreen> createState() => _ControlesScreenState();
}

class _ControlesScreenState extends ConsumerState<ControlesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ControlPrenatalService _controlService = ControlPrenatalService();
  final GestanteService _gestanteService = GestanteService();
  
  List<ControlPrenatalModel> _controles = [];
  List<ControlPrenatalModel> _controlesVencidos = [];
  List<ControlPrenatalModel> _controlesPendientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadControles();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadControles() async {
    setState(() => _isLoading = true);
    try {
      final controles = await _controlService.obtenerControles();
      final controlesVencidos = await _controlService.obtenerControlesVencidos();
      
      setState(() {
        _controles = controles;
        _controlesVencidos = controlesVencidos;
        _controlesPendientes = controles.where((c) => 
          c.fechaProximoControl != null && 
          c.fechaProximoControl!.isAfter(DateTime.now())
        ).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar controles: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controles Prenatales'),
        backgroundColor: Colors.blue[100],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todos', icon: Icon(Icons.list)),
            Tab(text: 'Vencidos', icon: Icon(Icons.schedule)),
            Tab(text: 'Pendientes', icon: Icon(Icons.pending)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildControlesList(_controles, 'todos'),
          _buildControlesList(_controlesVencidos, 'vencidos'),
          _buildControlesList(_controlesPendientes, 'pendientes'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddControlDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildControlesList(List<ControlPrenatalModel> controles, String tipo) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'vencidos' ? Icons.schedule_outlined : 
              tipo == 'pendientes' ? Icons.pending_outlined : Icons.list_outlined,
              size: 64, 
              color: Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              tipo == 'vencidos' ? 'No hay controles vencidos' :
              tipo == 'pendientes' ? 'No hay controles pendientes' : 'No hay controles registrados',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadControles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controles.length,
        itemBuilder: (context, index) {
          final control = controles[index];
          return _buildControlCard(control, tipo);
        },
      ),
    );
  }

  Widget _buildControlCard(ControlPrenatalModel control, String tipo) {
    final isVencido = tipo == 'vencidos';
    final isPendiente = tipo == 'pendientes';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showControlDetail(control),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isVencido ? Colors.red[100] : 
                             isPendiente ? Colors.orange[100] : Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      color: isVencido ? Colors.red : 
                             isPendiente ? Colors.orange : Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Control #${control.numeroControl}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gestante ID: ${control.gestanteId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isVencido)
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
                        'Vencido',
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
                    DateFormat('dd/MM/yyyy').format(control.fechaControl),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.pregnant_woman,
                    '${control.semanasGestacion} sem',
                    Colors.pink,
                  ),
                  const SizedBox(width: 8),
                  if (control.peso != null)
                    _buildInfoChip(
                      Icons.monitor_weight,
                      '${control.peso} kg',
                      Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (control.presionArterial != null)
                    _buildInfoChip(
                      Icons.favorite,
                      control.presionArterial!,
                      Colors.red,
                    ),
                  const SizedBox(width: 8),
                  if (control.temperatura != null)
                    _buildInfoChip(
                      Icons.thermostat,
                      '${control.temperatura}°C',
                      Colors.orange,
                    ),
                  const SizedBox(width: 8),
                  if (control.frecuenciaCardiaca != null)
                    _buildInfoChip(
                      Icons.monitor_heart,
                      '${control.frecuenciaCardiaca} bpm',
                      Colors.purple,
                    ),
                ],
              ),
              if (control.fechaProximoControl != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Próximo control: ${DateFormat('dd/MM/yyyy').format(control.fechaProximoControl!)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
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

  void _showControlDetail(ControlPrenatalModel control) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ControlDetailSheet(control: control),
    );
  }

  void _showAddControlDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddControlDialog(),
    );
  }
}

class ControlDetailSheet extends StatelessWidget {
  final ControlPrenatalModel control;

  const ControlDetailSheet({super.key, required this.control});

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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Control Prenatal #${control.numeroControl}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(control.fechaControl)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                  _buildDetailSection('Información General', [
                    _buildDetailRow('Número de Control', control.numeroControl.toString()),
                    _buildDetailRow('Semanas de Gestación', '${control.semanasGestacion}'),
                    _buildDetailRow('Fecha de Control', 
                        DateFormat('dd/MM/yyyy').format(control.fechaControl)),
                    if (control.fechaProximoControl != null)
                      _buildDetailRow('Próximo Control', 
                          DateFormat('dd/MM/yyyy').format(control.fechaProximoControl!)),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Signos Vitales', [
                    _buildDetailRow('Peso', 
                        control.peso != null ? '${control.peso} kg' : 'No registrado'),
                    _buildDetailRow('Talla', 
                        control.talla != null ? '${control.talla} cm' : 'No registrada'),
                    _buildDetailRow('Presión Arterial', 
                        control.presionArterial ?? 'No registrada'),
                    _buildDetailRow('Temperatura', 
                        control.temperatura != null ? '${control.temperatura}°C' : 'No registrada'),
                    _buildDetailRow('Frecuencia Cardíaca', 
                        control.frecuenciaCardiaca != null ? '${control.frecuenciaCardiaca} bpm' : 'No registrada'),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Exámenes y Observaciones', [
                    _buildDetailRow('Exámenes Realizados', 
                        control.examenesRealizados?.join(', ') ?? 'Ninguno'),
                    _buildDetailRow('Observaciones', 
                        control.observaciones ?? 'Sin observaciones'),
                    _buildDetailRow('Recomendaciones', 
                        control.recomendaciones ?? 'Sin recomendaciones'),
                  ]),
                  const SizedBox(height: 20),
                  if (control.medicamentos != null && control.medicamentos!.isNotEmpty)
                    _buildDetailSection('Medicamentos', [
                      _buildDetailRow('Medicamentos Prescritos', 
                          control.medicamentos!.join(', ')),
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
                      // Edit control
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
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
                      // Generate report
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
            color: Colors.blue,
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

class AddControlDialog extends StatefulWidget {
  const AddControlDialog({super.key});

  @override
  State<AddControlDialog> createState() => _AddControlDialogState();
}

class _AddControlDialogState extends State<AddControlDialog> {
  final _formKey = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _presionController = TextEditingController();
  final _temperaturaController = TextEditingController();
  final _frecuenciaController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _recomendacionesController = TextEditingController();
  
  DateTime _fechaControl = DateTime.now();
  DateTime? _fechaProximoControl;
  int _semanasGestacion = 1;
  String? _gestanteSeleccionada;

  @override
  void dispose() {
    _pesoController.dispose();
    _tallaController.dispose();
    _presionController.dispose();
    _temperaturaController.dispose();
    _frecuenciaController.dispose();
    _observacionesController.dispose();
    _recomendacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Nuevo Control Prenatal',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _gestanteSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Gestante',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '1',
                            child: Text('María García - CC: 12345678'),
                          ),
                          DropdownMenuItem(
                            value: '2',
                            child: Text('Ana López - CC: 87654321'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _gestanteSeleccionada = value);
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Por favor seleccione una gestante';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _pesoController,
                              decoration: const InputDecoration(
                                labelText: 'Peso (kg)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _tallaController,
                              decoration: const InputDecoration(
                                labelText: 'Talla (cm)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _presionController,
                              decoration: const InputDecoration(
                                labelText: 'Presión Arterial',
                                hintText: '120/80',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _temperaturaController,
                              decoration: const InputDecoration(
                                labelText: 'Temperatura (°C)',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _frecuenciaController,
                              decoration: const InputDecoration(
                                labelText: 'Frecuencia Cardíaca',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _semanasGestacion,
                              decoration: const InputDecoration(
                                labelText: 'Semanas Gestación',
                                border: OutlineInputBorder(),
                              ),
                              items: List.generate(42, (index) => 
                                DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('${index + 1} semanas'),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() => _semanasGestacion = value!);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _observacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Observaciones',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _recomendacionesController,
                        decoration: const InputDecoration(
                          labelText: 'Recomendaciones',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
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
                    onPressed: _saveControl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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

  void _saveControl() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the control using the service
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Control prenatal guardado exitosamente')),
      );
    }
  }
}