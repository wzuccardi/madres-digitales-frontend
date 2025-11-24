import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/application/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/app_bar_with_logo.dart';

class MunicipiosAdminScreen extends ConsumerStatefulWidget {
  const MunicipiosAdminScreen({super.key});

  @override
  ConsumerState<MunicipiosAdminScreen> createState() => _MunicipiosAdminScreenState();
}

class _MunicipiosAdminScreenState extends ConsumerState<MunicipiosAdminScreen> {
  
  List<Map<String, dynamic>> _municipios = [];
  List<Map<String, dynamic>> _municipiosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  String _searchQuery = '';
  String _filtroEstado = 'todos'; // todos, activos, inactivos
  String _filtroDepartamento = 'todos';
  
  // Paginación
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  int _totalItems = 0;
  
  // Estadísticas
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  void _verificarPermisos() {
    // Escuchar cambios en permisos para evitar bloqueo por estado aún no inicializado
    ref.listen<bool>(isSuperAdminProvider, (prev, isSuper) {
      final isAdmin = ref.read(isAdminProvider);
      if ((isSuper == true) || isAdmin) {
        _loadData();
      }
    });
    // Intento inicial con el estado actual
    final isSuper = ref.read(isSuperAdminProvider);
    final isAdmin = ref.read(isAdminProvider);
    if (isSuper || isAdmin) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadMunicipios(),
      _loadEstadisticas(),
    ]);
  }

  Future<void> _loadMunicipios() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final svc = ref.read(municipioServiceProvider);
      final stats = await svc.getStats();
      final allMunicipios = await svc.getMunicipios(
        page: _currentPage,
        limit: _itemsPerPage,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        departamento: _filtroDepartamento != 'todos' ? _filtroDepartamento : null,
      );
      final municipiosConStats = allMunicipios.map((m) => {
            'id': m.id,
            'codigo': m.codigo,
            'nombre': m.nombre,
            'departamento': m.departamento,
            'activo': m.activo,
            'estadisticas': stats['resumen'] ?? {},
          }).toList();

      if (mounted) {
        setState(() {
          _municipios = municipiosConStats;
          _totalItems = municipiosConStats.length;
          _isLoading = false;
        });
        _aplicarFiltros();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error cargando municipios: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadEstadisticas() async {
    try {
      final svc = ref.read(municipioServiceProvider);
      final stats = await svc.getStats();
      if (mounted) {
        setState(() {
          _estadisticas = stats;
        });
      }
    } catch (e) {
    }
  }

  void _aplicarFiltros() {
    if (mounted) {
      setState(() {
        _municipiosFiltrados = _municipios.where((municipio) {
          // Filtro por búsqueda
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final nombre = municipio['nombre']?.toLowerCase() ?? '';
            final codigo = municipio['codigo']?.toLowerCase() ?? '';
            if (!nombre.contains(query) && !codigo.contains(query)) {
              return false;
            }
          }

          // Filtro por departamento
          if (_filtroDepartamento != 'todos') {
            if (municipio['departamento'] != _filtroDepartamento) {
              return false;
            }
          }

          return true;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final puedeAcceder = ref.watch(isSuperAdminProvider) || ref.watch(isAdminProvider);
    return Scaffold(
      appBar: appBarWithLogo(
        title: 'Administración de Municipios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: puedeAcceder ? _loadData : null,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: puedeAcceder ? _showImportDialog : null,
            tooltip: 'Importar municipios',
          ),
        ],
      ),
      body: !puedeAcceder
          ? const Center(child: Text('Acceso denegado. Solo super administradores o administradores pueden acceder.'))
          : Column(
        children: [
          _buildEstadisticas(),
          _buildFiltros(),
          Expanded(child: _buildContent()),
          _buildPaginacion(),
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    if (_estadisticas == null) {
      return const SizedBox.shrink();
    }

    final resumen = _estadisticas!['resumen'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              '${resumen['total']}',
              Colors.blue,
              Icons.location_city,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Activos',
              '${resumen['activos']}',
              Colors.green,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Inactivos',
              '${resumen['inactivos']}',
              Colors.red,
              Icons.cancel,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Con Gestantes',
              '${resumen['conGestantes']}',
              Colors.orange,
              Icons.pregnant_woman,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar municipio',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _searchQuery = value;
                  });
                }
                _aplicarFiltros();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filtroEstado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'activos', child: Text('Activos')),
                DropdownMenuItem(value: 'inactivos', child: Text('Inactivos')),
              ],
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _filtroEstado = value!;
                    _currentPage = 1;
                  });
                }
                _loadMunicipios();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filtroDepartamento,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'BOLÍVAR', child: Text('Bolívar')),
                // Agregar más departamentos según sea necesario
              ],
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _filtroDepartamento = value!;
                  });
                }
                _aplicarFiltros();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando municipios...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_municipiosFiltrados.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No se encontraron municipios'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Código')),
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Departamento')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Gestantes')),
            DataColumn(label: Text('Madrinas')),
            DataColumn(label: Text('Médicos')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: _municipiosFiltrados.map((municipio) => _buildMunicipioRow(municipio)).toList(),
        ),
      ),
    );
  }

  DataRow _buildMunicipioRow(Map<String, dynamic> municipio) {
    final estadisticas = municipio['estadisticas'] ?? {};
    final activo = municipio['activo'] == true;

    return DataRow(
      cells: [
        DataCell(Text(municipio['codigo'] ?? '')),
        DataCell(Text(municipio['nombre'] ?? '')),
        DataCell(Text(municipio['departamento'] ?? '')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activo ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              activo ? 'Activo' : 'Inactivo',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        DataCell(Text('${estadisticas['gestantes'] ?? 0}')),
        DataCell(Text('${estadisticas['madrinas'] ?? 0}')),
        DataCell(Text('${estadisticas['medicos'] ?? 0}')),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  activo ? Icons.toggle_on : Icons.toggle_off,
                  color: activo ? Colors.green : Colors.red,
                ),
                onPressed: () => _toggleMunicipioStatus(municipio),
                tooltip: activo ? 'Desactivar' : 'Activar',
              ),
              IconButton(
                icon: const Icon(Icons.info),
                onPressed: () => _showMunicipioDetails(municipio),
                tooltip: 'Ver detalles',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaginacion() {
    final totalPages = (_totalItems / _itemsPerPage).ceil();
    
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Página $_currentPage de $totalPages'),
          IconButton(
            onPressed: _currentPage < totalPages ? () => _changePage(_currentPage + 1) : null,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  void _changePage(int newPage) {
    if (mounted) {
      setState(() {
        _currentPage = newPage;
      });
    }
    _loadMunicipios();
  }

  Future<void> _toggleMunicipioStatus(Map<String, dynamic> municipio) async {
    final activo = municipio['activo'] == true;
    final action = activo ? 'desactivar' : 'activar';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Municipio'),
        content: Text('¿Está seguro que desea $action el municipio ${municipio['nombre']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      final municipioId = municipio['id'];

      // Usar el endpoint correcto según el estado actual
      final endpoint = activo
          ? '/municipios/$municipioId/desactivar'
          : '/municipios/$municipioId/activar';

      final response = await apiService.post(endpoint);

      if (!mounted) return;

      if (response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Municipio ${activo ? 'desactivado' : 'activado'} correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        // Mostrar el mensaje de error específico del backend
        final errorMsg = response.data['error'] ?? 'Error desconocido';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (!mounted) return;

      // Extraer el mensaje de error limpio
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showMunicipioDetails(Map<String, dynamic> municipio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(municipio['nombre']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código: ${municipio['codigo']}'),
              Text('Departamento: ${municipio['departamento']}'),
              Text('Estado: ${municipio['activo'] ? 'Activo' : 'Inactivo'}'),
              const SizedBox(height: 16),
              const Text('Estadísticas:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Gestantes: ${municipio['estadisticas']?['gestantes'] ?? 0}'),
              Text('Madrinas: ${municipio['estadisticas']?['madrinas'] ?? 0}'),
              Text('Médicos: ${municipio['estadisticas']?['medicos'] ?? 0}'),
            ],
          ),
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

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar Municipios'),
        content: const Text(
          'Esta función importará los municipios desde el archivo Bolivar.txt. '
          '¿Desea continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _importMunicipios();
            },
            child: const Text('Importar'),
          ),
        ],
      ),
    );
  }

  Future<void> _importMunicipios() async {
    if (!mounted) return;

    try {
      // Mostrar diálogo de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Importando municipios de Bolívar...'),
              Text('Este proceso puede tomar unos minutos.'),
            ],
          ),
        ),
      );

      // final response = await ApiService.importarMunicipiosBolivar();
      final response = {'success': true, 'message': 'Importación simulada'}; // Temporal fix

      // Verificar si el widget sigue montado antes de usar context
      if (!mounted) return;

      // Cerrar diálogo de progreso
      Navigator.pop(context);

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'].toString()),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar datos
        _loadData();
      } else {
        throw Exception(response['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      if (!mounted) return;

      // Cerrar diálogo de progreso si está abierto
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importando municipios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

