import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import '../../controles_v2/data/control_api_v2.dart';
import '../../controles_v2/domain/control_dto.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:intl/intl.dart';
import 'package:madres_digitales_flutter_new/presentation/pages/control/control_prenatal_mejorado_screen.dart';

/// Lista de controles optimizada con información completa
/// Muestra: nombre, municipio, edad, semanas, número de control, alertas con semaforización
class ControlesListOptimizedPage extends ConsumerStatefulWidget {
  const ControlesListOptimizedPage({super.key, this.gestanteId});
  final String? gestanteId;
  
  @override
  ConsumerState<ControlesListOptimizedPage> createState() => _ControlesListOptimizedPageState();
}

class _ControlesListOptimizedPageState extends ConsumerState<ControlesListOptimizedPage> {
  bool _loading = true;
  String? _error;
  List<ControlEnriquecido> _items = [];
  String? _filterGestanteId;

  @override
  void initState() {
    super.initState();
    _filterGestanteId = widget.gestanteId;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // Cargar controles
      final api = ControlApiV2(api: ref.read(apiServiceProvider));
      final controles = await api.fetchControles();
      
      // Filtrar por gestante si es necesario
      final controlesFiltrados = (_filterGestanteId == null || _filterGestanteId!.isEmpty)
          ? controles
          : controles.where((c) => c.gestanteId == _filterGestanteId).toList();
      
      // Enriquecer cada control con información adicional
      final controlesEnriquecidos = <ControlEnriquecido>[];
      
      for (final control in controlesFiltrados) {
        try {
          // Obtener información de la gestante
          Gestante? gestante;
          if (control.gestanteId != null) {
            final gestanteService = ref.read(gestanteServiceProvider);
            gestante = await gestanteService.obtenerGestantePorId(control.gestanteId!);
          }
          
          // Obtener alertas activas de la gestante
          List<Map<String, dynamic>> alertas = [];
          if (control.gestanteId != null) {
            try {
              final alertaService = ref.read(alertaServiceProvider);
              final todasAlertas = await alertaService.getAlertasByGestante(control.gestanteId!);
              alertas = todasAlertas
                  .where((a) => a.estado != AlertaEstado.resuelta)
                  .map((a) => a.toJson())
                  .toList();
            } catch (e) {
              // Si falla, continuar sin alertas
            }
          }
          
          // Calcular número de control (contar controles anteriores de la misma gestante)
          final numeroControl = controlesFiltrados
              .where((c) => 
                  c.gestanteId == control.gestanteId && 
                  c.fechaControl != null && 
                  control.fechaControl != null &&
                  c.fechaControl!.isBefore(control.fechaControl!) || 
                  c.fechaControl == control.fechaControl)
              .length;
          
          controlesEnriquecidos.add(ControlEnriquecido(
            control: control,
            gestante: gestante,
            alertasActivas: alertas,
            numeroControl: numeroControl,
          ));
        } catch (e) {
          // Si falla enriquecer un control, agregarlo sin información adicional
          controlesEnriquecidos.add(ControlEnriquecido(
            control: control,
            gestante: null,
            alertasActivas: [],
            numeroControl: 0,
          ));
        }
      }
      
      // Ordenar por fecha descendente (más recientes primero)
      controlesEnriquecidos.sort((a, b) {
        if (a.control.fechaControl == null) return 1;
        if (b.control.fechaControl == null) return -1;
        return b.control.fechaControl!.compareTo(a.control.fechaControl!);
      });
      
      if (mounted) {
        setState(() {
          _items = controlesEnriquecidos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_filterGestanteId == null ? 'Controles Prenatales' : 'Controles'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ControlPrenatalMejoradoScreen(),
            ),
          ).then((_) => _load());
        },
        backgroundColor: Colors.blue,
        tooltip: 'Crear nuevo control prenatal',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _items.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay controles registrados'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return _buildControlCard(item);
                        },
                      ),
                    ),
    );
  }

  Widget _buildControlCard(ControlEnriquecido item) {
    final control = item.control;
    final gestante = item.gestante;
    final alertas = item.alertasActivas;
    
    // Determinar color de alerta (semaforización)
    Color alertColor = Colors.green;
    IconData alertIcon = Icons.check_circle;
    String alertText = 'Sin alertas';
    
    if (alertas.isNotEmpty) {
      // Buscar la alerta de mayor prioridad
      final prioridades = alertas.map((a) => a['nivel_prioridad']?.toString().toUpperCase() ?? '').toList();
      
      if (prioridades.contains('CRITICA')) {
        alertColor = Colors.red;
        alertIcon = Icons.warning;
        alertText = 'Alerta crítica';
      } else if (prioridades.contains('ALTA')) {
        alertColor = Colors.orange;
        alertIcon = Icons.warning_amber;
        alertText = 'Alerta alta';
      } else if (prioridades.contains('MEDIA')) {
        alertColor = Colors.yellow[700]!;
        alertIcon = Icons.info;
        alertText = 'Alerta media';
      } else {
        alertColor = Colors.blue;
        alertIcon = Icons.info_outline;
        alertText = 'Alerta baja';
      }
    }
    
    // Calcular edad de la gestante
    int? edad;
    if (gestante?.fechaNacimiento != null) {
      final hoy = DateTime.now();
      edad = hoy.year - gestante!.fechaNacimiento!.year;
      if (hoy.month < gestante.fechaNacimiento!.month ||
          (hoy.month == gestante.fechaNacimiento!.month && hoy.day < gestante.fechaNacimiento!.day)) {
        edad--;
      }
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado: Nombre y número de control
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gestante?.nombre ?? 'Gestante desconocida',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Control #${item.numeroControl}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Indicador de alerta
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alertColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(alertIcon, color: alertColor, size: 28),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Información principal
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      'Fecha',
                      control.fechaControl != null
                          ? DateFormat('dd/MM/yyyy').format(control.fechaControl!)
                          : '-',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.cake,
                      'Edad',
                      edad != null ? '$edad años' : '-',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.pregnant_woman,
                      'Semanas',
                      control.semanasGestacion != null
                          ? '${control.semanasGestacion} sem'
                          : '-',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.location_city,
                      'Municipio',
                      gestante?.municipioId ?? '-',
                    ),
                  ),
                ],
              ),
              
              // Información de alerta
              if (alertas.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: alertColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(alertIcon, color: alertColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$alertText (${alertas.length})',
                          style: TextStyle(
                            color: alertColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Observaciones (si existen)
              if (control.observaciones != null && control.observaciones!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  control.observaciones!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openDetail(ControlEnriquecido item) {
    // Navegar a la página de detalle
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ControlDetailOptimizedPage(item: item),
      ),
    );
  }
}

/// Clase para almacenar un control con información enriquecida
class ControlEnriquecido {

  ControlEnriquecido({
    required this.control,
    required this.gestante,
    required this.alertasActivas,
    required this.numeroControl,
  });
  final ControlDto control;
  final Gestante? gestante;
  final List<Map<String, dynamic>> alertasActivas;
  final int numeroControl;
}

/// Página de detalle del control optimizada
class ControlDetailOptimizedPage extends StatelessWidget {
  const ControlDetailOptimizedPage({super.key, required this.item});
  final ControlEnriquecido item;

  @override
  Widget build(BuildContext context) {
    final control = item.control;
    final gestante = item.gestante;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalle del Control'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información de la gestante
            _buildSection(
              'Información de la Gestante',
              Icons.person,
              [
                _buildDetailRow('Nombre', gestante?.nombre ?? '-'),
                _buildDetailRow('Documento', gestante?.documento ?? '-'),
                _buildDetailRow('Teléfono', gestante?.telefono ?? '-'),
                _buildDetailRow('Municipio', gestante?.municipioId ?? '-'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Información del control
            _buildSection(
              'Datos del Control',
              Icons.assignment,
              [
                _buildDetailRow('Número de control', '#${item.numeroControl}'),
                _buildDetailRow('Fecha', control.fechaControl != null
                    ? DateFormat('dd/MM/yyyy').format(control.fechaControl!)
                    : '-'),
                _buildDetailRow('Semanas de gestación', control.semanasGestacion?.toString() ?? '-'),
                _buildDetailRow('Peso', control.peso != null ? '${control.peso} kg' : '-'),
                _buildDetailRow('Presión arterial', 
                    control.presionSistolica != null && control.presionDiastolica != null
                        ? '${control.presionSistolica}/${control.presionDiastolica} mmHg'
                        : '-'),
                _buildDetailRow('Frecuencia cardíaca', 
                    control.frecuenciaCardiaca != null ? '${control.frecuenciaCardiaca} lpm' : '-'),
                _buildDetailRow('Temperatura', 
                    control.temperatura != null ? '${control.temperatura} °C' : '-'),
                _buildDetailRow('Altura uterina', 
                    control.alturaUterina != null ? '${control.alturaUterina} cm' : '-'),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Observaciones y recomendaciones
            if (control.observaciones != null && control.observaciones!.isNotEmpty)
              _buildSection(
                'Observaciones',
                Icons.notes,
                [
                  Text(
                    control.observaciones!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            
            if (control.recomendaciones != null && control.recomendaciones!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                'Recomendaciones',
                Icons.lightbulb,
                [
                  Text(
                    control.recomendaciones!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            
            // Alertas activas
            if (item.alertasActivas.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                'Alertas Activas (${item.alertasActivas.length})',
                Icons.warning,
                item.alertasActivas.map((alerta) {
                  return Card(
                    color: _getAlertColor(alerta['nivel_prioridad']?.toString() ?? '').withOpacity(0.1),
                    child: ListTile(
                      leading: Icon(
                        Icons.warning,
                        color: _getAlertColor(alerta['nivel_prioridad']?.toString() ?? ''),
                      ),
                      title: Text(alerta['mensaje']?.toString() ?? 'Sin mensaje'),
                      subtitle: Text(alerta['tipo_alerta']?.toString() ?? ''),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAlertColor(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'CRITICA':
        return Colors.red;
      case 'ALTA':
        return Colors.orange;
      case 'MEDIA':
        return Colors.yellow[700]!;
      case 'BAJA':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
