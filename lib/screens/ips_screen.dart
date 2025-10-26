import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/ips_service.dart';
import '../shared/widgets/app_bar_with_logo.dart';
import '../providers/service_providers.dart';
// import '../features/ips/presentation/screens/ips_form_screen.dart'; // ELIMINADO
import '../utils/logger.dart';

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

  @override
  void initState() {
    super.initState();
    _ipsService = IPSService(ref.read(apiServiceProvider));
    _loadIps();
  }

  @override
  void dispose() {
    appLogger.info('_IpsScreenState: Iniciando dispose');
    _isDisposed = true;
    _searchController.dispose();
    appLogger.info('_IpsScreenState: Dispose completado');
    super.dispose();
  }

  Future<void> _loadIps() async {
    appLogger.info('_IpsScreenState: Iniciando carga de IPS');
    
    if (_isDisposed) {
      appLogger.error('_IpsScreenState: Widget dispuesto, cancelando carga de IPS');
      return;
    }
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
        appLogger.info('_IpsScreenState: Estado de carga actualizado a true');
      }
    });
    
    try {
      appLogger.info('_IpsScreenState: Obteniendo IPS del servicio');
      final ips = await _ipsService.obtenerTodasLasIPS();
      appLogger.info('_IpsScreenState: IPS obtenidas: ${ips.length}');
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _ipsList = ips;
            _filteredIpsList = ips;
            _isLoading = false;
          });
          appLogger.info('_IpsScreenState: Estado actualizado con IPS cargadas');
        } else {
          appLogger.error('_IpsScreenState: Widget no montado o dispuesto, no se actualiza estado');
        }
      });
    } catch (e) {
      appLogger.error('_IpsScreenState: Error cargando IPS', error: e);
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _isLoading = false);
          appLogger.info('_IpsScreenState: Estado de carga actualizado a false');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar IPS: $e')),
          );
        } else {
          appLogger.error('_IpsScreenState: Widget no montado o dispuesto en catch');
        }
      });
    }
  }

  void _filterIps(String query) {
    appLogger.info('_IpsScreenState: Filtrando IPS con query: $query');
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _searchQuery = query;
          if (query.isEmpty) {
            _filteredIpsList = _ipsList;
            appLogger.info('_IpsScreenState: Filtro eliminado, mostrando todas las IPS');
          } else {
            _filteredIpsList = _ipsList.where((ips) {
              final nombre = (ips['nombre'] ?? '').toString().toLowerCase();
              final nit = (ips['nit'] ?? '').toString().toLowerCase();
              final municipio = (ips['municipio']?['nombre'] ?? '').toString().toLowerCase();
              final searchLower = query.toLowerCase();
              return nombre.contains(searchLower) ||
                     nit.contains(searchLower) ||
                     municipio.contains(searchLower);
            }).toList();
            appLogger.info('_IpsScreenState: IPS filtradas: ${_filteredIpsList.length}');
          }
        });
      } else {
        appLogger.error('_IpsScreenState: Widget no montado o dispuesto, no se filtra');
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
        await _ipsService.eliminarIPS(id);
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
      appBar: AppBarWithLogo(
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
                          appLogger.info('_IpsScreenState: Búsqueda limpiada');
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
                                    Text('🏛️ ${ips['municipio']['nombre'] ?? 'Sin municipio'}'),
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
                                    print('🏥 IpsScreen: ========== EDITANDO IPS ==========');
                                    print('🏥 IpsScreen: ID de la IPS: ${ips['id']}');
                                    print('🏥 IpsScreen: Navegando al formulario de edición con GoRouter...');
                                    
                                    context.push('/ips/editar/${ips['id']}', extra: ips);
                                    
                                    // Recargar después de un delay
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted && !_isDisposed) {
                                        print('🏥 IpsScreen: Recargando lista de IPS...');
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
          print('🏥 IpsScreen: ========== CREANDO NUEVA IPS ==========');
          print('🏥 IpsScreen: Navegando al formulario de creación con GoRouter...');
          
          context.push('/ips/nuevo');
          
          // Recargar después de un delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted && !_isDisposed) {
              print('🏥 IpsScreen: Recargando lista de IPS...');
              _loadIps();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva IPS'),
      ),

    );
  }
}