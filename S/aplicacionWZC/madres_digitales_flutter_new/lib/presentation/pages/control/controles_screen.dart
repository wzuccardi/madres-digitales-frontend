import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/entities/control.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/pages/control/control_prenatal_mejorado_screen.dart';
import 'package:madres_digitales_flutter_new/presentation/pages/home/sos_mejorado_screen.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/info_contextual_widget.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/app_bar_with_logo.dart';

class ControlesScreen extends ConsumerStatefulWidget {
  const ControlesScreen({super.key});

  @override
  ConsumerState<ControlesScreen> createState() => _ControlesScreenState();
}

class _ControlesScreenState extends ConsumerState<ControlesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Control> _controles = [];
  List<Control> _controlesVencidos = [];
  List<Control> _controlesPendientes = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
  bool _loadingInProgress = false;
  
  // Cache de alertas para evitar múltiples solicitudes
  final Map<String, List<Alerta>> _alertasCache = {};
  DateTime? _alertasCacheTimestamp;
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache expira después de 5 minutos

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _cargarControles();
      } else {
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    _tabController.dispose();
    
    super.dispose();
  }

  Future<void> _cargarControles() async {
    if (_isDisposed || !mounted || _loadingInProgress) return;
    _loadingInProgress = true;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      AppLogger.info('ControlesScreen: Cargando controles reales del backend...');
      
      // Limpiar caché de alertas al recargar controles
      _limpiarCacheAlertas();
      
      // Usar el servicio específico desde el provider
      final controlService = ref.read(controlServiceProvider);
      
      // Obtener controles reales
      final controles = await controlService.obtenerControles();
      
      // Filtrar controles por estado
      final controlesVencidos = await controlService.obtenerControlesVencidos();
      final controlesPendientes = await controlService.obtenerControlesPendientes();
      
      AppLogger.info('ControlesScreen: Controles obtenidos: ${controles.length}');
      
      // Prefetch de alertas recientes por lote y llenar caché
      try {
        final repo = ref.read(alertaRepositoryProvider);
        final result = await repo.fetchAlertas();
        if (result.isSuccess) {
          final allAlertas = result.dataOrThrow;
          final ahora = DateTime.now();
          final hace24Horas = ahora.subtract(const Duration(hours: 24));
          final ids = controles.map((c) => c.gestanteId).whereType<String>().toSet();
          _alertasCache.clear();
          for (final id in ids) {
            final list = allAlertas.where((a) =>
              a.gestanteId == id &&
              a.fechaCreacion.isAfter(hace24Horas) &&
              a.estado != AlertaEstado.resuelta
            ).toList();
            _alertasCache[id] = list;
          }
          _alertasCacheTimestamp = ahora;
        }
      } catch (_) {}

      if (mounted && !_isDisposed) {
        setState(() {
          _controles = controles;
          _controlesVencidos = controlesVencidos;
          _controlesPendientes = controlesPendientes;
          _isLoading = false;
        });
        AppLogger.info('ControlesScreen: Estado actualizado - Vencidos: ${controlesVencidos.length}, Pendientes: ${controlesPendientes.length}');
      }
    } catch (e) {
      AppLogger.error('ControlesScreen: Error cargando controles', error: e);
      
      if (mounted && !_isDisposed) {
        setState(() {
          _error = 'Error al cargar controles: $e';
          _isLoading = false;
        });
        AppLogger.info('ControlesScreen: Estado de error actualizado');
      }
    }
    _loadingInProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogo(
        title: 'Controles Prenatales',
        actions: [
          const ControlPrenatalInfoWidget(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarControles,
          ),
        ],
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
        heroTag: 'controles_fab',
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ControlPrenatalMejoradoScreen(),
            ),
          );
          if (result == true) {
            // Recargar controles si se creó uno nuevo
            _cargarControles();
          }
        },
        backgroundColor: Colors.teal[600],
        child: const Icon(Icons.add),
      ),

    );
  }

  Widget _buildControlesList(List<Control> controles, String tipo) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando controles...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarControles,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
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
      onRefresh: _cargarControles,
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

  Widget _buildControlCard(Control control, String tipo) {
    final isVencido = tipo == 'vencidos';
    final isPendiente = tipo == 'pendientes';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: isVencido ? Colors.red[100] : 
                              isPendiente ? Colors.orange[100] : Colors.blue[100],
              child: Icon(
                Icons.medical_services,
                color: isVencido ? Colors.red : 
                       isPendiente ? Colors.orange : Colors.blue,
              ),
            ),
            // Indicador de alertas - solo mostrar si hay alertas en caché
            if ((_alertasCache[control.gestanteId]?.isNotEmpty ?? false))
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => _mostrarAlertasRecientes(control),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.warning,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Control ${control.tipo ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (control.gestanteId != null &&
                _alertasCache[control.gestanteId]?.isNotEmpty == true)
              GestureDetector(
                onTap: () => _mostrarAlertasRecientes(control),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (_alertasCache[control.gestanteId]!
                            .any((a) => a.nivelPrioridad == AlertaNivel.critica))
                        ? Colors.red[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning,
                        size: 12,
                        color: (_alertasCache[control.gestanteId]!
                                .any((a) => a.nivelPrioridad == AlertaNivel.critica))
                            ? Colors.red[700]
                            : Colors.orange[700],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        (_alertasCache[control.gestanteId]!
                                .any((a) => a.nivelPrioridad == AlertaNivel.critica))
                            ? 'CRÍTICA'
                            : 'ALERTA',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: (_alertasCache[control.gestanteId]!
                                  .any((a) => a.nivelPrioridad == AlertaNivel.critica))
                              ? Colors.red[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${_formatDate(control.fecha ?? control.fechaProgramada)}'),
            Text(
              'Gestante: ${_getGestanteDisplayName(control)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (_getGestanteDetails(control).isNotEmpty)
              Text(
                _getGestanteDetails(control),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            Text('Estado: ${control.estado ?? '-'}'),
            if (control.semanasGestacion != null)
              Text(
                'Semana gestación: ${control.semanasGestacion}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
            if (control.peso != null)
              Text(
                'Peso: ${control.peso} kg',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            if (control.presionSistolica != null && control.presionDiastolica != null)
              Text(
                'Presión: ${control.presionSistolica}/${control.presionDiastolica} mmHg',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isVencido ? Icons.schedule : 
              isPendiente ? Icons.pending : Icons.check_circle,
              color: isVencido ? Colors.red : 
                     isPendiente ? Colors.orange : Colors.green,
              size: 20,
            ),
            Text(
              isVencido ? 'Vencido' : 
              isPendiente ? 'Pendiente' : 'Realizado',
              style: TextStyle(
                fontSize: 12,
                color: isVencido ? Colors.red : 
                       isPendiente ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            if (control.gestanteId != null)
              IconButton(
                tooltip: 'SOS',
                icon: const Icon(Icons.emergency, color: Colors.red, size: 20),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SOSMejoradoScreen(
                        gestanteId: control.gestanteId,
                        descripcion: 'SOS desde listado de controles',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        onTap: () {
          if (mounted) {
            _mostrarDetalleControl(control);
          }
        },
        onLongPress: () async {
          if (mounted) {
            // Preparar datos de la gestante para el formulario
            Map<String, dynamic>? gestanteData;
            if (control.gestante != null) {
              final obj = control.gestante;
              if (obj is Gestante) {
                gestanteData = {
                  'id': obj.id,
                  'nombre': obj.nombre,
                  'documento': obj.documento,
                  'telefono': obj.telefono,
                  'fecha_ultima_mestruacion': obj.fechaUltimaMenstruacion?.toIso8601String(),
                  'semanas_gestacion': obj.semanasGestacion,
                };
              } else if (obj is Map<String, dynamic>) {
                gestanteData = obj;
              }
            }
            
            // Preparar datos del control para edición
            final controlData = {
              'id': control.id,
              'gestante_id': control.gestanteId,
              'fecha_control': control.fecha?.toIso8601String(),
              'semanas_gestacion': control.semanasGestacion,
              'peso': control.peso,
              'presion_sistolica': control.presionSistolica,
              'presion_diastolica': control.presionDiastolica,
              'frecuencia_cardiaca': control.frecuenciaCardiaca,
              'temperatura': control.temperatura,
              'altura_uterina': control.alturaUterina,
              'observaciones': control.observaciones,
              'recomendaciones': control.recomendaciones,
            };
            
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ControlPrenatalMejoradoScreen(
                  gestante: gestanteData,
                  control: controlData,
                ),
              ),
            );
            if (result == true) {
              // Recargar controles si se editó
              _cargarControles();
            }
          }
        },
      ),
    );
  }

  void _mostrarDetalleControl(Control control) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Control ${control.tipo ?? '-'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Control: ${control.id}'),
              const SizedBox(height: 8),
              Text(
                'Gestante: ${_getGestanteDisplayName(control)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_getGestanteDetails(control).isNotEmpty) ...[
                Text(_getGestanteDetails(control)),
                const SizedBox(height: 8),
              ],
              Text('Fecha: ${_formatDate(control.fechaProgramada)}'),
              Text('Estado: ${control.estado ?? '-'}'),
              Text('Tipo: ${control.tipo ?? '-'}'),
              if (control.semanasGestacion != null)
                Text('Semana gestación: ${control.semanasGestacion}'),
              if (control.peso != null)
                Text('Peso: ${control.peso} kg'),
              if (control.alturaUterina != null)
                Text('Altura uterina: ${control.alturaUterina} cm'),
              if (control.presionSistolica != null && control.presionDiastolica != null)
                Text('Presión: ${control.presionSistolica}/${control.presionDiastolica} mmHg'),
              if (control.frecuenciaCardiaca != null)
                Text('Frecuencia cardíaca: ${control.frecuenciaCardiaca} lpm'),
              if (control.temperatura != null)
                Text('Temperatura: ${control.temperatura} °C'),
              if (control.observaciones != null && control.observaciones!.isNotEmpty)
                Text('Observaciones: ${control.observaciones}'),
              if (control.recomendaciones != null && control.recomendaciones!.isNotEmpty)
                Text('Recomendaciones: ${control.recomendaciones}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }


  // Método para obtener las alertas recientes de una gestante con caché
  Future<List<Alerta>> _obtenerAlertasRecientes(String gestanteId) async {
    try {
      // Verificar si tenemos datos en caché y si no han expirado
      final ahora = DateTime.now();
      if (_alertasCacheTimestamp != null &&
          ahora.difference(_alertasCacheTimestamp!) < _cacheExpiry &&
          _alertasCache.containsKey(gestanteId)) {
        return _alertasCache[gestanteId] ?? [];
      }
      
      // Si no hay datos en caché o han expirado, obtener del servidor
      final repo = ref.read(alertaRepositoryProvider);
      final result = await repo.fetchAlertas();
      if (result.isFailure) {
        throw result.errorOrThrow;
      }
      final allAlertas = result.dataOrThrow;
      final alertas = allAlertas.take(10).toList();
      
      // Filtrar alertas de las últimas 24 horas para esta gestante
      final hace24Horas = ahora.subtract(const Duration(hours: 24));
      final alertasFiltradas = alertas.where((alerta) =>
        alerta.gestanteId == gestanteId &&
        alerta.fechaCreacion.isAfter(hace24Horas) &&
        alerta.estado != AlertaEstado.resuelta
      ).toList();
      
      // Actualizar caché
      _alertasCache[gestanteId] = alertasFiltradas;
      _alertasCacheTimestamp = ahora;
      
      return alertasFiltradas;
    } catch (e) {
      AppLogger.error('Error obteniendo alertas recientes', error: e);
      return [];
    }
  }
  
  // Método para limpiar el caché de alertas
  void _limpiarCacheAlertas() {
    _alertasCache.clear();
    _alertasCacheTimestamp = null;
  }

  // Método para obtener los datos completos de la gestante
  String _getGestanteDisplayName(Control control) {
    if (control.gestante != null) {
      final obj = control.gestante;
      if (obj is Gestante) {
        if (obj.telefono.isNotEmpty) return '${obj.nombre} (${obj.telefono})';
        return obj.nombre;
      }
      if (obj is Map<String, dynamic>) {
        final nombre = (obj['nombre'] ?? '').toString();
        final telefono = (obj['telefono'] ?? '').toString();
        if (telefono.isNotEmpty) return '$nombre ($telefono)';
        if (nombre.isNotEmpty) return nombre;
      }
    }
    
    // Si solo tenemos el nombre, usarlo
    if (control.gestanteNombre != null && control.gestanteNombre!.isNotEmpty) {
      return control.gestanteNombre!;
    }
    
    // Si no tenemos nada, mostrar el ID
    return 'Gestante ID: ${control.gestanteId}';
  }

  String _getGestanteDetails(Control control) {
    final obj = control.gestante;
    final details = <String>[];
    if (obj is Gestante) {
      if (obj.documento.isNotEmpty) details.add('CC: ${obj.documento}');
      if (obj.telefono.isNotEmpty) details.add('Tel: ${obj.telefono}');
      if (obj.eps != null && obj.eps!.isNotEmpty) details.add('EPS: ${obj.eps}');
      if (obj.riesgoAlto) details.add('⚠️ Alto riesgo');
    } else if (obj is Map<String, dynamic>) {
      final doc = (obj['documento'] ?? '').toString();
      final tel = (obj['telefono'] ?? '').toString();
      final eps = (obj['eps'] ?? '').toString();
      if (doc.isNotEmpty) details.add('CC: $doc');
      if (tel.isNotEmpty) details.add('Tel: $tel');
      if (eps.isNotEmpty) details.add('EPS: $eps');
    }
    return details.isNotEmpty ? details.join(' • ') : '';
  }

  void _mostrarAlertasRecientes(Control control) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Alerta>>(
        future: control.gestanteId != null ? _obtenerAlertasRecientes(control.gestanteId!) : Future.value([]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }
          
          if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('No se pudieron cargar las alertas: ${snapshot.error}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          
          final alertas = snapshot.data ?? [];
          
          return AlertDialog(
            title: Text('Alertas de ${_getGestanteDisplayName(control)}'),
            content: SizedBox(
              width: double.maxFinite,
              child: alertas.isEmpty
                  ? const Text('No hay alertas recientes')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: alertas.length,
                      itemBuilder: (context, index) {
                        final alerta = alertas[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning,
                              color: alerta.nivelPrioridad == AlertaNivel.critica ? Colors.red : Colors.orange,
                            ),
                            title: Text(alerta.tipoAlerta.name.toUpperCase()),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alerta.descripcion),
                                const SizedBox(height: 4),
                                Text(
                                  'Prioridad: ${alerta.nivelPrioridad.name.toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: alerta.nivelPrioridad == AlertaNivel.critica ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Fecha: ${_formatDate(alerta.fechaCreacion)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                // Mostrar los valores del control que activaron la alarma
                                ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Valores que activaron la alarma:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (alerta.datosAdicionales['presion_sistolica'] != null &&
                                          alerta.datosAdicionales['presion_diastolica'] != null)
                                        Text(
                                          'Presión: ${alerta.datosAdicionales['presion_sistolica']}/${alerta.datosAdicionales['presion_diastolica']} mmHg',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (alerta.datosAdicionales['frecuencia_cardiaca'] != null)
                                        Text(
                                          'Frecuencia cardíaca: ${alerta.datosAdicionales['frecuencia_cardiaca']} lpm',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (alerta.datosAdicionales['temperatura'] != null)
                                        Text(
                                          'Temperatura: ${alerta.datosAdicionales['temperatura']} °C',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (alerta.datosAdicionales['semanas_gestacion'] != null)
                                        Text(
                                          'Semana gestación: ${alerta.datosAdicionales['semanas_gestacion']}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (alerta.etiquetas.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Etiquetas: ${alerta.etiquetas.join(', ')}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              ],
                            ),
                            trailing: alerta.nivelPrioridad == AlertaNivel.critica
                                ? const Icon(Icons.priority_high, color: Colors.red)
                                : const Icon(Icons.info, color: Colors.orange),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
  }
}
