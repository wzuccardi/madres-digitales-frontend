import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../features/contenido/data/models/contenido_model.dart' as ContenidoModelAlias;
import '../models/contenido_unificado.dart';
import '../providers/service_providers.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart';
import 'contenido_form_screen.dart';
import 'contenido_import_export_screen.dart';

class ContenidoCrudScreen extends ConsumerStatefulWidget {
  const ContenidoCrudScreen({super.key});

  @override
  ConsumerState<ContenidoCrudScreen> createState() => _ContenidoCrudScreenState();
}

class _ContenidoCrudScreenState extends ConsumerState<ContenidoCrudScreen> {
  List<ContenidoModelAlias.ContenidoModel> _contenidos = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'titulo'; // titulo, fecha, categoria, tipo
  bool _sortAscending = true;
  bool _showSelectedActions = false;
  final Set<String> _selectedContenidos = <String>{};

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
  }

  Future<void> _cargarContenidos() async {
    print('🔄 CRUD: Iniciando carga de contenidos...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      print('🔄 CRUD: Llamando a getAllContenidos()...');
      final contenidos = await contenidoService.getAllContenidos();
      print('✅ CRUD: Recibidos ${contenidos.length} contenidos');

      if (mounted) {
        setState(() {
          _contenidos = contenidos.map((c) => _convertToContenidoModel(c)).toList();
          _isLoading = false;
        });
        print('✅ CRUD: Estado actualizado con ${contenidos.length} contenidos');
      }
    } catch (e) {
      print('❌ CRUD: Error al cargar contenidos: $e');
      if (mounted) {
        setState(() {
          _error = 'Error al cargar contenidos: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _eliminarContenido(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este contenido?'),
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

    if (confirm != true) return;

    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      await contenidoService.deleteContenido(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contenido eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarContenidos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _duplicarContenido(ContenidoModelAlias.ContenidoModel contenido) async {
    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      
      // Crear una copia del contenido con "Copia" en el título
      final contenidoDuplicado = ContenidoUnificado(
        id: '', // ID vacío para nuevo contenido
        titulo: '${contenido.titulo} (Copia)',
        descripcion: contenido.descripcion,
        categoria: contenido.categoria,
        tipo: contenido.tipo,
        urlContenido: contenido.urlContenido,
        urlImagen: contenido.imagenUrl,
        duracionMinutos: contenido.duracion,
        nivel: contenido.nivel,
        tags: contenido.etiquetas,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
        activo: false, // Inactivar por defecto la copia
      );
      
      await contenidoService.saveContenido(contenidoDuplicado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Contenido duplicado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _cargarContenidos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al duplicar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleActivo(String id, bool activo) async {
    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      
      // Buscar el contenido y actualizar su estado
      final contenido = _contenidos.firstWhere((c) => c.id == id);
      final contenidoActualizado = ContenidoUnificado(
        id: contenido.id,
        titulo: contenido.titulo,
        descripcion: contenido.descripcion,
        categoria: contenido.categoria,
        tipo: contenido.tipo,
        urlContenido: contenido.urlContenido,
        urlImagen: contenido.imagenUrl,
        duracionMinutos: contenido.duracion,
        nivel: contenido.nivel,
        tags: contenido.etiquetas,
        fechaCreacion: contenido.fechaCreacion,
        fechaActualizacion: DateTime.now(),
        activo: activo,
      );
      
      await contenidoService.saveContenido(contenidoActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(activo ? '✅ Contenido activado' : '🔴 Contenido desactivado'),
            backgroundColor: activo ? Colors.green : Colors.orange,
          ),
        );
        _cargarContenidos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cambiar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _abrirUrl(String? url) async {
    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ No se puede abrir la URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _irAFormulario({ContenidoModelAlias.ContenidoModel? contenido}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContenidoFormScreen(
          contenido: contenido != null ? _convertToContenidoUnificado(contenido) : null,
          isSimpleMode: true,
        ),
      ),
    ).then((_) => _cargarContenidos());
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedContenidos.contains(id)) {
        _selectedContenidos.remove(id);
      } else {
        _selectedContenidos.add(id);
      }
      _showSelectedActions = _selectedContenidos.isNotEmpty;
    });
  }

  void _selectAll() {
    setState(() {
      if (_selectedContenidos.length == _contenidosFiltrados.length) {
        _selectedContenidos.clear();
      } else {
        _selectedContenidos.addAll(_contenidosFiltrados.map((c) => c.id));
      }
      _showSelectedActions = _selectedContenidos.isNotEmpty;
    });
  }

  Future<void> _activarSeleccionados(bool activo) async {
    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      
      for (final id in _selectedContenidos) {
        final contenido = _contenidos.firstWhere((c) => c.id == id);
        final contenidoActualizado = ContenidoUnificado(
          id: contenido.id,
          titulo: contenido.titulo,
          descripcion: contenido.descripcion,
          categoria: contenido.categoria,
          tipo: contenido.tipo,
          urlContenido: contenido.urlContenido,
          urlImagen: contenido.imagenUrl,
          duracionMinutos: contenido.duracion,
          nivel: contenido.nivel,
          tags: contenido.etiquetas,
          fechaCreacion: contenido.fechaCreacion,
          fechaActualizacion: DateTime.now(),
          activo: activo,
        );
        
        await contenidoService.saveContenido(contenidoActualizado);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activo ? '✅' : '🔴'} ${_selectedContenidos.length} contenido(s) ${activo ? 'activado(s)' : 'desactivado(s)'}'),
            backgroundColor: activo ? Colors.green : Colors.orange,
          ),
        );
        setState(() {
          _selectedContenidos.clear();
          _showSelectedActions = false;
        });
        _cargarContenidos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cambiar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _eliminarSeleccionados() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación masiva'),
        content: Text('¿Estás seguro de que deseas eliminar ${_selectedContenidos.length} contenidos? Esta acción no se puede deshacer.'),
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

    if (confirm != true) return;

    try {
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      
      for (final id in _selectedContenidos) {
        await contenidoService.deleteContenido(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${_selectedContenidos.length} contenido(s) eliminado(s)'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedContenidos.clear();
          _showSelectedActions = false;
        });
        _cargarContenidos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<ContenidoModelAlias.ContenidoModel> get _contenidosFiltrados {
    var contenidos = _contenidos.where((contenido) {
      return contenido.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             contenido.descripcion.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Aplicar ordenamiento
    contenidos.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'titulo':
          comparison = a.titulo.compareTo(b.titulo);
          break;
        case 'fecha':
          comparison = a.fechaCreacion.compareTo(b.fechaCreacion);
          break;
        case 'categoria':
          comparison = a.categoria.compareTo(b.categoria);
          break;
        case 'tipo':
          comparison = a.tipo.compareTo(b.tipo);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return contenidos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Contenidos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarContenidos,
            tooltip: 'Refrescar',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'titulo',
                child: Row(
                  children: [
                    Icon(Icons.title, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por título'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'fecha',
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por fecha'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categoria',
                child: Row(
                  children: [
                    Icon(Icons.category, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por categoría'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'tipo',
                child: Row(
                  children: [
                    Icon(Icons.type_specimen, size: 20),
                    SizedBox(width: 8),
                    Text('Ordenar por tipo'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            tooltip: 'Cambiar orden',
          ),
          IconButton(
            icon: const Icon(Icons.import_export),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ContenidoImportExportScreen(),
                ),
              ).then((_) => _cargarContenidos());
            },
            tooltip: 'Importar/Exportar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _irAFormulario(),
            tooltip: 'Nuevo contenido',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de herramientas de selección
          if (_showSelectedActions)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Text(
                    '${_selectedContenidos.length} seleccionado(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: _selectAll,
                    tooltip: 'Seleccionar todo',
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _activarSeleccionados(true),
                    tooltip: 'Activar seleccionados',
                  ),
                  IconButton(
                    icon: const Icon(Icons.block, color: Colors.orange),
                    onPressed: () => _activarSeleccionados(false),
                    tooltip: 'Desactivar seleccionados',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _eliminarSeleccionados,
                    tooltip: 'Eliminar seleccionados',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedContenidos.clear();
                        _showSelectedActions = false;
                      });
                    },
                    tooltip: 'Cancelar selección',
                  ),
                ],
              ),
            ),
          
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar contenidos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // Lista de contenidos
          Expanded(
            child: _isLoading
                ? const LoadingWidget(message: 'Cargando contenidos...')
                : _error != null
                    ? CustomErrorWidget(
                        message: _error!,
                        onRetry: _cargarContenidos,
                      )
                    : _contenidosFiltrados.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.content_paste,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'No se encontraron resultados'
                                      : 'No hay contenidos disponibles',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _irAFormulario(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Crear primer contenido'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _contenidosFiltrados.length,
                            itemBuilder: (context, index) {
                              final contenido = _contenidosFiltrados[index];
                              final isSelected = _selectedContenidos.contains(contenido.id);
                              
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: isSelected ? Colors.blue.shade50 : null,
                                child: ListTile(
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Checkbox para selección múltiple
                                      Checkbox(
                                        value: isSelected,
                                        onChanged: (value) {
                                          _toggleSelection(contenido.id);
                                        },
                                      ),
                                      CircleAvatar(
                                        backgroundColor: contenido.activo ? AppTheme.primaryColor : Colors.grey,
                                        child: Icon(
                                          _getIconoTipo(contenido.tipo),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    contenido.titulo,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      decoration: contenido.activo ? null : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Text(
                                        contenido.descripcion,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          Chip(
                                            label: Text(
                                              contenido.categoria,
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          Chip(
                                            label: Text(
                                              contenido.tipo,
                                              style: const TextStyle(fontSize: 11),
                                            ),
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          if (!contenido.activo)
                                            const Chip(
                                              label: Text(
                                                'Inactivo',
                                                style: TextStyle(fontSize: 11, color: Colors.white),
                                              ),
                                              backgroundColor: Colors.red,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _irAFormulario(contenido: contenido);
                                          break;
                                        case 'duplicate':
                                          _duplicarContenido(contenido);
                                          break;
                                        case 'toggle':
                                          _toggleActivo(contenido.id, !contenido.activo);
                                          break;
                                        case 'preview':
                                          _abrirUrl(contenido.urlContenido);
                                          break;
                                        case 'delete':
                                          _eliminarContenido(contenido.id);
                                          break;
                                      }
                                    },
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
                                        value: 'duplicate',
                                        child: Row(
                                          children: [
                                            Icon(Icons.copy, size: 20),
                                            SizedBox(width: 8),
                                            Text('Duplicar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'toggle',
                                        child: Row(
                                          children: [
                                            Icon(
                                              contenido.activo ? Icons.block : Icons.check_circle,
                                              size: 20,
                                              color: contenido.activo ? Colors.orange : Colors.green,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              contenido.activo ? 'Desactivar' : 'Activar',
                                              style: TextStyle(
                                                color: contenido.activo ? Colors.orange : Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (contenido.urlContenido != null && contenido.urlContenido!.isNotEmpty)
                                        const PopupMenuItem(
                                          value: 'preview',
                                          child: Row(
                                            children: [
                                              Icon(Icons.preview, size: 20),
                                              SizedBox(width: 8),
                                              Text('Vista previa'),
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
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContenidoFormScreen(
                contenido: null,
                isSimpleMode: true,
              ),
            ),
          );
          if (result == true) _cargarContenidos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Contenido'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
    );
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VIDEO':
        return Icons.play_circle_outline;
      case 'ARTICULO':
        return Icons.article;
      case 'INFOGRAFIA':
        return Icons.image;
      case 'PDF':
        return Icons.picture_as_pdf;
      case 'AUDIO':
        return Icons.audiotrack;
      default:
        return Icons.description;
    }
  }
  
  // Función para convertir ContenidoUnificado a ContenidoModel
  ContenidoModelAlias.ContenidoModel _convertToContenidoModel(ContenidoUnificado contenido) {
    return ContenidoModelAlias.ContenidoModel(
      id: contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion ?? '', // Corrección: descripcion es nullable
      categoria: contenido.categoria,
      tipo: contenido.tipo, // Corrección: usar tipo
      url: contenido.urlContenido,
      urlContenido: contenido.urlContenido,
      thumbnailUrl: null,
      imagenUrl: contenido.urlImagen, // Corrección: usar urlImagen
      duracion: contenido.duracionMinutos, // Corrección: usar duracionMinutos
      nivel: contenido.nivel ?? 'basico', // Corrección: usar nivel
      etiquetas: contenido.tags ?? [], // Corrección: usar tags
      activo: contenido.activo,
      favorito: false,
      fechaPublicacion: contenido.fechaCreacion,
      fechaCreacion: contenido.fechaCreacion,
      semanaGestacionInicio: null,
      semanaGestacionFin: null,
      progreso: null,
      isAvailableOffline: false,
      createdAt: contenido.fechaCreacion,
      updatedAt: contenido.fechaActualizacion, // Corrección: usar fechaActualizacion
    );
  }
  
  // Función para convertir ContenidoModel a ContenidoUnificado
  ContenidoUnificado _convertToContenidoUnificado(ContenidoModelAlias.ContenidoModel contenido) {
    return ContenidoUnificado(
      id: contenido.id,
      titulo: contenido.titulo,
      descripcion: contenido.descripcion,
      categoria: contenido.categoria,
      tipo: contenido.tipo, // Corrección: usar tipo
      urlContenido: contenido.urlContenido ?? contenido.url,
      urlImagen: contenido.imagenUrl, // Corrección: usar urlImagen
      duracionMinutos: contenido.duracion, // Corrección: usar duracionMinutos
      nivel: contenido.nivel, // Corrección: usar nivel
      tags: contenido.etiquetas, // Corrección: usar tags
      fechaCreacion: contenido.fechaCreacion,
      fechaActualizacion: contenido.updatedAt, // Corrección: usar fechaActualizacion
      activo: contenido.activo,
    );
  }
}

