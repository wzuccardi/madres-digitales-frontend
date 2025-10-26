import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/control_service.dart';
import '../services/gestante_service.dart';
import '../services/alerta_service.dart';
import '../providers/service_providers.dart';
import '../screens/control_form_screen.dart';
import '../utils/logger.dart';
import '../shared/widgets/info_contextual_widget.dart';
import '../shared/widgets/app_bar_with_logo.dart';

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
  
  // Cache de alertas para evitar múltiples solicitudes
  final Map<String, List<Alerta>> _alertasCache = {};
  DateTime? _alertasCacheTimestamp;
  static const Duration _cacheExpiry = Duration(minutes: 5); // Cache expira después de 5 minutos

  @override
  void initState() {
    super.initState();
    print('🩺 ControlesScreen: ========== INICIALIZANDO PANTALLA ==========');
    _tabController = TabController(length: 3, vsync: this);
    print('🩺 ControlesScreen: TabController creado con 3 tabs');
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🩺 ControlesScreen: PostFrameCallback ejecutado');
      if (mounted && !_isDisposed) {
        print('🩺 ControlesScreen: Widget montado, iniciando carga de controles...');
        _cargarControles();
      } else {
        print('❌ ControlesScreen: Widget no montado o disposed');
      }
    });
  }

  @override
  void dispose() {
    print('🩺 ControlesScreen: ========== DISPOSING PANTALLA ==========');
    _isDisposed = true;
    print('🩺 ControlesScreen: Flag _isDisposed establecido a true');
    
    _tabController.dispose();
    print('🩺 ControlesScreen: ✅ TabController disposed');
    
    print('🩺 ControlesScreen: ✅ Pantalla disposed exitosamente');
    super.dispose();
  }

  Future<void> _cargarControles() async {
    if (_isDisposed || !mounted) return;
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
        appLogger.info('ControlesScreen: Estado de carga actualizado a true');
      }
    });

    try {
      appLogger.info('ControlesScreen: Cargando controles reales del backend...');
      
      // Limpiar caché de alertas al recargar controles
      _limpiarCacheAlertas();
      
      // Usar el servicio específico desde el provider
      final apiService = ref.read(apiServiceProvider);
      final gestanteService = GestanteService(apiService);
      final controlService = ControlService(apiService, gestanteService);
      
      // Obtener controles reales
      final controles = await controlService.obtenerControles();
      
      // Filtrar controles por estado
      final controlesVencidos = await controlService.obtenerControlesVencidos();
      final controlesPendientes = await controlService.obtenerControlesPendientes();
      
      appLogger.info('ControlesScreen: Controles obtenidos: ${controles.length}');
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _controles = controles;
            _controlesVencidos = controlesVencidos;
            _controlesPendientes = controlesPendientes;
            _isLoading = false;
          });
          appLogger.info('ControlesScreen: Estado actualizado - Vencidos: ${controlesVencidos.length}, Pendientes: ${controlesPendientes.length}');
        }
      });
    } catch (e) {
      appLogger.error('ControlesScreen: Error cargando controles', error: e);
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _error = 'Error al cargar controles: $e';
            _isLoading = false;
          });
          appLogger.info('ControlesScreen: Estado de error actualizado');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
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
        heroTag: "controles_fab",
        onPressed: () async {
          print('🔶 CONTROLES_SCREEN: Botón de agregar control presionado - ARCHIVO: controles_screen.dart');
          print('🔶 CONTROLES_SCREEN: Navegando a ControlFormScreen');
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ControlFormScreen(),
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
            if (_alertasCache.containsKey(control.gestanteId) &&
                _alertasCache[control.gestanteId]!.isNotEmpty)
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
                'Control ${control.tipo}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            // Indicador de alertas en el título
            FutureBuilder<bool>(
              future: _tieneAlertasRecientes(control.gestanteId),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return GestureDetector(
                    onTap: () => _mostrarAlertasRecientes(control),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, size: 12, color: Colors.red[700]),
                          const SizedBox(width: 2),
                          Text(
                            'ALERTA',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${_formatDate(control.fechaProgramada)}'),
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
            Text('Estado: ${control.estado}'),
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
          ],
        ),
        onTap: () {
          if (mounted) {
            _mostrarDetalleControl(control);
          }
        },
        onLongPress: () async {
          if (mounted) {
            print('🔶 CONTROLES_SCREEN: Mantener presionado control para editar - ARCHIVO: controles_screen.dart');
            print('🔶 CONTROLES_SCREEN: controlId = ${control.id}, gestanteId = ${control.gestanteId}');
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ControlFormScreen(
                  controlId: control.id,
                  gestantePreseleccionada: control.gestanteId,
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
        title: Text('Control ${control.tipo}'),
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
              Text('Estado: ${control.estado}'),
              Text('Tipo: ${control.tipo}'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<bool> _tieneAlertasRecientes(String gestanteId) async {
    try {
      final alertas = await _obtenerAlertasRecientes(gestanteId);
      return alertas.isNotEmpty;
    } catch (e) {
      appLogger.error('Error verificando alertas recientes', error: e);
      return false;
    }
  }

  // Método para obtener las alertas recientes de una gestante con caché
  Future<List<Alerta>> _obtenerAlertasRecientes(String gestanteId) async {
    try {
      // Verificar si tenemos datos en caché y si no han expirado
      final ahora = DateTime.now();
      if (_alertasCacheTimestamp != null &&
          ahora.difference(_alertasCacheTimestamp!) < _cacheExpiry &&
          _alertasCache.containsKey(gestanteId)) {
        return _alertasCache[gestanteId]!;
      }
      
      // Si no hay datos en caché o han expirado, obtener del servidor
      final apiService = ref.read(apiServiceProvider);
      final gestanteService = GestanteService(apiService);
      final alertaService = AlertaService(apiService, gestanteService);
      final alertas = await alertaService.obtenerAlertas(limit: 10);
      
      // Filtrar alertas de las últimas 24 horas para esta gestante
      final hace24Horas = ahora.subtract(const Duration(hours: 24));
      final alertasFiltradas = alertas.where((alerta) =>
        alerta.gestanteId == gestanteId &&
        alerta.fechaCreacion.isAfter(hace24Horas) &&
        !alerta.resuelta
      ).toList();
      
      // Actualizar caché
      _alertasCache[gestanteId] = alertasFiltradas;
      _alertasCacheTimestamp = ahora;
      
      return alertasFiltradas;
    } catch (e) {
      appLogger.error('Error obteniendo alertas recientes', error: e);
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
    // Si tenemos los datos completos de la gestante, mostrar nombre y teléfono
    if (control.gestante != null) {
      final gestante = control.gestante!;
      if (gestante.telefono != null && gestante.telefono!.isNotEmpty) {
        return '${gestante.nombre} (${gestante.telefono})';
      }
      return gestante.nombre;
    }
    
    // Si solo tenemos el nombre, usarlo
    if (control.gestanteNombre != null && control.gestanteNombre!.isNotEmpty) {
      return control.gestanteNombre!;
    }
    
    // Si no tenemos nada, mostrar el ID
    return 'Gestante ID: ${control.gestanteId}';
  }

  String _getGestanteDetails(Control control) {
    if (control.gestante == null) {
      return '';
    }
    
    final gestante = control.gestante!;
    final details = <String>[];
    
    if (gestante.documento.isNotEmpty) {
      details.add('CC: ${gestante.documento}');
    }
    
    if (gestante.telefono != null && gestante.telefono!.isNotEmpty) {
      details.add('Tel: ${gestante.telefono}');
    }
    
    if (gestante.eps != null && gestante.eps!.isNotEmpty) {
      details.add('EPS: ${gestante.eps}');
    }
    
    if (gestante.riesgo_alto) {
      details.add('⚠️ Alto riesgo');
    }
    
    return details.isNotEmpty ? details.join(' • ') : '';
  }

  void _mostrarAlertasRecientes(Control control) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<Alerta>>(
        future: _obtenerAlertasRecientes(control.gestanteId),
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
                              color: alerta.esCritica ? Colors.red : Colors.orange,
                            ),
                            title: Text(alerta.tipoTexto),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alerta.mensaje),
                                const SizedBox(height: 4),
                                Text(
                                  'Prioridad: ${alerta.prioridadTexto}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: alerta.esCritica ? Colors.red : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Fecha: ${_formatDate(alerta.fechaCreacion)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                // Mostrar los valores del control que activaron la alarma
                                if (alerta.signosVitales != null) ...[
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
                                        if (alerta.signosVitales!['presion_sistolica'] != null &&
                                            alerta.signosVitales!['presion_diastolica'] != null)
                                          Text(
                                            'Presión: ${alerta.signosVitales!['presion_sistolica']}/${alerta.signosVitales!['presion_diastolica']} mmHg',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (alerta.signosVitales!['frecuencia_cardiaca'] != null)
                                          Text(
                                            'Frecuencia cardíaca: ${alerta.signosVitales!['frecuencia_cardiaca']} lpm',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (alerta.signosVitales!['temperatura'] != null)
                                          Text(
                                            'Temperatura: ${alerta.signosVitales!['temperatura']} °C',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (alerta.signosVitales!['semanas_gestacion'] != null)
                                          Text(
                                            'Semana gestación: ${alerta.signosVitales!['semanas_gestacion']}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        if (alerta.sintomas.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Síntomas: ${alerta.sintomas.join(', ')}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: alerta.esCritica
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