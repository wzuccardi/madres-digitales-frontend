﻿import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/medico_service.dart';
import '../shared/widgets/app_bar_with_logo.dart';
// import '../features/medicos/presentation/screens/medico_form_screen.dart'; // ELIMINADO
import '../utils/logger.dart';

class MedicosScreen extends StatefulWidget {
  const MedicosScreen({super.key});

  @override
  State<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends State<MedicosScreen> {
  final MedicoService _medicoService = MedicoService();
  List<dynamic> _medicosList = [];
  List<dynamic> _filteredMedicosList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadMedicos();
  }

  @override
  void dispose() {
    appLogger.info('_MedicosScreenState: Iniciando dispose');
    _isDisposed = true;
    _searchController.dispose();
    appLogger.info('_MedicosScreenState: Dispose completado');
    super.dispose();
  }

  Future<void> _loadMedicos() async {
    appLogger.info('_MedicosScreenState: Iniciando carga de mÃ©dicos');
    
    if (_isDisposed) {
      appLogger.error('_MedicosScreenState: Widget dispuesto, cancelando carga de mÃ©dicos');
      return;
    }
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
        appLogger.info('_MedicosScreenState: Estado de carga actualizado a true');
      }
    });
    
    try {
      appLogger.info('_MedicosScreenState: Obteniendo mÃ©dicos del servicio');
      final medicos = await _medicoService.getAllMedicos();
      appLogger.info('_MedicosScreenState: MÃ©dicos obtenidos: ${medicos.length}');
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() {
            _medicosList = medicos;
            _filteredMedicosList = medicos;
            _isLoading = false;
          });
          appLogger.info('_MedicosScreenState: Estado actualizado con mÃ©dicos cargados');
        } else {
          appLogger.error('_MedicosScreenState: Widget no montado o dispuesto, no se actualiza estado');
        }
      });
    } catch (e) {
      appLogger.error('_MedicosScreenState: Error cargando mÃ©dicos', error: e);
      
      // Usar WidgetsBinding para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _isLoading = false);
          appLogger.info('_MedicosScreenState: Estado de carga actualizado a false');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar mÃ©dicos: $e')),
          );
        } else {
          appLogger.error('_MedicosScreenState: Widget no montado o dispuesto en catch');
        }
      });
    }
  }

  void _filterMedicos(String query) {
    appLogger.info('_MedicosScreenState: Filtrando mÃ©dicos con query: $query');
    
    // Usar WidgetsBinding para evitar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        setState(() {
          _searchQuery = query;
          if (query.isEmpty) {
            _filteredMedicosList = _medicosList;
            appLogger.info('_MedicosScreenState: Filtro eliminado, mostrando todos los mÃ©dicos');
          } else {
            _filteredMedicosList = _medicosList.where((medico) {
              final nombre = (medico['nombre'] ?? '').toString().toLowerCase();
              final documento = (medico['documento'] ?? '').toString().toLowerCase();
              final especialidad = (medico['especialidad'] ?? '').toString().toLowerCase();
              final searchLower = query.toLowerCase();
              return nombre.contains(searchLower) ||
                     documento.contains(searchLower) ||
                     especialidad.contains(searchLower);
            }).toList();
            appLogger.info('_MedicosScreenState: MÃ©dicos filtrados: ${_filteredMedicosList.length}');
          }
        });
      } else {
        appLogger.error('_MedicosScreenState: Widget no montado o dispuesto, no se filtra');
      }
    });
  }

  Future<void> _deleteMedico(String id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminaciÃ³n'),
        content: Text('Â¿EstÃ¡ seguro de eliminar al mÃ©dico "$nombre"?'),
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
            const SnackBar(content: Text('MÃ©dico eliminado exitosamente')),
          );
        }
        _loadMedicos();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar mÃ©dico: $e')),
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
      appBar: AppBarWithLogo(
        title: 'MÃ©dicos',
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
          // Barra de bÃºsqueda
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
                          appLogger.info('_MedicosScreenState: BÃºsqueda limpiada');
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
                  '${_filteredMedicosList.length} mÃ©dicos encontrados',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de mÃ©dicos
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
                                  ? 'No hay mÃ©dicos registrados'
                                  : 'No se encontraron mÃ©dicos',
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
                                backgroundColor: _getEspecialidadColor(medico['especialidad']),
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(
                                medico['nombre'] ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (medico['documento'] != null) Text('Documento: ${medico['documento']}'),
                                  if (medico['registroMedico'] != null) Text('Registro: ${medico['registroMedico']}'),
                                  if (medico['especialidad'] != null) Text('Especialidad: ${medico['especialidad']}'),
                                  if (medico['telefono'] != null) Text('ðŸ“ž ${medico['telefono']}'),
                                  if (medico['email'] != null) Text('ðŸ“§ ${medico['email']}'),
                                  if (medico['ips'] != null) Text('ðŸ¥ ${medico['ips']}'),
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
                                    
                                    context.push('/medicos/editar/${medico['id']}', extra: medico);
                                    
                                    // Recargar despuÃ©s de un delay para simular regreso
                                    Future.delayed(const Duration(seconds: 1), () {
                                      if (mounted) {
                                        _loadMedicos();
                                      }
                                    });
                                  } else if (value == 'delete') {
                                    _deleteMedico(medico['id'], medico['nombre'] ?? 'Sin nombre');
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
          
          // Recargar despuÃ©s de un delay para simular regreso
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _loadMedicos();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo MÃ©dico'),
      ),

    );
  }
}

