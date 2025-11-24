// Limpieza de imports duplicados y rutas incorrectas
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';

class AlertasScreen extends ConsumerStatefulWidget {
  const AlertasScreen({super.key});

  @override
  ConsumerState<AlertasScreen> createState() => _AlertasScreenState();
}

class _AlertasScreenState extends ConsumerState<AlertasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Alerta> _todasAlertas = [];
  List<Alerta> _alertasCriticas = [];
  List<Alerta> _alertasPendientes = [];
  List<Alerta> _alertasAutomaticas = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
  
  // Filtros
  String? _filtroTipo;
  String? _filtroPrioridad;
  String? _filtroEstado;
  bool? _filtroAutomatica;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarAlertas();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarAlertas() async {
    if (_isDisposed || !mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      AppLogger.info('AlertasScreen: Cargando alertas del backend usando AlertaServiceSimple...');
      final service = ref.read(alertaServiceSimpleProvider);
      var alertas = await service.getAlertas();
      AppLogger.info('AlertasScreen: Se obtuvieron ${alertas.length} alertas del servicio simple');
      
      // Log detallado de las alertas recibidas
      for (int i = 0; i < (alertas.length > 3 ? 3 : alertas.length); i++) {
        AppLogger.info('AlertasScreen: Alerta $i - ID: ${alertas[i].id}, Tipo: ${alertas[i].tipoAlerta}, Estado: ${alertas[i].estado}, Gestante: ${alertas[i].gestanteId}');
      }

      // Aplicar filtros en cliente
      if (_filtroPrioridad != null) {
        alertas = alertas.where((a) => a.nivelPrioridad.name == _filtroPrioridad).toList();
      }
      if (_filtroTipo != null) {
        alertas = alertas.where((a) => a.tipoAlerta.name == _filtroTipo).toList();
      }
      if (_filtroEstado != null) {
        alertas = alertas.where((a) {
          switch (_filtroEstado) {
            case 'pendiente':
              return a.estado == AlertaEstado.pendiente;
            case 'en_progreso':
              return a.estado == AlertaEstado.enProgreso;
            case 'resuelta':
              return a.estado == AlertaEstado.resuelta;
            default:
              return true;
          }
        }).toList();
      }
      if (_filtroAutomatica == true) {
        alertas = alertas.where((a) => a.esAutomatica).toList();
      }

      if (!mounted || _isDisposed) return;

      setState(() {
        _todasAlertas = alertas;
        _alertasCriticas = alertas.where((a) => a.esCritica).toList();
        _alertasPendientes = alertas.where((a) => a.esPendiente).toList();
        _alertasAutomaticas = alertas.where((a) => a.esAutomatica).toList();
        _isLoading = false;
      });

      AppLogger.info('AlertasScreen: Alertas cargadas - Total: ${alertas.length}, Críticas: ${_alertasCriticas.length}, Pendientes: ${_alertasPendientes.length}, Automáticas: ${_alertasAutomaticas.length}');
    } catch (e) {
      AppLogger.error('AlertasScreen: Error cargando alertas', error: e);
      if (!mounted || _isDisposed) return;

      setState(() {
        _error = 'Error al cargar alertas: $e';
        _isLoading = false;
      });
    }
  }


  Future<void> _marcarComoLeida(Alerta alerta) async {
    try {
      final service = ref.read(alertaServiceSimpleProvider);
      await service.marcarComoLeida(alerta.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta marcada como leída'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarAlertas(); // Recargar para actualizar el estado
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar alerta como leída: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Filtro por prioridad
              DropdownButtonFormField<String>(
                value: _filtroPrioridad,
                decoration: const InputDecoration(
                  labelText: 'Prioridad',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Todas')),
                  ...AlertaNivel.values.map((p) => 
                    DropdownMenuItem<String>(value: p.name, child: Text(p.name.toUpperCase()))
                  ),
                ],
                onChanged: (value) {
                  setModalState(() {
                    _filtroPrioridad = value;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Filtro por tipo
              DropdownButtonFormField<String>(
                value: _filtroTipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('Todos')),
                  ...AlertaTipo.values.map((t) => 
                    DropdownMenuItem<String>(value: t.name, child: Text(t.name.toUpperCase()))
                  ),
                ],
                onChanged: (value) {
                  setModalState(() {
                    _filtroTipo = value;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Filtro por estado
              DropdownButtonFormField<String>(
                value: _filtroEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<String>(value: null, child: Text('Todos')),
                  DropdownMenuItem<String>(value: 'pendiente', child: Text('PENDIENTE')),
                  DropdownMenuItem<String>(value: 'en_progreso', child: Text('EN PROGRESO')),
                  DropdownMenuItem<String>(value: 'resuelta', child: Text('RESUELTA')),
                ],
                onChanged: (value) {
                  setModalState(() {
                    _filtroEstado = value;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Filtro automática
              CheckboxListTile(
                title: const Text('Solo alertas automáticas'),
                value: _filtroAutomatica ?? false,
                onChanged: (value) {
                  setModalState(() {
                    _filtroAutomatica = value == true ? true : null;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setModalState(() {
                          _filtroPrioridad = null;
                          _filtroTipo = null;
                          _filtroEstado = null;
                          _filtroAutomatica = null;
                        });
                      },
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          // Los filtros ya están actualizados
                        });
                        _cargarAlertas();
                      },
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAlertas,
            tooltip: 'Actualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(
              text: 'Todas',
              icon: Badge(
                label: Text('${_todasAlertas.length}'),
                child: const Icon(Icons.list),
              ),
            ),
            Tab(
              text: 'Críticas',
              icon: Badge(
                label: Text('${_alertasCriticas.length}'),
                child: const Icon(Icons.warning),
              ),
            ),
            Tab(
              text: 'Pendientes',
              icon: Badge(
                label: Text('${_alertasPendientes.length}'),
                child: const Icon(Icons.pending),
              ),
            ),
            Tab(
              text: 'Automáticas',
              icon: Badge(
                label: Text('${_alertasAutomaticas.length}'),
                child: const Icon(Icons.smart_toy),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertasList(_todasAlertas, 'todas'),
          _buildAlertasList(_alertasCriticas, 'criticas'),
          _buildAlertasList(_alertasPendientes, 'pendientes'),
          _buildAlertasList(_alertasAutomaticas, 'automaticas'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'alertas_fab',
        onPressed: () async {
          final result = await Navigator.of(context).pushNamed('/alertas/nueva');
          if (result == true) {
            // Recargar alertas si se creó una nueva
            _cargarAlertas();
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add_alert),
      ),
    );
  }

  Widget _buildAlertasList(List<Alerta> alertas, String tipo) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando alertas...'),
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
              onPressed: _cargarAlertas,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'criticas' ? Icons.priority_high_outlined :
              tipo == 'pendientes' ? Icons.mark_email_unread_outlined : 
              tipo == 'automaticas' ? Icons.smart_toy_outlined : Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              tipo == 'criticas' ? 'No hay alertas críticas' :
              tipo == 'pendientes' ? 'No hay alertas pendientes' :
              tipo == 'automaticas' ? 'No hay alertas automáticas' : 'No hay alertas',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAlertas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alertas.length,
        itemBuilder: (context, index) {
          final alerta = alertas[index];
          return _buildAlertaCard(alerta);
        },
      ),
    );
  }

  Widget _buildAlertaCard(Alerta alerta) {
    final isUrgent = alerta.nivelPrioridad == AlertaNivel.critica;
    final isWarning = alerta.nivelPrioridad == AlertaNivel.alta;

    Color cardColor = Colors.blue[50]!;
    Color iconColor = Colors.blue;
    IconData iconData = Icons.info;

    if (isUrgent) {
      cardColor = Colors.red[50]!;
      iconColor = Colors.red;
      iconData = Icons.priority_high;
    } else if (isWarning) {
      cardColor = Colors.orange[50]!;
      iconColor = Colors.orange;
      iconData = Icons.warning;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: alerta.esResuelta ? Colors.grey[100] : cardColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alerta.esResuelta ? Colors.grey[300] : iconColor.withValues(alpha: 0.2),
          child: Icon(
            iconData,
            color: alerta.esResuelta ? Colors.grey : iconColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                alerta.descripcion,
                style: TextStyle(
                  fontWeight: alerta.esResuelta ? FontWeight.normal : FontWeight.bold,
                  color: alerta.esResuelta ? Colors.grey[600] : null,
                ),
              ),
            ),
            if (!alerta.esResuelta)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              alerta.descripcionDetallada,
              style: TextStyle(
                color: alerta.esResuelta ? Colors.grey[600] : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(alerta.fechaCreacion),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!alerta.esResuelta)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read, size: 20),
                    SizedBox(width: 8),
                    Text('Marcar como leída'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
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
          onSelected: (value) async {
            if (value == 'mark_read') {
              await _marcarComoLeida(alerta);
            } else if (value == 'edit') {
              await _editarAlerta(alerta);
            } else if (value == 'details') {
              _mostrarDetalleAlerta(alerta);
            } else if (value == 'delete') {
              await _eliminarAlerta(alerta);
            }
          },
        ),
        onTap: () => _mostrarDetalleAlerta(alerta),
        isThreeLine: true,
      ),
    );
  }

  void _mostrarDetalleAlerta(Alerta alerta) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              alerta.nivelPrioridad == AlertaNivel.critica
                  ? Icons.priority_high
                  : alerta.nivelPrioridad == AlertaNivel.alta
                      ? Icons.warning
                      : Icons.info,
              color: alerta.nivelPrioridad == AlertaNivel.critica
                  ? Colors.red
                  : alerta.nivelPrioridad == AlertaNivel.alta
                      ? Colors.orange
                      : Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(alerta.tipoAlerta.name.toUpperCase())),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mensaje:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(alerta.descripcion),
            const SizedBox(height: 16),
            Text('Tipo:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(alerta.tipoAlerta.name.toUpperCase()),
            const SizedBox(height: 16),
            Text('Fecha:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(_formatDate(alerta.fechaCreacion)),
            const SizedBox(height: 16),
            Text('Estado:', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(alerta.esResuelta ? 'Resuelta' : 'Pendiente'),
          ],
        ),
        actions: [
          if (!alerta.esResuelta)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _marcarComoLeida(alerta);
              },
              child: const Text('Marcar como leída'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _editarAlerta(Alerta alerta) async {
    if (!mounted) return;

    try {
      final result = await Navigator.of(context).pushNamed('/alertas/editar/${alerta.id}', arguments: alerta);
      if (result == true) {
        // Recargar alertas si se editó
        _cargarAlertas();
      }
    } catch (e) {
      AppLogger.error('AlertasScreen: Error navegando a editar alerta', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir editor: $e')),
        );
      }
    }
  }

  Future<void> _eliminarAlerta(Alerta alerta) async {
    if (!mounted) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de que desea eliminar la alerta "${alerta.descripcion}"?'),
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

    if (confirmar != true) return;

    try {
      final alertaService = ref.read(alertaServiceProvider);
      await alertaService.deleteAlerta(alerta.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarAlertas(); // Recargar la lista
      }
    } catch (e) {
      AppLogger.error('AlertasScreen: Error eliminando alerta', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar alerta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
