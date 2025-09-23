import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/gestante_model.dart';
import '../services/alerta_service.dart';

class AlertasScreen extends ConsumerStatefulWidget {
  const AlertasScreen({super.key});

  @override
  ConsumerState<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends ConsumerState<AlertasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AlertaService _alertaService = AlertaService();
  
  List<AlertaModel> _alertas = [];
  List<AlertaModel> _alertasCriticas = [];
  List<AlertaModel> _alertasResueltas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAlertas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAlertas() async {
    setState(() => _isLoading = true);
    try {
      final alertas = await _alertaService.obtenerAlertas();
      final alertasCriticas = await _alertaService.obtenerAlertasCriticas();
      
      setState(() {
        _alertas = alertas;
        _alertasCriticas = alertasCriticas;
        _alertasResueltas = alertas.where((a) => a.fechaResolucion != null).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alertas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas Médicas'),
        backgroundColor: Colors.orange[100],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Activas',
              icon: Badge(
                label: Text('${_alertas.where((a) => a.fechaResolucion == null).length}'),
                child: const Icon(Icons.warning),
              ),
            ),
            Tab(
              text: 'Críticas',
              icon: Badge(
                label: Text('${_alertasCriticas.length}'),
                child: const Icon(Icons.priority_high),
              ),
            ),
            const Tab(text: 'Resueltas', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertasList(_alertas.where((a) => a.fechaResolucion == null).toList(), 'activas'),
          _buildAlertasList(_alertasCriticas, 'criticas'),
          _buildAlertasList(_alertasResueltas, 'resueltas'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlertaDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildAlertasList(List<AlertaModel> alertas, String tipo) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'criticas' ? Icons.priority_high_outlined : 
              tipo == 'resueltas' ? Icons.check_circle_outline : Icons.warning_outlined,
              size: 64, 
              color: Colors.grey[400]
            ),
            const SizedBox(height: 16),
            Text(
              tipo == 'criticas' ? 'No hay alertas críticas' :
              tipo == 'resueltas' ? 'No hay alertas resueltas' : 'No hay alertas activas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAlertas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alertas.length,
        itemBuilder: (context, index) {
          final alerta = alertas[index];
          return _buildAlertaCard(alerta, tipo);
        },
      ),
    );
  }

  Widget _buildAlertaCard(AlertaModel alerta, String tipo) {
    final isCritica = alerta.prioridad == NivelPrioridad.critica;
    final isResuelta = alerta.fechaResolucion != null;
    
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    
    if (isCritica && !isResuelta) {
      cardColor = Colors.red[50]!;
      borderColor = Colors.red[300]!;
    } else if (alerta.prioridad == NivelPrioridad.alta && !isResuelta) {
      cardColor = Colors.orange[50]!;
      borderColor = Colors.orange[300]!;
    } else if (isResuelta) {
      cardColor = Colors.green[50]!;
      borderColor = Colors.green[300]!;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAlertaDetail(alerta),
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
                      color: _getPriorityColor(alerta.prioridad).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAlertIcon(alerta.tipo),
                      color: _getPriorityColor(alerta.prioridad),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta.titulo,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Gestante ID: ${alerta.gestanteId}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(alerta.prioridad).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(alerta.prioridad),
                      style: TextStyle(
                        color: _getPriorityColor(alerta.prioridad),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alerta.descripcion,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.calendar_today,
                    DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaCreacion),
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.category,
                    _getTipoText(alerta.tipo),
                    Colors.purple,
                  ),
                  if (isResuelta) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.check_circle,
                      'Resuelta',
                      Colors.green,
                    ),
                  ],
                ],
              ),
              if (alerta.fechaResolucion != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Resuelta: ${DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaResolucion!)}',
                      style: TextStyle(
                        color: Colors.green[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Color _getPriorityColor(NivelPrioridad prioridad) {
    switch (prioridad) {
      case NivelPrioridad.critica:
        return Colors.red;
      case NivelPrioridad.alta:
        return Colors.orange;
      case NivelPrioridad.media:
        return Colors.yellow[700]!;
      case NivelPrioridad.baja:
        return Colors.blue;
    }
  }

  String _getPriorityText(NivelPrioridad prioridad) {
    switch (prioridad) {
      case NivelPrioridad.critica:
        return 'CRÍTICA';
      case NivelPrioridad.alta:
        return 'ALTA';
      case NivelPrioridad.media:
        return 'MEDIA';
      case NivelPrioridad.baja:
        return 'BAJA';
    }
  }

  IconData _getAlertIcon(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.presionAlta:
        return Icons.favorite;
      case TipoAlerta.presionBaja:
        return Icons.favorite_border;
      case TipoAlerta.fiebre:
        return Icons.thermostat;
      case TipoAlerta.pesoAnormal:
        return Icons.monitor_weight;
      case TipoAlerta.controlVencido:
        return Icons.schedule;
      case TipoAlerta.riesgoAlto:
        return Icons.warning;
      case TipoAlerta.medicacion:
        return Icons.medication;
      case TipoAlerta.laboratorio:
        return Icons.science;
      case TipoAlerta.otro:
        return Icons.info;
    }
  }

  String _getTipoText(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.presionAlta:
        return 'Presión Alta';
      case TipoAlerta.presionBaja:
        return 'Presión Baja';
      case TipoAlerta.fiebre:
        return 'Fiebre';
      case TipoAlerta.pesoAnormal:
        return 'Peso Anormal';
      case TipoAlerta.controlVencido:
        return 'Control Vencido';
      case TipoAlerta.riesgoAlto:
        return 'Riesgo Alto';
      case TipoAlerta.medicacion:
        return 'Medicación';
      case TipoAlerta.laboratorio:
        return 'Laboratorio';
      case TipoAlerta.otro:
        return 'Otro';
    }
  }

  void _showAlertaDetail(AlertaModel alerta) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AlertaDetailSheet(
        alerta: alerta,
        onResolve: () {
          _loadAlertas();
        },
      ),
    );
  }

  void _showAddAlertaDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddAlertaDialog(),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrar Alertas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Filtros disponibles:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.priority_high),
              title: const Text('Solo críticas'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Por fecha'),
              onTap: () {
                Navigator.pop(context);
                // Implement date filter
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Por tipo'),
              onTap: () {
                Navigator.pop(context);
                // Implement type filter
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}

class AlertaDetailSheet extends StatelessWidget {
  final AlertaModel alerta;
  final VoidCallback onResolve;

  const AlertaDetailSheet({
    super.key,
    required this.alerta,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final isResuelta = alerta.fechaResolucion != null;
    
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
                    color: _getPriorityColor(alerta.prioridad).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAlertIcon(alerta.tipo),
                    color: _getPriorityColor(alerta.prioridad),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alerta.titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gestante ID: ${alerta.gestanteId}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(alerta.prioridad).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getPriorityText(alerta.prioridad),
                    style: TextStyle(
                      color: _getPriorityColor(alerta.prioridad),
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
                  _buildDetailSection('Información de la Alerta', [
                    _buildDetailRow('Tipo', _getTipoText(alerta.tipo)),
                    _buildDetailRow('Prioridad', _getPriorityText(alerta.prioridad)),
                    _buildDetailRow('Fecha de Creación', 
                        DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaCreacion)),
                    if (alerta.fechaResolucion != null)
                      _buildDetailRow('Fecha de Resolución', 
                          DateFormat('dd/MM/yyyy HH:mm').format(alerta.fechaResolucion!)),
                  ]),
                  const SizedBox(height: 20),
                  _buildDetailSection('Descripción', [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        alerta.descripcion,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ]),
                  if (alerta.observaciones != null) ...[
                    const SizedBox(height: 20),
                    _buildDetailSection('Observaciones', [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          alerta.observaciones!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ]),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Actions
          if (!isResuelta)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _resolveAlert(context),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Resolver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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
                        // Edit alert
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
            color: Colors.orange,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
            width: 120,
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

  void _resolveAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Alerta'),
        content: const Text('¿Está seguro de que desea marcar esta alerta como resuelta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              onResolve();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alerta resuelta exitosamente')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(NivelPrioridad prioridad) {
    switch (prioridad) {
      case NivelPrioridad.critica:
        return Colors.red;
      case NivelPrioridad.alta:
        return Colors.orange;
      case NivelPrioridad.media:
        return Colors.yellow[700]!;
      case NivelPrioridad.baja:
        return Colors.blue;
    }
  }

  String _getPriorityText(NivelPrioridad prioridad) {
    switch (prioridad) {
      case NivelPrioridad.critica:
        return 'CRÍTICA';
      case NivelPrioridad.alta:
        return 'ALTA';
      case NivelPrioridad.media:
        return 'MEDIA';
      case NivelPrioridad.baja:
        return 'BAJA';
    }
  }

  IconData _getAlertIcon(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.presionAlta:
        return Icons.favorite;
      case TipoAlerta.presionBaja:
        return Icons.favorite_border;
      case TipoAlerta.fiebre:
        return Icons.thermostat;
      case TipoAlerta.pesoAnormal:
        return Icons.monitor_weight;
      case TipoAlerta.controlVencido:
        return Icons.schedule;
      case TipoAlerta.riesgoAlto:
        return Icons.warning;
      case TipoAlerta.medicacion:
        return Icons.medication;
      case TipoAlerta.laboratorio:
        return Icons.science;
      case TipoAlerta.otro:
        return Icons.info;
    }
  }

  String _getTipoText(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.presionAlta:
        return 'Presión Alta';
      case TipoAlerta.presionBaja:
        return 'Presión Baja';
      case TipoAlerta.fiebre:
        return 'Fiebre';
      case TipoAlerta.pesoAnormal:
        return 'Peso Anormal';
      case TipoAlerta.controlVencido:
        return 'Control Vencido';
      case TipoAlerta.riesgoAlto:
        return 'Riesgo Alto';
      case TipoAlerta.medicacion:
        return 'Medicación';
      case TipoAlerta.laboratorio:
        return 'Laboratorio';
      case TipoAlerta.otro:
        return 'Otro';
    }
  }
}

class AddAlertaDialog extends StatefulWidget {
  const AddAlertaDialog({super.key});

  @override
  State<AddAlertaDialog> createState() => _AddAlertaDialogState();
}

class _AddAlertaDialogState extends State<AddAlertaDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  TipoAlerta _tipoSeleccionado = TipoAlerta.otro;
  NivelPrioridad _prioridadSeleccionada = NivelPrioridad.media;
  String? _gestanteSeleccionada;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
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
              'Nueva Alerta Médica',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
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
                      TextFormField(
                        controller: _tituloController,
                        decoration: const InputDecoration(
                          labelText: 'Título de la Alerta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un título';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TipoAlerta>(
                        value: _tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Alerta',
                          border: OutlineInputBorder(),
                        ),
                        items: TipoAlerta.values.map((tipo) => 
                          DropdownMenuItem(
                            value: tipo,
                            child: Text(_getTipoText(tipo)),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          setState(() => _tipoSeleccionado = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<NivelPrioridad>(
                        value: _prioridadSeleccionada,
                        decoration: const InputDecoration(
                          labelText: 'Prioridad',
                          border: OutlineInputBorder(),
                        ),
                        items: NivelPrioridad.values.map((prioridad) => 
                          DropdownMenuItem(
                            value: prioridad,
                            child: Text(_getPriorityText(prioridad)),
                          ),
                        ).toList(),
                        onChanged: (value) {
                          setState(() => _prioridadSeleccionada = value!);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una descripción';
                          }
                          return null;
                        },
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
                    onPressed: _saveAlerta,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  String _getTipoText(TipoAlerta tipo) {
    switch (tipo) {
      case TipoAlerta.presionAlta:
        return 'Presión Alta';
      case TipoAlerta.presionBaja:
        return 'Presión Baja';
      case TipoAlerta.fiebre:
        return 'Fiebre';
      case TipoAlerta.pesoAnormal:
        return 'Peso Anormal';
      case TipoAlerta.controlVencido:
        return 'Control Vencido';
      case TipoAlerta.riesgoAlto:
        return 'Riesgo Alto';
      case TipoAlerta.medicacion:
        return 'Medicación';
      case TipoAlerta.laboratorio:
        return 'Laboratorio';
      case TipoAlerta.otro:
        return 'Otro';
    }
  }

  String _getPriorityText(NivelPrioridad prioridad) {
    switch (prioridad) {
      case NivelPrioridad.critica:
        return 'CRÍTICA';
      case NivelPrioridad.alta:
        return 'ALTA';
      case NivelPrioridad.media:
        return 'MEDIA';
      case NivelPrioridad.baja:
        return 'BAJA';
    }
  }

  void _saveAlerta() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the alert using the service
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerta creada exitosamente')),
      );
    }
  }
}