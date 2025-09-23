import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/contenido_model.dart';
import '../services/contenido_service.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart';

class ContenidoScreen extends ConsumerStatefulWidget {
  const ContenidoScreen({super.key});

  @override
  ConsumerState<ContenidoScreen> createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends ConsumerState<ContenidoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ContenidoModel> _contenidos = [];
  List<ContenidoModel> _contenidosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  CategoriaContenido _categoriaSeleccionada = CategoriaContenido.embarazo;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CategoriaContenido.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    _cargarContenidos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _categoriaSeleccionada = CategoriaContenido.values[_tabController.index];
      });
      _cargarContenidos();
    }
  }

  Future<void> _cargarContenidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Aquí normalmente obtendrías el servicio del provider
      // final contenidoService = ref.read(contenidoServiceProvider);
      // final contenidos = await contenidoService.obtenerContenidosPorCategoria(_categoriaSeleccionada);
      
      // Por ahora simulamos datos
      await Future.delayed(const Duration(seconds: 1));
      
      final contenidosSimulados = _generarContenidosSimulados(_categoriaSeleccionada);
      
      setState(() {
        _contenidos = contenidosSimulados;
        _contenidosFiltrados = contenidosSimulados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ContenidoModel> _generarContenidosSimulados(CategoriaContenido categoria) {
    final contenidos = <ContenidoModel>[];
    
    switch (categoria) {
      case CategoriaContenido.embarazo:
        contenidos.addAll([
          ContenidoModel(
            id: '1',
            titulo: 'Primeros síntomas del embarazo',
            descripcion: 'Aprende a identificar los primeros signos de embarazo',
            categoria: categoria,
            tipo: TipoContenido.video,
            nivel: NivelDificultad.basico,
            urlContenido: 'https://example.com/video1.mp4',
            urlMiniatura: 'https://example.com/thumb1.jpg',
            duracion: 300,
            tags: ['síntomas', 'embarazo temprano'],
            activo: true,
            fechaCreacion: DateTime.now().subtract(const Duration(days: 10)),
          ),
          ContenidoModel(
            id: '2',
            titulo: 'Nutrición durante el embarazo',
            descripcion: 'Guía completa sobre alimentación saludable para embarazadas',
            categoria: categoria,
            tipo: TipoContenido.documento,
            nivel: NivelDificultad.intermedio,
            urlContenido: 'https://example.com/doc1.pdf',
            urlMiniatura: 'https://example.com/thumb2.jpg',
            tags: ['nutrición', 'alimentación', 'salud'],
            activo: true,
            fechaCreacion: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ]);
        break;
      case CategoriaContenido.parto:
        contenidos.addAll([
          ContenidoModel(
            id: '3',
            titulo: 'Preparación para el parto',
            descripcion: 'Todo lo que necesitas saber para prepararte para el parto',
            categoria: categoria,
            tipo: TipoContenido.video,
            nivel: NivelDificultad.intermedio,
            urlContenido: 'https://example.com/video2.mp4',
            urlMiniatura: 'https://example.com/thumb3.jpg',
            duracion: 600,
            tags: ['parto', 'preparación'],
            activo: true,
            fechaCreacion: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ]);
        break;
      case CategoriaContenido.lactancia:
        contenidos.addAll([
          ContenidoModel(
            id: '4',
            titulo: 'Técnicas de lactancia materna',
            descripcion: 'Aprende las mejores técnicas para una lactancia exitosa',
            categoria: categoria,
            tipo: TipoContenido.video,
            nivel: NivelDificultad.basico,
            urlContenido: 'https://example.com/video3.mp4',
            urlMiniatura: 'https://example.com/thumb4.jpg',
            duracion: 450,
            tags: ['lactancia', 'técnicas'],
            activo: true,
            fechaCreacion: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);
        break;
      case CategoriaContenido.cuidadoBebe:
        contenidos.addAll([
          ContenidoModel(
            id: '5',
            titulo: 'Cuidados básicos del recién nacido',
            descripcion: 'Guía esencial para el cuidado de tu bebé',
            categoria: categoria,
            tipo: TipoContenido.interactivo,
            nivel: NivelDificultad.basico,
            urlContenido: 'https://example.com/interactive1.html',
            urlMiniatura: 'https://example.com/thumb5.jpg',
            tags: ['recién nacido', 'cuidados'],
            activo: true,
            fechaCreacion: DateTime.now(),
          ),
        ]);
        break;
      case CategoriaContenido.saludMental:
        contenidos.addAll([
          ContenidoModel(
            id: '6',
            titulo: 'Manejo del estrés durante el embarazo',
            descripcion: 'Técnicas de relajación y manejo del estrés',
            categoria: categoria,
            tipo: TipoContenido.audio,
            nivel: NivelDificultad.basico,
            urlContenido: 'https://example.com/audio1.mp3',
            urlMiniatura: 'https://example.com/thumb6.jpg',
            duracion: 900,
            tags: ['estrés', 'relajación', 'bienestar'],
            activo: true,
            fechaCreacion: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ]);
        break;
    }
    
    return contenidos;
  }

  void _filtrarContenidos(String query) {
    setState(() {
      _busqueda = query;
      if (query.isEmpty) {
        _contenidosFiltrados = _contenidos;
      } else {
        _contenidosFiltrados = _contenidos.where((contenido) {
          return contenido.titulo.toLowerCase().contains(query.toLowerCase()) ||
                 contenido.descripcion.toLowerCase().contains(query.toLowerCase()) ||
                 contenido.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido Educativo'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _mostrarBusqueda(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: CategoriaContenido.values.map((categoria) {
            return Tab(
              text: _obtenerNombreCategoria(categoria),
              icon: Icon(_obtenerIconoCategoria(categoria)),
            );
          }).toList(),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando contenidos...')
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _cargarContenidos,
                )
              : TabBarView(
                  controller: _tabController,
                  children: CategoriaContenido.values.map((categoria) {
                    return _buildContenidoList();
                  }).toList(),
                ),
    );
  }

  Widget _buildContenidoList() {
    if (_contenidosFiltrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _busqueda.isEmpty
                  ? 'No hay contenidos disponibles'
                  : 'No se encontraron contenidos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarContenidos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _contenidosFiltrados.length,
        itemBuilder: (context, index) {
          final contenido = _contenidosFiltrados[index];
          return _buildContenidoCard(contenido);
        },
      ),
    );
  }

  Widget _buildContenidoCard(ContenidoModel contenido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => _abrirContenido(contenido),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura
            if (contenido.urlMiniatura != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: contenido.urlMiniatura!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Icon(
                      _obtenerIconoTipo(contenido.tipo),
                      size: 64,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y tipo
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contenido.titulo,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildTipoChip(contenido.tipo),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Descripción
                  Text(
                    contenido.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Información adicional
                  Row(
                    children: [
                      _buildNivelChip(contenido.nivel),
                      const SizedBox(width: 8),
                      if (contenido.duracion != null)
                        _buildDuracionChip(contenido.duracion!),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tags
                  if (contenido.tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: contenido.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipoChip(TipoContenido tipo) {
    final color = _obtenerColorTipo(tipo);
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _obtenerIconoTipo(tipo),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            _obtenerNombreTipo(tipo),
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildNivelChip(NivelDificultad nivel) {
    final color = _obtenerColorNivel(nivel);
    return Chip(
      label: Text(
        _obtenerNombreNivel(nivel),
        style: TextStyle(
          fontSize: 12,
          color: color,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildDuracionChip(int duracionSegundos) {
    final minutos = (duracionSegundos / 60).round();
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time, size: 16),
          const SizedBox(width: 4),
          Text(
            '${minutos}min',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _mostrarBusqueda(BuildContext context) {
    showSearch(
      context: context,
      delegate: ContenidoSearchDelegate(
        contenidos: _contenidos,
        onSearch: _filtrarContenidos,
      ),
    );
  }

  void _abrirContenido(ContenidoModel contenido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenidoDetailScreen(contenido: contenido),
      ),
    );
  }

  String _obtenerNombreCategoria(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.embarazo:
        return 'Embarazo';
      case CategoriaContenido.parto:
        return 'Parto';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.cuidadoBebe:
        return 'Cuidado Bebé';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
    }
  }

  IconData _obtenerIconoCategoria(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.embarazo:
        return Icons.pregnant_woman;
      case CategoriaContenido.parto:
        return Icons.child_care;
      case CategoriaContenido.lactancia:
        return Icons.baby_changing_station;
      case CategoriaContenido.cuidadoBebe:
        return Icons.child_friendly;
      case CategoriaContenido.saludMental:
        return Icons.psychology;
    }
  }

  IconData _obtenerIconoTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return Icons.play_circle;
      case TipoContenido.audio:
        return Icons.audiotrack;
      case TipoContenido.imagen:
        return Icons.image;
      case TipoContenido.documento:
        return Icons.description;
      case TipoContenido.interactivo:
        return Icons.touch_app;
    }
  }

  Color _obtenerColorTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return Colors.red;
      case TipoContenido.audio:
        return Colors.purple;
      case TipoContenido.imagen:
        return Colors.green;
      case TipoContenido.documento:
        return Colors.blue;
      case TipoContenido.interactivo:
        return Colors.orange;
    }
  }

  String _obtenerNombreTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.audio:
        return 'Audio';
      case TipoContenido.imagen:
        return 'Imagen';
      case TipoContenido.documento:
        return 'Documento';
      case TipoContenido.interactivo:
        return 'Interactivo';
    }
  }

  Color _obtenerColorNivel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return Colors.green;
      case NivelDificultad.intermedio:
        return Colors.orange;
      case NivelDificultad.avanzado:
        return Colors.red;
    }
  }

  String _obtenerNombreNivel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }
}

class ContenidoSearchDelegate extends SearchDelegate<String> {
  final List<ContenidoModel> contenidos;
  final Function(String) onSearch;

  ContenidoSearchDelegate({
    required this.contenidos,
    required this.onSearch,
  });

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final sugerencias = contenidos.where((contenido) {
      return contenido.titulo.toLowerCase().contains(query.toLowerCase()) ||
             contenido.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();

    return ListView.builder(
      itemCount: sugerencias.length,
      itemBuilder: (context, index) {
        final contenido = sugerencias[index];
        return ListTile(
          title: Text(contenido.titulo),
          subtitle: Text(contenido.descripcion),
          onTap: () {
            query = contenido.titulo;
            showResults(context);
          },
        );
      },
    );
  }
}

class ContenidoDetailScreen extends StatefulWidget {
  final ContenidoModel contenido;

  const ContenidoDetailScreen({
    super.key,
    required this.contenido,
  });

  @override
  State<ContenidoDetailScreen> createState() => _ContenidoDetailScreenState();
}

class _ContenidoDetailScreenState extends State<ContenidoDetailScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.contenido.tipo == TipoContenido.video) {
      _initializeVideoPlayer();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.network(widget.contenido.urlContenido);
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contenido.titulo),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reproductor de contenido
            _buildContentPlayer(),
            
            // Información del contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.contenido.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.contenido.descripcion,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información adicional
                  _buildInfoSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  if (widget.contenido.tags.isNotEmpty)
                    _buildTagsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPlayer() {
    switch (widget.contenido.tipo) {
      case TipoContenido.video:
        if (_chewieController != null) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: _chewieController!),
          );
        }
        return Container(
          height: 200,
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
        
      case TipoContenido.imagen:
        return CachedNetworkImage(
          imageUrl: widget.contenido.urlContenido,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          ),
        );
        
      default:
        return Container(
          height: 200,
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _obtenerIconoTipo(widget.contenido.tipo),
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'Toca para abrir',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Categoría', _obtenerNombreCategoria(widget.contenido.categoria)),
            _buildInfoRow('Tipo', _obtenerNombreTipo(widget.contenido.tipo)),
            _buildInfoRow('Nivel', _obtenerNombreNivel(widget.contenido.nivel)),
            if (widget.contenido.duracion != null)
              _buildInfoRow('Duración', '${(widget.contenido.duracion! / 60).round()} minutos'),
            _buildInfoRow('Fecha', _formatearFecha(widget.contenido.fechaCreacion)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etiquetas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.contenido.tags.map((tag) {
            return Chip(
              label: Text(tag),
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _obtenerIconoTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return Icons.play_circle;
      case TipoContenido.audio:
        return Icons.audiotrack;
      case TipoContenido.imagen:
        return Icons.image;
      case TipoContenido.documento:
        return Icons.description;
      case TipoContenido.interactivo:
        return Icons.touch_app;
    }
  }

  String _obtenerNombreCategoria(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.embarazo:
        return 'Embarazo';
      case CategoriaContenido.parto:
        return 'Parto';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.cuidadoBebe:
        return 'Cuidado del Bebé';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
    }
  }

  String _obtenerNombreTipo(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.audio:
        return 'Audio';
      case TipoContenido.imagen:
        return 'Imagen';
      case TipoContenido.documento:
        return 'Documento';
      case TipoContenido.interactivo:
        return 'Interactivo';
    }
  }

  String _obtenerNombreNivel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}