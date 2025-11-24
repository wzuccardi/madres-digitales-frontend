import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';
import 'contenido_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:madres_digitales_flutter_new/features/contenido/data/datasources/contenido_remote_datasource.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
final contenidosProvider = Provider((ref) => null);

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
              setState(() {});
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
              _buildListaFavoritos(ref),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          AppLogger.error('Error cargando contenidos', error: error);
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
                    setState(() {});
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
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contenidos.length,
        itemBuilder: (context, index) {
          final contenido = contenidos[index];
          return _buildContenidoCard(contenido, key: ValueKey('contenido_${contenido.id}'));
        },
      ),
    );
  }

  Widget _buildContenidoCard(ContenidoUnificado contenido, {Key? key}) {
    return Card(
      key: key,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _abrirContenido(contenido),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: contenido.miniaturaUrl != null && contenido.miniaturaUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: contenido.miniaturaUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => ColoredBox(
                        color: Colors.grey[300]!,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => ColoredBox(
                        color: Colors.grey[300]!,
                        child: Center(
                          child: Icon(
                          TipoContenido.fromString(contenido.tipo).icono,
                            size: 48,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : ColoredBox(
                      color: Colors.grey[300]!,
                      child: Center(
                        child: Icon(
                          TipoContenido.fromString(contenido.tipo).icono,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contenido.titulo,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getNombreCategoria(contenido.categoria),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaFavoritos(WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    final usuarioId = auth.user?.id;
    if (usuarioId == null || usuarioId.isEmpty) {
      return const Center(child: Text('Inicia sesión para ver favoritos'));
    }
    final api = ref.read(apiServiceProvider);
    final remote = ContenidoRemoteDataSourceImpl(apiService: api);
    return FutureBuilder<List<ContenidoUnificado>>(
      future: remote.getFavoritos(usuarioId).then((list) => list
          .map((m) => ContenidoUnificado(
                id: m.id,
                titulo: m.titulo,
                descripcion: m.descripcion,
                categoria: m.categoria,
                tipo: m.tipo,
                urlContenido: m.url,
                urlImagen: m.thumbnailUrl,
                duracionMinutos: m.duracion,
                nivel: m.nivel,
                tags: m.etiquetas,
                fechaCreacion: m.createdAt,
                fechaActualizacion: m.updatedAt,
                activo: m.activo,
              ))
          .toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando favoritos'));
        }
        final contenidos = snapshot.data ?? const [];
        return _buildListaContenido(contenidos);
      },
    );
  }

  

  void _abrirContenido(ContenidoUnificado contenido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenidoDetailScreen(contenido: contenido),
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
                  label: Text(TipoContenido.fromString(tipo).nombre),
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
