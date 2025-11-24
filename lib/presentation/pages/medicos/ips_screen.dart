import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/data/services/ips_service.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/app_bar_with_logo.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
// import '../features/ips/presentation/screens/ips_form_screen.dart'; // ELIMINADO

class IpsScreen extends ConsumerStatefulWidget {
  const IpsScreen({super.key});

  @override
  ConsumerState<IpsScreen> createState() => _IpsScreenState();
}

class _IpsScreenState extends ConsumerState<IpsScreen> {
  late final IPSService _ipsService;
  List<dynamic> _ipsList = [];
  List<dynamic> _filteredIpsList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;
  String? _selectedDepartamento;
  String? _selectedCiudad;
  String? _selectedTipo;
  int? _selectedNivel;
  final List<String> _departamentos = [];
  final List<String> _ciudades = [];

  @override
  void initState() {
    super.initState();
    _ipsService = ref.read(ipsServiceProvider);
    _loadDepartamentos();
    _loadIps();
  }

  @override
  void dispose() {
    AppLogger.info('_IpsScreenState: Iniciando dispose');
    _isDisposed = true;
    _searchController.dispose();
    AppLogger.info('_IpsScreenState: Dispose completado');
    super.dispose();
  }

  Future<void> _loadIps() async {
    AppLogger.info('_IpsScreenState: Iniciando carga de IPS');
    
    if (_isDisposed) {
      AppLogger.error('_IpsScreenState: Widget dispuesto, cancelando carga de IPS');
      return;
    }
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
        AppLogger.info('_IpsScreenState: Estado de carga actualizado a true');
      }
    });
    
    try {
      AppLogger.info('_IpsScreenState: Obteniendo IPS del servicio');
      List<IPS> ipsEntities;
      if (_searchQuery.isNotEmpty) {
        ipsEntities = (await _ipsService.searchIPS(_searchQuery));
      } else if (_selectedCiudad != null && _selectedCiudad!.isNotEmpty) {
        ipsEntities = (await _ipsService.getIPSByCiudad(_selectedCiudad!));
      } else if (_selectedDepartamento != null && _selectedDepartamento!.isNotEmpty) {
        ipsEntities = (await _ipsService.getIPSByDepartamento(_selectedDepartamento!));
      } else if (_selectedTipo != null && _selectedTipo!.isNotEmpty) {
        ipsEntities = (await _ipsService.getIPSByTipo(_selectedTipo!));
      } else if (_selectedNivel != null) {
        ipsEntities = (await _ipsService.getIPSByNivel(_selectedNivel!));
      } else {
        ipsEntities = (await _ipsService.getAllIPS());
      }
      final ips = ipsEntities.map((e) => {
        'id': e.id,
        'nombre': e.nombre,
        'nit': e.nit,
        'municipio': e.ciudad,
      }).toList();
      AppLogger.info('_IpsScreenState: IPS obtenidas: ${ips.length}');
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _ipsList = ips;
            _filteredIpsList = ips;
            _isLoading = false;
          });
          AppLogger.info('_IpsScreenState: Estado actualizado con IPS cargadas');
        } else {
          AppLogger.error('_IpsScreenState: Widget no montado o dispuesto, no se actualiza estado');
        }
      });
    } catch (e) {
      AppLogger.error('_IpsScreenState: Error cargando IPS', error: e);
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _isLoading = false);
          AppLogger.info('_IpsScreenState: Estado de carga actualizado a false');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar IPS: $e')),
          );
        } else {
          AppLogger.error('_IpsScreenState: Widget no montado o dispuesto en catch');
        }
      });
    }
  }

  void _filterIps(String query) {
    AppLogger.info('_IpsScreenState: Filtrando IPS con query: $query');
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _searchQuery = query;
          if (query.isEmpty) {
            _filteredIpsList = _ipsList;
            AppLogger.info('_IpsScreenState: Filtro eliminado, mostrando todas las IPS');
          } else {
            _filteredIpsList = _ipsList.where((ips) {
              final nombre = (ips['nombre'] ?? '').toString().toLowerCase();
              final nit = (ips['nit'] ?? '').toString().toLowerCase();
              final municipio = (ips['municipio'] ?? '').toString().toLowerCase();
              final searchLower = query.toLowerCase();
              return nombre.contains(searchLower) ||
                     nit.contains(searchLower) ||
                     municipio.contains(searchLower);
            }).toList();
            AppLogger.info('_IpsScreenState: IPS filtradas: ${_filteredIpsList.length}');
          }
        });
      } else {
        AppLogger.error('_IpsScreenState: Widget no montado o dispuesto, no se filtra');
      }
    });
  }

  Future<void> _deleteIps(String id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la IPS "$nombre"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _ipsService.deleteIPS(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('IPS eliminada exitosamente')),
          );
        }
        _loadIps();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar IPS: $e')),
          );
        }
      }
    }
  }

  Color _getNivelAtencionColor(String? nivel) {
    switch (nivel) {
      case 'primario':
        return Colors.green;
      case 'secundario':
        return Colors.orange;
      case 'terciario':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _getNivelAtencionLabel(String? nivel) {
    switch (nivel) {
      case 'primario':
        return 'Primer Nivel';
      case 'secundario':
        return 'Segundo Nivel';
      case 'terciario':
        return 'Tercer Nivel';
      default:
        return nivel ?? 'Sin especificar';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogo(
        title: 'IPS - Instituciones Prestadoras de Salud',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIps,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedDepartamento,
                    decoration: const InputDecoration(
                      labelText: 'Departamento',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                      ..._departamentos.map((d) => DropdownMenuItem<String?>(value: d, child: Text(d))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartamento = value;
                        _selectedCiudad = null;
                      });
                      _loadCiudades();
                      _loadIps();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    value: _selectedCiudad,
                    decoration: const InputDecoration(
                      labelText: 'Ciudad',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                      ..._ciudades.map((c) => DropdownMenuItem<String?>(value: c, child: Text(c))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCiudad = value;
                      });
                      _loadIps();
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<String>(value: null, child: Text('Todos')),
                      DropdownMenuItem<String>(value: 'publica', child: Text('Pública')),
                      DropdownMenuItem<String>(value: 'privada', child: Text('Privada')),
                      DropdownMenuItem<String>(value: 'mixta', child: Text('Mixta')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedTipo = value;
                      });
                      _loadIps();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedNivel,
                    decoration: const InputDecoration(
                      labelText: 'Nivel',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem<int>(value: null, child: Text('Todos')),
                      DropdownMenuItem<int>(value: 1, child: Text('Primario')),
                      DropdownMenuItem<int>(value: 2, child: Text('Secundario')),
                      DropdownMenuItem<int>(value: 3, child: Text('Terciario')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedNivel = value;
                      });
                      _loadIps();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, NIT o municipio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterIps('');
                          AppLogger.info('_IpsScreenState: Búsqueda limpiada');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterIps,
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_filteredIpsList.length} IPS encontradas',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de IPS
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredIpsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_hospital_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay IPS registradas'
                                  : 'No se encontraron IPS',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredIpsList.length,
                        itemBuilder: (context, index) {
                          final ips = _filteredIpsList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getNivelAtencionColor(ips['nivel']),
                                child: const Icon(Icons.local_hospital, color: Colors.white),
                              ),
                              title: Text(
                                ips['nombre'] ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (ips['nit'] != null) Text('NIT: ${ips['nit']}'),
                                  Text('Nivel: ${_getNivelAtencionLabel(ips['nivel'])}'),
                                  if (ips['direccion'] != null)
                                    Text('📍 ${ips['direccion']}'),
                                  if (ips['telefono'] != null)
                                    Text('📞 ${ips['telefono']}'),
                                  if (ips['municipio'] != null)
                                    Text('🏛️ ${ips['municipio']}'),
                                ],
                              ),
                              trailing: PopupMenuButton(
                                itemBuilder: (context) => [
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
                                  if (value == 'edit') {
                                    
                                    context.push('/ips/editar/${ips['id']}', extra: ips);
                                    
                                    // Recargar después de un delay
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted && !_isDisposed) {
                                        _loadIps();
                                      }
                                    });
                                  } else if (value == 'delete') {
                                    _deleteIps(ips['id'], ips['nombre'] ?? 'Sin nombre');
                                  }
                                },
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          
          context.push('/ips/nuevo');
          
          // Recargar después de un delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_isDisposed) {
              _loadIps();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva IPS'),
      ),

    );
  }

  Future<void> _loadDepartamentos() async {
    try {
      final deps = await _ipsService.getDepartamentos();
      if (mounted && !_isDisposed) {
        setState(() {
          _departamentos.clear();
          _departamentos.addAll(deps);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCiudades() async {
    if (_selectedDepartamento == null || _selectedDepartamento!.isEmpty) return;
    try {
      final ciudades = await _ipsService.getCiudadesByDepartamento(_selectedDepartamento!);
      if (mounted && !_isDisposed) {
        setState(() {
          _ciudades.clear();
          _ciudades.addAll(ciudades);
        });
      }
    } catch (_) {}
  }
  }
