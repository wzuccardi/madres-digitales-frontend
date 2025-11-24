import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/data/services/medico_service.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/app_bar_with_logo.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/data/services/ips_service.dart';
import 'package:madres_digitales_flutter_new/models/integrated_models.dart';
// import '../features/medicos/presentation/screens/medico_form_screen.dart'; // ELIMINADO

class MedicosScreen extends ConsumerStatefulWidget {
  const MedicosScreen({super.key});

  @override
  ConsumerState<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends ConsumerState<MedicosScreen> {
  late final MedicoService _medicoService;
  late final IPSService _ipsService;
  List<dynamic> _medicosList = [];
  List<dynamic> _filteredMedicosList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;
  String? _selectedIpsId;
  final List<Map<String, String>> _ipsOptions = [];
  List<Map<String, String>> _municipios = [];
  String? _selectedMunicipioId;
  bool _loadingMunicipios = true;
  String? _safeStr(dynamic v) => v?.toString();
  String? _medicoId(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['id']) : (m is MedicoIntegrado ? m.id : null);
  String _medicoNombre(dynamic m) {
    if (m is Map<String, dynamic>) {
      return _safeStr(m['nombre']) ?? 'Sin nombre';
    }
    if (m is MedicoIntegrado) {
      return m.especialidad.isNotEmpty ? m.especialidad : 'Sin nombre';
    }
    return 'Sin nombre';
  }
  String? _medicoEspecialidad(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['especialidad']) : (m is MedicoIntegrado ? m.especialidad : null);
  String? _medicoDocumento(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['documento']) : null;
  String? _medicoRegistro(dynamic m) {
    if (m is Map<String, dynamic>) {
      return _safeStr(m['registroMedico']) ?? _safeStr(m['registro_medico']);
    }
    if (m is MedicoIntegrado) {
      return m.registroMedico;
    }
    return null;
  }
  String? _medicoTelefono(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['telefono']) : null;
  String? _medicoEmail(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['email']) : null;
  String? _medicoIpsNombre(dynamic m) => (m is Map<String, dynamic>) ? _safeStr(m['ips']) ?? _safeStr(m['ips_nombre']) : (m is MedicoIntegrado ? m.ipsNombre : null);

  @override
  void initState() {
    super.initState();
    _medicoService = ref.read(medicoServiceProvider);
    _ipsService = ref.read(ipsServiceProvider);
    _loadMunicipiosOptions();
    _loadIpsOptions();
    _loadMedicos();
  }

  @override
  void dispose() {
    AppLogger.info('_MedicosScreenState: Iniciando dispose');
    _isDisposed = true;
    _searchController.dispose();
    AppLogger.info('_MedicosScreenState: Dispose completado');
    super.dispose();
  }

  Future<void> _loadMedicos() async {
    AppLogger.info('_MedicosScreenState: Iniciando carga de médicos');
    
    if (_isDisposed) {
      AppLogger.error('_MedicosScreenState: Widget dispuesto, cancelando carga de médicos');
      return;
    }
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
        AppLogger.info('_MedicosScreenState: Estado de carga actualizado a true');
      }
    });
    
    try {
      AppLogger.info('_MedicosScreenState: Obteniendo médicos del servicio');
      List<dynamic> medicos;
      if (_selectedIpsId != null && _selectedIpsId!.isNotEmpty) {
        medicos = await _medicoService.getMedicosByIps(_selectedIpsId!);
      } else {
        medicos = await _medicoService.getAllMedicos();
      }
      AppLogger.info('_MedicosScreenState: Médicos obtenidos: ${medicos.length}');
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _medicosList = medicos;
            _filteredMedicosList = medicos;
            _isLoading = false;
          });
          AppLogger.info('_MedicosScreenState: Estado actualizado con médicos cargados');
        } else {
          AppLogger.error('_MedicosScreenState: Widget no montado o dispuesto, no se actualiza estado');
        }
      });
    } catch (e) {
      AppLogger.error('_MedicosScreenState: Error cargando médicos', error: e);
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _isLoading = false);
          AppLogger.info('_MedicosScreenState: Estado de carga actualizado a false');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar médicos: $e')),
          );
        } else {
          AppLogger.error('_MedicosScreenState: Widget no montado o dispuesto en catch');
        }
      });
    }
  }

  void _filterMedicos(String query) {
    AppLogger.info('_MedicosScreenState: Filtrando médicos con query: $query');
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _searchQuery = query;
          final searchLower = query.toLowerCase();
          final byText = query.isEmpty
              ? _medicosList
              : _medicosList.where((medico) {
                  final nombre = _medicoNombre(medico).toLowerCase();
                  final documento = (_medicoDocumento(medico) ?? '').toLowerCase();
                  final especialidad = (_medicoEspecialidad(medico) ?? '').toLowerCase();
                  return nombre.contains(searchLower) || documento.contains(searchLower) || especialidad.contains(searchLower);
                }).toList();
          _filteredMedicosList = byText.where((medico) {
            if (_selectedIpsId != null && _selectedIpsId!.isNotEmpty) {
              final ipsId = (medico is Map<String, dynamic>) ? (medico['ips_id']?.toString() ?? '') : '';
              if (ipsId != _selectedIpsId) return false;
            }
            if (_selectedMunicipioId != null && _selectedMunicipioId!.isNotEmpty) {
              final munId = (medico is Map<String, dynamic>) ? (medico['municipio_id']?.toString() ?? '') : '';
              if (munId != _selectedMunicipioId) return false;
            }
            return true;
          }).toList();
          AppLogger.info('_MedicosScreenState: Médicos filtrados: ${_filteredMedicosList.length}');
        });
      } else {
        AppLogger.error('_MedicosScreenState: Widget no montado o dispuesto, no se filtra');
      }
    });
  }

  Future<void> _deleteMedico(String id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar al médico "$nombre"?'),
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
        await _medicoService.deleteMedico(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Médico eliminado exitosamente')),
          );
        }
        _loadMedicos();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar médico: $e')),
          );
        }
      }
    }
  }

  Color _getEspecialidadColor(String? especialidad) {
    final especialidades = {
      'medicina general': Colors.blue,
      'ginecologia': Colors.pink,
      'pediatria': Colors.green,
      'cardiologia': Colors.red,
      'cirugia': Colors.orange,
    };
    return especialidades[especialidad?.toLowerCase()] ?? Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithLogo(
        title: 'Médicos',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedicos,
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
                  value: _selectedIpsId,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por IPS',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                    ..._ipsOptions.map((ips) => DropdownMenuItem<String?>(
                          value: ips['id'],
                          child: Text(ips['nombre'] ?? ''),
                        )),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _selectedIpsId = value;
                    });
                    _filterMedicos(_searchQuery);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedMunicipioId,
                  decoration: const InputDecoration(
                    labelText: 'Municipio',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                    ..._municipios.map((m) => DropdownMenuItem<String?>(value: m['id'], child: Text(m['nombre'] ?? ''))),
                  ],
                  onChanged: (v) {
                    setState(() { _selectedMunicipioId = v; });
                    _filterMedicos(_searchQuery);
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
                hintText: 'Buscar por nombre, documento o especialidad...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterMedicos('');
                          AppLogger.info('_MedicosScreenState: Búsqueda limpiada');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterMedicos,
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_filteredMedicosList.length} médicos encontrados',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de médicos
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedicosList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay médicos registrados'
                                  : 'No se encontraron médicos',
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
                        itemCount: _filteredMedicosList.length,
                        itemBuilder: (context, index) {
                          final medico = _filteredMedicosList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getEspecialidadColor(_medicoEspecialidad(medico)),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                _medicoNombre(medico),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (_medicoDocumento(medico) != null) Text('Documento: ${_medicoDocumento(medico)}'),
                                  if (_medicoRegistro(medico) != null) Text('Registro: ${_medicoRegistro(medico)}'),
                                  if (_medicoEspecialidad(medico) != null) Text('Especialidad: ${_medicoEspecialidad(medico)}'),
                                  if (_medicoTelefono(medico) != null) Text('📞 ${_medicoTelefono(medico)}'),
                                  if (_medicoEmail(medico) != null) Text('📧 ${_medicoEmail(medico)}'),
                                  if (_medicoIpsNombre(medico) != null) Text('🏥 ${_medicoIpsNombre(medico)}'),
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
                                    final id = _medicoId(medico);
                                    if (id != null && id.isNotEmpty) {
                                      context.push('/medicos/editar/$id', extra: medico);
                                    }
                                    
                                    // Recargar después de un delay para simular regreso
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        _loadMedicos();
                                      }
                                    });
                                  } else if (value == 'delete') {
                                    final id = _medicoId(medico);
                                    _deleteMedico(id ?? '', _medicoNombre(medico));
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
          
          context.push('/medicos/nuevo');
          
          // Recargar después de un delay para simular regreso
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _loadMedicos();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Médico'),
      ),

    );
  }

  Future<void> _loadIpsOptions() async {
    try {
      final ipsList = await _ipsService.getAllIPS();
      if (mounted && !_isDisposed) {
        setState(() {
          _ipsOptions.clear();
          _ipsOptions.addAll(ipsList.map((e) => {'id': e.id, 'nombre': e.nombre}));
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMunicipiosOptions() async {
    try {
      final ms = ref.read(municipioServiceProvider);
      final list = await ms.getMunicipios(activo: true, limit: 200);
      if (mounted && !_isDisposed) {
        setState(() {
          _municipios = list.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
          _loadingMunicipios = false;
        });
      }
    } catch (_) {
      setState(() { _loadingMunicipios = false; });
    }
  }
}

