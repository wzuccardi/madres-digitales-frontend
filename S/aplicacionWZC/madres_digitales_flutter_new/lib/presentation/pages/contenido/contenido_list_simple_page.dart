import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/pages/contenido/contenido_screen.dart';

class ContenidoListSimplePage extends ConsumerStatefulWidget {
  const ContenidoListSimplePage({super.key});

  @override
  ConsumerState<ContenidoListSimplePage> createState() => _ContenidoListSimplePageState();
}

class _ContenidoListSimplePageState extends ConsumerState<ContenidoListSimplePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  List<ContenidoUnificado> _contenidos = [];
  String? _filtroTipo;
  String? _filtroCategoria;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarContenidos(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _cargarContenidos({bool reset = false}) async {
    if (reset) {
      setState(() {
        _contenidos = [];
      });
    }

    final service = ref.read(contenidoServiceProvider);
    final nuevos = await service.getAllContenidos();
    setState(() {
      _contenidos = nuevos;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore) {
        setState(() => _isLoadingMore = true);
        setState(() => _isLoadingMore = false);
      }
    }
  }

  List<ContenidoUnificado> _filtrar(List<ContenidoUnificado> contenidos) {
    var list = contenidos;
    if (_filtroTipo != null) {
      list = list.where((c) => c.tipo == _filtroTipo).toList();
    }
    if (_filtroCategoria != null) {
      list = list.where((c) => c.categoria == _filtroCategoria).toList();
    }
    if (_busqueda.isNotEmpty) {
      list = list.where((c) => c.titulo.toLowerCase().contains(_busqueda.toLowerCase()) ||
          (c.descripcion?.toLowerCase().contains(_busqueda.toLowerCase()) ?? false)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtrados = _filtrar(_contenidos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido (Presentación)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final query = await showDialog<String>(
                context: context,
                builder: (context) {
                  final controller = TextEditingController(text: _busqueda);
                  return AlertDialog(
                    title: const Text('Buscar contenido'),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                      TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Buscar')),
                    ],
                  );
                },
              );
              if (query != null) setState(() => _busqueda = query);
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarContenidos(reset: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _cargarContenidos(reset: true),
        child: filtrados.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_books, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('No hay contenido disponible'),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes intentar sincronizar el contenido desde el servidor',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            final sync = ref.read(syncServiceProvider);
                            await sync.sync();
                            await _cargarContenidos(reset: true);
                          } catch (_) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Error sincronizando contenido')),
                            );
                          }
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Sincronizar Contenido'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: filtrados.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isLoadingMore && index == filtrados.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final c = filtrados[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () => _abrirContenido(c),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c.urlImagen != null && c.urlImagen!.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: c.urlImagen!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(c.descripcion ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 8),
                                Row(children: [
                                  _buildChip(_labelTipo(c.tipo), _colorTipo(c.tipo)),
                                  const SizedBox(width: 8),
                                  _buildChip(_labelCategoria(c.categoria), Colors.blue),
                                  const Spacer(),
                                  if (c.duracionMinutos != null)
                                    Text('${c.duracionMinutos} min', style: TextStyle(color: Colors.grey[600])),
                                ]),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFiltros(),
        icon: const Icon(Icons.filter_list),
        label: const Text('Filtros'),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipo de contenido'),
            Wrap(
              spacing: 8,
              children: ['video', 'audio', 'documento', 'imagen', 'articulo', 'infografia'].map((tipo) {
                return FilterChip(
                  label: Text(_labelTipo(tipo)),
                  selected: _filtroTipo == tipo,
                  onSelected: (selected) {
                    setState(() => _filtroTipo = selected ? tipo : null);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Categoría'),
            Wrap(
              spacing: 8,
              children: ['nutricion','cuidado_prenatal','signos_alarma','lactancia','parto','posparto','planificacion','salud_mental','ejercicio','derechos']
                  .map((cat) {
                return FilterChip(
                  label: Text(_labelCategoria(cat)),
                  selected: _filtroCategoria == cat,
                  onSelected: (selected) {
                    setState(() => _filtroCategoria = selected ? cat : null);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() { _filtroTipo = null; _filtroCategoria = null; });
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirContenido(ContenidoUnificado contenido) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContenidoDetailScreen(contenido: contenido)),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'video': return 'Video';
      case 'audio': return 'Audio';
      case 'documento': return 'Documento';
      case 'imagen': return 'Imagen';
      case 'articulo': return 'Artículo';
      case 'infografia': return 'Infografía';
      default: return 'Otro';
    }
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'video': return Colors.red;
      case 'audio': return Colors.purple;
      case 'documento': return Colors.blue;
      case 'imagen': return Colors.green;
      case 'articulo': return Colors.orange;
      case 'infografia': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _labelCategoria(String categoria) {
    switch (categoria) {
      case 'nutricion': return 'Nutrición';
      case 'cuidado_prenatal': return 'Cuidado Prenatal';
      case 'signos_alarma': return 'Signos de Alarma';
      case 'lactancia': return 'Lactancia';
      case 'parto': return 'Parto';
      case 'posparto': return 'Posparto';
      case 'planificacion': return 'Planificación';
      case 'salud_mental': return 'Salud Mental';
      case 'ejercicio': return 'Ejercicio';
      case 'derechos': return 'Derechos';
      default: return 'Otros';
    }
  }
}
