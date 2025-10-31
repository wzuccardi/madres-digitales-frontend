import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/service_providers.dart';
import '../../../../services/auth_service.dart';
import '../../../../shared/widgets/app_bar_with_logo.dart';

class MunicipiosAdminScreen extends ConsumerStatefulWidget {
  const MunicipiosAdminScreen({super.key});

  @override
  ConsumerState<MunicipiosAdminScreen> createState() => _MunicipiosAdminScreenState();
}

class _MunicipiosAdminScreenState extends ConsumerState<MunicipiosAdminScreen> {
  final AuthService _authService = AuthService();
  
  List<Map<String, dynamic>> _municipios = [];
  List<Map<String, dynamic>> _municipiosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  
  // Filtros
  String _searchQuery = '';
  String _filtroEstado = 'todos'; // todos, activos, inactivos
  String _filtroDepartamento = 'todos';
  
  // PaginaciÃ³n
  int _currentPage = 1;
  final int _itemsPerPage = 20;
  int _totalItems = 0;
  
  // EstadÃ­sticas
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _verificarPermisos();
  }

  void _verificarPermisos() {
    if (!_authService.isSuperAdmin() && !_authService.isAdmin()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso denegado. Solo super administradores o administradores pueden acceder.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    _loadData();
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

      final apiService = ref.read(apiServiceProvider);

      // Usar el endpoint stats que no requiere autenticaciÃ³n
      final statsResponse = await apiService.get('/municipios/stats');
      
      // Usar el endpoint pÃºblico de municipios que no requiere autenticaciÃ³n
      final municipiosResponse = await apiService.get('/municipios');


      if (statsResponse.data['success'] == true && municipiosResponse.data['success'] == true) {
        final allMunicipios = List<Map<String, dynamic>>.from(municipiosResponse.data['data']);
        
        // Combinar datos de municipios con estadÃ­sticas
        final municipiosConStats = allMunicipios.map((municipio) {
          // Buscar estadÃ­sticas si existen (valores predeterminados en 0)
          return {
            ...municipio,
            'estadisticas': {
              'gestantes': 0,
              'medicos': 0,
              'madrinas': 0,
              'ips': 0,
              'gestantes_activas': 0,
              'gestantes_riesgo_alto': 0,
              'alertas_activas': 0
            }
          };
        }).toList();

        if (mounted) {
          setState(() {
            _municipios = municipiosConStats;
            _totalItems = municipiosConStats.length;
            _isLoading = false;
          });
          _aplicarFiltros();
        }

      } else {
        throw Exception('Error desconocido al cargar datos');
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
      final apiService = ref.read(apiServiceProvider);

      final response = await apiService.get('/municipios/stats');


      if (response.data['success'] == true && mounted) {
        setState(() {
          _estadisticas = response.data['data'];
        });
      }
    } catch (e) {
    }
  }

  void _aplicarFiltros() {
    if (mounted) {
      setState(() {
        _municipiosFiltrados = _municipios.where((municipio) {
          // Filtro por bÃºsqueda
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
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'AdministraciÃ³n de Municipios',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _showImportDialog,
            tooltip: 'Importar municipios',
          ),
        ],
      ),
      body: Column(
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
              initialValue: _filtroEstado,
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
              initialValue: _filtroDepartamento,
              decoration: const InputDecoration(
                labelText: 'Departamento',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos')),
                DropdownMenuItem(value: 'BOLÃVAR', child: Text('BolÃ­var')),
                // Agregar mÃ¡s departamentos segÃºn sea necesario
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
            DataColumn(label: Text('CÃ³digo')),
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Departamento')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Gestantes')),
            DataColumn(label: Text('Madrinas')),
            DataColumn(label: Text('MÃ©dicos')),
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
          Text('PÃ¡gina $_currentPage de $totalPages'),
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
        content: Text('Â¿EstÃ¡ seguro que desea $action el municipio ${municipio['nombre']}?'),
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

      // Usar el endpoint correcto segÃºn el estado actual
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
        // Mostrar el mensaje de error especÃ­fico del backend
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
              Text('CÃ³digo: ${municipio['codigo']}'),
              Text('Departamento: ${municipio['departamento']}'),
              Text('Estado: ${municipio['activo'] ? 'Activo' : 'Inactivo'}'),
              const SizedBox(height: 16),
              const Text('EstadÃ­sticas:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Gestantes: ${municipio['estadisticas']?['gestantes'] ?? 0}'),
              Text('Madrinas: ${municipio['estadisticas']?['madrinas'] ?? 0}'),
              Text('MÃ©dicos: ${municipio['estadisticas']?['medicos'] ?? 0}'),
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
          'Esta funciÃ³n importarÃ¡ los municipios desde el archivo Bolivar.txt. '
          'Â¿Desea continuar?'
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
      // Mostrar diÃ¡logo de progreso
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Importando municipios de BolÃ­var...'),
              Text('Este proceso puede tomar unos minutos.'),
            ],
          ),
        ),
      );

      // final response = await ApiService.importarMunicipiosBolivar();
      final response = {'success': true, 'message': 'ImportaciÃ³n simulada'}; // Temporal fix

      // Verificar si el widget sigue montado antes de usar context
      if (!mounted) return;

      // Cerrar diÃ¡logo de progreso
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

      // Cerrar diÃ¡logo de progreso si estÃ¡ abierto
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

