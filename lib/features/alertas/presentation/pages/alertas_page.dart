import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_page_scaffold.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_filter_bar.dart';

class AlertasPage extends ConsumerStatefulWidget {
  const AlertasPage({super.key});
  @override
  ConsumerState<AlertasPage> createState() => _AlertasPageState();
}

class _AlertasPageState extends ConsumerState<AlertasPage> {
  List<Alerta> alertas = const [];
  bool isLoading = true;
  String? errorMessage;
  AlertaEstado? filtroEstado;
  int page = 1;
  final int limit = 20;
  List<Alerta> visibles = const [];
  StreamSubscription? _alertaCreatedSub;
  StreamSubscription? _controlCreatedSub;

  @override
  void initState() {
    super.initState();
    _fetchAlertas();
    _subscribeRealtime();
  }

  Future<void> _fetchAlertas() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final apiService = ref.read(apiServiceProvider);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await apiService.get('/api/alertas?_t=$timestamp');
      
      if (!mounted) return;
      
      List<dynamic> alertasData = [];
      
      // Procesar la respuesta
      if (response.data is List) {
        alertasData = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('alertas') && dataMap['alertas'] is List) {
          alertasData = dataMap['alertas'] as List<dynamic>;
        }
      }
      
      // Convertir a objetos Alerta
      final alertasList = alertasData.map((data) {
        // Extraer información de gestante y madrina
        final gestante = data['gestante'] as Map<String, dynamic>?;
        final madrina = data['madrina'] as Map<String, dynamic>?;
        
        final gestanteNombre = gestante?['nombre'] ?? 'Sin asignar';
        final gestanteDoc = gestante?['documento'] ?? '';
        final madrinaNombre = madrina?['nombre'] ?? 'Sin asignar';
        final madrinaTel = madrina?['telefono'] ?? '';
        
        // Construir descripción enriquecida
        final descripcionBase = data['tipo_alerta'] ?? data['tipo'] ?? 'Sin tipo';
        final descripcionEnriquecida = '$descripcionBase\n'
            '👤 Gestante: $gestanteNombre${gestanteDoc.isNotEmpty ? ' ($gestanteDoc)' : ''}\n'
            '🤝 Madrina: $madrinaNombre${madrinaTel.isNotEmpty ? ' - $madrinaTel' : ''}';
        
        return Alerta(
          id: data['id'] ?? '',
          titulo: data['mensaje'] ?? 'Sin mensaje',
          descripcion: descripcionEnriquecida,
          tipoAlerta: _parseTipo(data['tipo_alerta'] ?? data['tipo']),
          nivelPrioridad: _parseNivel(data['nivel_prioridad'] ?? data['prioridad']),
          estado: _parseEstado(data['resuelta']),
          gestanteId: data['gestante_id'],
          madrinaId: data['madrina_id'],
          fechaCreacion: DateTime.tryParse(data['fecha_creacion'] ?? data['fechaCreacion'] ?? '') ?? DateTime.now(),
        );
      }).toList();
      
      if (!mounted) return;
      
      setState(() {
        alertas = alertasList;
        page = 1;
        _aplicarFiltros();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }
  
  AlertaEstado _parseEstado(dynamic resuelta) {
    if (resuelta == true) return AlertaEstado.resuelta;
    return AlertaEstado.pendiente;
  }
  
  AlertaNivel _parseNivel(dynamic prioridad) {
    final prioridadStr = prioridad?.toString().toLowerCase() ?? '';
    if (prioridadStr.contains('critica')) return AlertaNivel.critica;
    if (prioridadStr.contains('alta')) return AlertaNivel.alta;
    if (prioridadStr.contains('media')) return AlertaNivel.media;
    return AlertaNivel.baja;
  }
  
  AlertaTipo _parseTipo(dynamic tipo) {
    final tipoStr = tipo?.toString().toLowerCase() ?? '';
    if (tipoStr.contains('sos')) return AlertaTipo.sos;
    if (tipoStr.contains('medica')) return AlertaTipo.medica;
    if (tipoStr.contains('control')) return AlertaTipo.control;
    if (tipoStr.contains('recordatorio')) return AlertaTipo.recordatorio;
    if (tipoStr.contains('sistema')) return AlertaTipo.sistema;
    return AlertaTipo.informacion;
  }
  
  String _formatFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);
    
    if (diferencia.inMinutes < 1) {
      return 'Hace un momento';
    } else if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours} h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  Future<void> _subscribeRealtime() async {
    final ws = ref.read(webSocketServiceProvider);
    await ws.connect();
    _alertaCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((data) async {
      if (!mounted) return;
      await _fetchAlertas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nueva alerta creada')));
    });
    _controlCreatedSub = ws.stream<Map<String, dynamic>>('control:created').listen((data) async {
      if (!mounted) return;
      await _fetchAlertas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nuevo control creado')));
    });
  }

  void _aplicarFiltros() {
    final filtered = filtroEstado == null
        ? alertas
        : alertas.where((a) => a.estado == filtroEstado).toList();
    visibles = filtered.take(page * limit).toList();
  }

  Future<void> _cargarMas() async {
    setState(() {
      page += 1;
      _aplicarFiltros();
    });
  }

  @override
  Widget build(BuildContext context) {
    return V2PageScaffold(
      title: 'Alertas',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchAlertas,
                  child: ListView(
                    children: [
                      V2FilterBar(
                        label: 'Estado',
                        child: DropdownButton<AlertaEstado?>(
                          value: filtroEstado,
                          items: const <DropdownMenuItem<AlertaEstado?>>[
                            DropdownMenuItem<AlertaEstado?>(value: null, child: Text('Todas')),
                            DropdownMenuItem<AlertaEstado?>(value: AlertaEstado.pendiente, child: Text('Pendiente')),
                            DropdownMenuItem<AlertaEstado?>(value: AlertaEstado.enProgreso, child: Text('En Progreso')),
                            DropdownMenuItem<AlertaEstado?>(value: AlertaEstado.resuelta, child: Text('Resuelta')),
                            DropdownMenuItem<AlertaEstado?>(value: AlertaEstado.cancelada, child: Text('Cancelada')),
                          ],
                          onChanged: (val) {
                            setState(() {
                              filtroEstado = val;
                              page = 1;
                              _aplicarFiltros();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...visibles.map((a) => Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            elevation: 2,
                            child: ListTile(
                              leading: Icon(
                                a.esResuelta ? Icons.check_circle : Icons.warning,
                                color: a.esCritica ? Colors.red : 
                                       a.esAlta ? Colors.orange : 
                                       a.esMedia ? Colors.yellow.shade700 : Colors.grey,
                                size: 32,
                              ),
                              title: Text(
                                a.titulo,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: a.esResuelta ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  // Tipo de alerta
                                  Row(
                                    children: [
                                      const Icon(Icons.label, size: 14, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        a.tipoAlerta.toString().split('.').last.toUpperCase(),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Información de gestante y madrina (del campo descripcion)
                                  Text(
                                    a.descripcion,
                                    style: const TextStyle(fontSize: 12, height: 1.3),
                                  ),
                                  const SizedBox(height: 6),
                                  // Prioridad y fecha
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.priority_high,
                                        size: 14,
                                        color: a.esCritica ? Colors.red : 
                                               a.esAlta ? Colors.orange : 
                                               a.esMedia ? Colors.yellow.shade700 : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        a.nivelPrioridad.toString().split('.').last.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: a.esCritica ? Colors.red : 
                                                 a.esAlta ? Colors.orange : 
                                                 a.esMedia ? Colors.yellow.shade700 : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatFecha(a.fechaCreacion),
                                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                              trailing: !a.esResuelta ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Resolver',
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () async {
                                      try {
                                        final apiService = ref.read(apiServiceProvider);
                                        await apiService.put('/api/alertas/${a.id}', data: {'resuelta': true});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Alerta resuelta')),
                                        );
                                        await _fetchAlertas();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('❌ Error: $e')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ) : null,
                            ),
                          )),
                      if (visibles.length < (filtroEstado == null
                          ? alertas.length
                          : alertas.where((a) => a.estado == filtroEstado).length))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: ElevatedButton(onPressed: _cargarMas, child: const Text('Cargar más')),
                        ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _alertaCreatedSub?.cancel();
    _controlCreatedSub?.cancel();
    super.dispose();
  }
}
