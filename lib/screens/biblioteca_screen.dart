import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/contenido_unificado.dart';
import '../providers/contenido_provider.dart';
import '../utils/logger.dart';
import 'reproductor_screen.dart';

/// Pantalla de biblioteca de contenido educativo
class BibliotecaScreen extends ConsumerStatefulWidget {
  const BibliotecaScreen({super.key});

  @override
  ConsumerState<BibliotecaScreen> createState() => _BibliotecaScreenState();
}

class _BibliotecaScreenState extends ConsumerState<BibliotecaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String? _filtroTipo;
  String? _filtroCategoria;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener contenidos desde el provider
    final contenidosAsync = ref.watch(contenidosProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca Educativa'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Destacado'),
            Tab(icon: Icon(Icons.library_books), text: 'Todo'),
            Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(contenidosProvider);
            },
          ),
        ],
      ),
      body: contenidosAsync.when(
        data: (contenidos) {
          // Filtrar destacados
          final destacados = contenidos.where((c) => c.destacado == true).toList();
          
          return TabBarView(
            controller: _tabController,
            children: [
              _buildListaContenido(destacados),
              _buildListaContenido(_contenidosFiltrados(contenidos)),
              _buildListaContenido([]), // TODO: Favoritos
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          appLogger.error('Error cargando contenidos', error: error, stackTrace: stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 80, color: Colors.red[300]),
                const SizedBox(height: 16),
                const Text(
                  'Error cargando contenido',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(contenidosProvider);
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<ContenidoUnificado> _contenidosFiltrados(List<ContenidoUnificado> contenidos) {
    var filtrados = contenidos;

    if (_filtroTipo != null) {
      filtrados = filtrados.where((c) => c.tipo == _filtroTipo).toList();
    }

    if (_filtroCategoria != null) {
      filtrados = filtrados.where((c) => c.categoria == _filtroCategoria).toList();
    }

    return filtrados;
  }

  Widget _buildListaContenido(List<ContenidoUnificado> contenidos) {
    if (contenidos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No hay contenido disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(contenidosProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contenidos.length,
        itemBuilder: (context, index) {
          final contenido = contenidos[index];
          return _buildContenidoCard(contenido);
        },
      ),
    );
  }

  Widget _buildContenidoCard(ContenidoUnificado contenido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _abrirContenido(contenido),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura
            if (contenido.urlImagen != null && contenido.urlImagen!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  contenido.urlImagen!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                ),
              )
            else
              Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    _getIconoTipo(contenido.tipo),
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    contenido.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    contenido.descripcion ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Metadata
                  Row(
                    children: [
                      _buildChip(
                        _getNombreTipo(contenido.tipo),
                        _getColorTipo(contenido.tipo),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        _getNombreCategoria(contenido.categoria),
                        Colors.blue,
                      ),
                      const Spacer(),
                      if (contenido.duracionMinutos != null)
                        Text(
                          '${contenido.duracionMinutos} min',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Estadísticas
                  Row(
                    children: [
                      Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('0', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '0.0',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _abrirContenido(ContenidoUnificado contenido) {
    // Abrir reproductor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorScreen(contenido: contenido),
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
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de contenido:'),
            Wrap(
              spacing: 8,
              children: ['video', 'audio', 'documento', 'imagen', 'articulo', 'infografia'].map((tipo) {
                return FilterChip(
                  label: Text(_getNombreTipo(tipo)),
                  selected: _filtroTipo == tipo,
                  onSelected: (selected) {
                    setState(() {
                      _filtroTipo = selected ? tipo : null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Categoría:'),
            Wrap(
              spacing: 8,
              children: [
                'nutricion', 'cuidado_prenatal', 'signos_alarma', 'lactancia', 
                'parto', 'posparto', 'planificacion', 'salud_mental', 
                'ejercicio', 'derechos'
              ].map((categoria) {
                return FilterChip(
                  label: Text(_getNombreCategoria(categoria)),
                  selected: _filtroCategoria == categoria,
                  onSelected: (selected) {
                    setState(() {
                      _filtroCategoria = selected ? categoria : null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filtroTipo = null;
                  _filtroCategoria = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.audiotrack;
      case 'documento':
        return Icons.description;
      case 'imagen':
        return Icons.image;
      case 'articulo':
        return Icons.article;
      case 'infografia':
        return Icons.info;
      default:
        return Icons.library_books;
    }
  }

  String _getNombreTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'documento':
        return 'Documento';
      case 'imagen':
        return 'Imagen';
      case 'articulo':
        return 'Artículo';
      case 'infografia':
        return 'Infografía';
      default:
        return 'Otro';
    }
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'documento':
        return Colors.blue;
      case 'imagen':
        return Colors.green;
      case 'articulo':
        return Colors.orange;
      case 'infografia':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getNombreCategoria(String categoria) {
    switch (categoria) {
      case 'nutricion':
        return 'Nutrición';
      case 'cuidado_prenatal':
        return 'Cuidado Prenatal';
      case 'signos_alarma':
        return 'Signos de Alarma';
      case 'lactancia':
        return 'Lactancia';
      case 'parto':
        return 'Parto';
      case 'posparto':
        return 'Posparto';
      case 'planificacion':
        return 'Planificación';
      case 'salud_mental':
        return 'Salud Mental';
      case 'ejercicio':
        return 'Ejercicio';
      case 'higiene':
        return 'Higiene';
      case 'derechos':
        return 'Derechos';
      case 'otros':
        return 'Otros';
      default:
        return 'Otro';
    }
  }
}
