import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/contenido.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../blocs/contenido/contenido_state.dart';
import '../widgets/contenido_card_enhanced.dart';
import '../widgets/reproductores/contenido_reproductor_widget.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class ContenidoDetailPage extends ConsumerStatefulWidget {
  final String contenidoId;
  final Contenido? contenido;

  const ContenidoDetailPage({
    super.key,
    required this.contenidoId,
    this.contenido,
  });

  @override
  ConsumerState<ContenidoDetailPage> createState() => _ContenidoDetailPageState();
}

class _ContenidoDetailPageState extends ConsumerState<ContenidoDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Cargar contenido si no se proporcionó
    if (widget.contenido == null) {
      _loadContenido();
    }
    
    // Registrar vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.registrarVista(widget.contenidoId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadContenido() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      ref.loadContenidoById(widget.contenidoId);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenidoState = ref.watch(contenidoBlocProvider);
    final contenido = widget.contenido ?? contenidoState.selectedContenido;

    // Mostrar loading si está cargando
    if (_isLoading || contenidoState.status == ContenidoStatus.loading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Cargando contenido...'),
      );
    }

    // Mostrar error si hay error
    if (_error != null || contenidoState.status == ContenidoStatus.failure) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: CustomErrorWidget(
          message: _error ?? contenidoState.error ?? 'Error desconocido',
          onRetry: () {
            if (widget.contenido == null) {
              _loadContenido();
            } else {
              setState(() {
                _error = null;
              });
            }
          },
        ),
      );
    }

    // Mostrar contenido si está disponible
    if (contenido == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Contenido no encontrado'),
        ),
        body: const Center(
          child: Text('El contenido solicitado no fue encontrado'),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar con imagen de fondo
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: contenido.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: contenido.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              _getTipoContenidoIcon(contenido.tipo),
                              size: 64,
                              color: Colors.grey[600],
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          _getTipoContenidoIcon(contenido.tipo),
                          size: 64,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
            ),
            actions: [
              // Botón de favorito
              IconButton(
                icon: Icon(
                  contenido.favorito ? Icons.favorite : Icons.favorite_border,
                  color: contenido.favorito ? Colors.red : null,
                ),
                onPressed: () {
                  ref.toggleFavorito(contenido.id);
                },
              ),
              // Botón de compartir
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Implementar funcionalidad de compartir
                },
              ),
            ],
          ),
          
          // Pestañas
          SliverPersistentHeader(
            delegate: _TabDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Contenido'),
                  Tab(text: 'Información'),
                  Tab(text: 'Relacionado'),
                ],
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: Colors.grey,
              ),
            ),
            pinned: true,
          ),
          
          // Contenido de las pestañas
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña de contenido
                _buildContenidoTab(contenido),
                
                // Pestaña de información
                _buildInformacionTab(contenido),
                
                // Pestaña de contenido relacionado
                _buildRelacionadoTab(contenido),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoTab(Contenido contenido) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            contenido.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Descripción
          Text(
            contenido.descripcion,
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: 24),
          
          // Reproductor de contenido
          Expanded(
            child: ContenidoReproductorWidget(
              contenido: contenido,
              onProgressUpdate: (tiempoVisualizado, porcentaje, completado) {
                ref.actualizarProgreso(contenido.id, {
                  'tiempoVisualizado': tiempoVisualizado,
                  'porcentaje': porcentaje,
                  'completado': completado,
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformacionTab(Contenido contenido) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información general
          _buildInfoSection('Información general', [
            _buildInfoRow('Tipo', _getTipoContenidoLabel(contenido.tipo)),
            _buildInfoRow('Categoría', _getCategoriaLabel(contenido.categoria)),
            if (contenido.duracion != null)
              _buildInfoRow('Duración', _formatDuration(contenido.duracion!)),
            _buildInfoRow('Nivel', _getNivelDificultadLabel(contenido.nivel)),
            if (contenido.semanaGestacionInicio != null)
              _buildInfoRow('Semana gestación inicio', '${contenido.semanaGestacionInicio}'),
            if (contenido.semanaGestacionFin != null)
              _buildInfoRow('Semana gestación fin', '${contenido.semanaGestacionFin}'),
            _buildInfoRow('Fecha de creación', _formatDate(contenido.createdAt)),
          ]),
          
          const SizedBox(height: 24),
          
          // Etiquetas
          if (contenido.etiquetas.isNotEmpty) ...[
            const Text(
              'Etiquetas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: contenido.etiquetas.map((etiqueta) {
                return Chip(
                  label: Text(etiqueta),
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Progreso
          if (contenido.progreso != null) ...[
            const Text(
              'Tu progreso',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: contenido.progreso!.porcentaje / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              '${contenido.progreso!.porcentaje.toStringAsFixed(0)}% completado',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRelacionadoTab(Contenido contenido) {
    // Cargar contenidos relacionados
    ref.loadContenidos(
      categoria: contenido.categoria,
      tipo: contenido.tipo,
      nivel: contenido.nivel,
    );
    
    final contenidoState = ref.watch(contenidoBlocProvider);
    
    if (contenidoState.status == ContenidoStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (contenidoState.status == ContenidoStatus.failure) {
      return Center(
        child: Text('Error cargando contenidos relacionados: ${contenidoState.error}'),
      );
    }
    
    final relacionados = contenidoState.contenidos
        .where((c) => c.id != contenido.id)
        .take(5)
        .toList();
    
    if (relacionados.isEmpty) {
      return const Center(
        child: Text('No hay contenidos relacionados'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: relacionados.length,
      itemBuilder: (context, index) {
        final relacionado = relacionados[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ContenidoCardEnhanced(
            contenido: relacionado,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContenidoDetailPage(
                    contenidoId: relacionado.id,
                    contenido: relacionado,
                  ),
                ),
              );
            },
            onToggleFavorito: () {
              ref.toggleFavorito(relacionado.id);
            },
            height: 150,
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  String _getTipoContenidoLabel(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return 'Artículo';
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.podcast:
        return 'Podcast';
      case TipoContenido.infografia:
        return 'Infografía';
      case TipoContenido.guia:
        return 'Guía';
      case TipoContenido.curso:
        return 'Curso';
      case TipoContenido.webinar:
        return 'Webinar';
      case TipoContenido.evaluacion:
        return 'Evaluación';
    }
  }

  IconData _getTipoContenidoIcon(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return Icons.article;
      case TipoContenido.video:
        return Icons.videocam;
      case TipoContenido.podcast:
        return Icons.audiotrack;
      case TipoContenido.infografia:
        return Icons.info;
      case TipoContenido.guia:
        return Icons.book;
      case TipoContenido.curso:
        return Icons.school;
      case TipoContenido.webinar:
        return Icons.laptop;
      case TipoContenido.evaluacion:
        return Icons.quiz;
    }
  }

  String _getCategoriaLabel(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return 'Nutrición';
      case CategoriaContenido.ejercicio:
        return 'Ejercicio';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
      case CategoriaContenido.preparacionParto:
        return 'Preparación Parto';
      case CategoriaContenido.cuidadoBebe:
        return 'Cuidado Bebé';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.desarrolloInfantil:
        return 'Desarrollo Infantil';
      case CategoriaContenido.seguridad:
        return 'Seguridad';
    }
  }

  String _getNivelDificultadLabel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }

  String _formatDuration(int segundos) {
    final minutos = segundos ~/ 60;
    final seg = segundos % 60;
    return '$minutos:${seg.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabDelegate oldDelegate) {
    return false;
  }
}