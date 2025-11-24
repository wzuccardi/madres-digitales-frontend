import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:madres_digitales_flutter_new/data/models/contenido_unificado.dart';
import 'package:madres_digitales_flutter_new/core/theme/app_theme.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/loading_widget.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/error_widget.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/players/multimedia_player.dart';
import 'package:madres_digitales_flutter_new/data/services/contenido_progreso_service.dart';
import 'contenido_crud_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';
import 'contenido_list_simple_page.dart';
// duplicate import removed


// Hot reload trigger - 2025-10-24

// Enum local para categorías de contenido
enum CategoriaContenido {
  nutricion,
  cuidadoPrenatal,
  signosAlarma,
  lactancia,
  parto,
  posparto,
  planificacion,
  saludMental,
  ejercicio,
  higiene,
  derechos,
  otros;
}

class ContenidoSearchDelegate extends SearchDelegate<ContenidoUnificado?> {
  ContenidoSearchDelegate({
    required this.onSearch,
    required this.onOpen,
    List<ContenidoUnificado>? initialResults,
  }) : _initial = initialResults ?? const [];
  final Future<List<ContenidoUnificado>> Function(String query) onSearch;
  final void Function(ContenidoUnificado contenido) onOpen;
  final List<ContenidoUnificado> _initial;

  @override
  String get searchFieldLabel => 'Buscar contenidos';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
        tooltip: 'Limpiar',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: 'Volver',
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildList(context, _initial);
    }
    return FutureBuilder<List<ContenidoUnificado>>(
      future: onSearch(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final results = snapshot.data ?? const [];
        if (results.isEmpty) {
          return const Center(child: Text('No se encontraron contenidos'));
        }
        return _buildList(context, results);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return _buildList(context, _initial);
    }
    return buildResults(context);
  }

  Widget _buildList(BuildContext context, List<ContenidoUnificado> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final contenido = items[index];
        return ListTile(
          leading: Icon(obtenerIconoTipoString(contenido.tipo)),
          title: Text(contenido.titulo),
          subtitle: Text(obtenerNombreCategoriaString(contenido.categoria)),
          onTap: () => close(context, contenido),
          trailing: IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () {
              onOpen(contenido);
              close(context, contenido);
            },
          ),
        );
      },
    );
  }
}
// --- String helpers as top-level functions ---
String obtenerNombreCategoriaString(String categoria) {
  switch (categoria.toUpperCase()) {
    case 'EMBARAZO':
      return 'Embarazo';
    case 'PARTO':
      return 'Parto';
    case 'POSPARTO':
      return 'Posparto';
    case 'LACTANCIA':
      return 'Lactancia';
    case 'NUTRICION':
    case 'NUTRICIÓN':
      return 'Nutrición';
    case 'EJERCICIO':
      return 'Ejercicio';
    case 'SALUD_MENTAL':
    case 'SALUDMENTAL':
      return 'Salud Mental';
    case 'CUIDADO_BEBE':
    case 'CUIDADOBEBE':
      return 'Cuidado del Bebé';
    case 'PLANIFICACION_FAMILIAR':
    case 'PLANIFICACIONFAMILIAR':
      return 'Planificación Familiar';
    case 'EMERGENCIAS':
      return 'Emergencias';
    case 'EDUCACION':
    case 'EDUCACIÓN':
      return 'Educación';
    case 'CUIDADO_PRENATAL':
    case 'CUIDADOPRENATAL':
      return 'Cuidado Prenatal';
    default:
      return categoria;
  }
}

String obtenerNombreTipoString(String tipo) {
  switch (tipo.toUpperCase()) {
    case 'ARTICULO':
      return 'Artículo';
    case 'VIDEO':
      return 'Video';
    case 'AUDIO':
      return 'Audio';
    case 'INFOGRAFIA':
    case 'INFOGRAFÍA':
      return 'Infografía';
    case 'GUIA':
    case 'GUÍA':
      return 'Guía';
    case 'CHECKLIST':
      return 'Checklist';
    default:
      return tipo;
  }
}

String obtenerNombreNivelString(String? nivel) {
  if (nivel == null) return 'No especificado';
  switch (nivel.toUpperCase()) {
    case 'BASICO':
    case 'BÁSICO':
      return 'Básico';
    case 'INTERMEDIO':
      return 'Intermedio';
    case 'AVANZADO':
      return 'Avanzado';
    case 'PRINCIPIANTE':
      return 'Principiante';
    case 'EXPERTO':
      return 'Experto';
    default:
      return nivel;
  }
}

IconData obtenerIconoTipoString(String tipo) {
  return TipoContenido.fromString(tipo.toLowerCase()).icono;
}

Widget buildTipoChipString(String tipo) {
  return Chip(
    label: Text(obtenerNombreTipoString(tipo)),
    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
  );
}

Widget buildNivelChipString(String? nivel) {
  return Chip(
    label: Text(obtenerNombreNivelString(nivel)),
    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
  );
}

Widget buildDuracionChip(int duracion) {
  return Chip(
    label: Text('${(duracion / 60).round()} min'),
    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
  );
}

void abrirContenido(BuildContext context, ContenidoUnificado contenido) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ContenidoDetailScreen(contenido: contenido),
    ),
  );
}

class ContenidoScreen extends ConsumerStatefulWidget {
  const ContenidoScreen({super.key});

  @override
  ConsumerState<ContenidoScreen> createState() => _ContenidoScreenState();
}

class _ContenidoScreenState extends ConsumerState<ContenidoScreen> with SingleTickerProviderStateMixin {
  // Helper for tab icon
  IconData _obtenerIconoCategoria(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return Icons.restaurant;
      case CategoriaContenido.cuidadoPrenatal:
        return Icons.pregnant_woman;
      case CategoriaContenido.signosAlarma:
        return Icons.warning;
      case CategoriaContenido.lactancia:
        return Icons.baby_changing_station;
      case CategoriaContenido.parto:
        return Icons.local_hospital;
      case CategoriaContenido.posparto:
        return Icons.healing;
      case CategoriaContenido.planificacion:
        return Icons.calendar_today;
      case CategoriaContenido.saludMental:
        return Icons.psychology;
      case CategoriaContenido.ejercicio:
        return Icons.fitness_center;
      case CategoriaContenido.higiene:
        return Icons.clean_hands;
      case CategoriaContenido.derechos:
        return Icons.gavel;
      case CategoriaContenido.otros:
        return Icons.more_horiz;
    }
  }

  late TabController _tabController;
  List<ContenidoUnificado> _contenidosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  CategoriaContenido _categoriaSeleccionada = CategoriaContenido.nutricion;
  final String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: CategoriaContenido.values.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
    // Cargar contenidos después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarContenidos();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  // Helper for tab label
  String _obtenerNombreCategoria(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return 'Nutrición';
      case CategoriaContenido.cuidadoPrenatal:
        return 'Cuidado Prenatal';
      case CategoriaContenido.signosAlarma:
        return 'Signos de Alarma';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.parto:
        return 'Parto';
      case CategoriaContenido.posparto:
        return 'Posparto';
      case CategoriaContenido.planificacion:
        return 'Planificación';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
      case CategoriaContenido.ejercicio:
        return 'Ejercicio';
      case CategoriaContenido.higiene:
        return 'Higiene';
      case CategoriaContenido.derechos:
        return 'Derechos';
      case CategoriaContenido.otros:
        return 'Otros';
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Usar addPostFrameCallback para evitar setState durante build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _categoriaSeleccionada = CategoriaContenido.values[_tabController.index];
          });
          _cargarContenidos();
        }
      });
    }
  }

  Future<void> _cargarContenidos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final contenidoService = ref.read(contenidoServiceProvider);
      final contenidos = await contenidoService.getContenidosByCategoria(_categoriaSeleccionada.name);
      setState(() {
        _contenidosFiltrados = contenidos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Eliminada función de mocks

  

  void _mostrarBusqueda(BuildContext context) {
    final contenidoService = ref.read(contenidoServiceProvider);
    final navigator = Navigator.of(context);
    showSearch<ContenidoUnificado?>(
      context: context,
      delegate: ContenidoSearchDelegate(
        onSearch: (q) => contenidoService.searchContenidos(q, categoria: _categoriaSeleccionada.name),
        onOpen: (c) => _abrirContenidoConNavigator(navigator, c),
        initialResults: _contenidosFiltrados,
      ),
    ).then((value) {
      if (value != null) _abrirContenidoConNavigator(navigator, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userRoleLower = authState.user?.role.toLowerCase();

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
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              try {
                context.go(AppConstants.contenidoListRoute);
              } catch (_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContenidoListSimplePage()),
                );
              }
            },
            tooltip: 'Lista simple (Presentación)',
          ),
          if (userRoleLower == AppConstants.adminRole ||
              userRoleLower == AppConstants.superAdminRole)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ContenidoCrudScreen(),
                  ),
                ).then((_) {
                  _cargarContenidos();
                });
              },
              tooltip: 'Administrar Contenidos (CRUD Completo)',
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
      floatingActionButton: (userRoleLower == AppConstants.adminRole ||
              userRoleLower == AppConstants.superAdminRole)
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContenidoCrudScreen()),
                );
                if (result == true) _cargarContenidos();
              },
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Contenido'),
            )
          : null,
    );
  }

  void _abrirContenidoConNavigator(NavigatorState navigator, ContenidoUnificado contenido) {
    navigator.push(
      MaterialPageRoute(
        builder: (context) => ContenidoDetailScreen(contenido: contenido),
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
          return _buildContenidoCard(contenido, context);
        },
      ),
    );
  }

  Widget _buildContenidoCard(ContenidoUnificado contenido, BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => abrirContenido(context, contenido),
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
                            obtenerIconoTipoString(contenido.tipo),
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
                          obtenerIconoTipoString(contenido.tipo),
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
                    obtenerNombreCategoriaString(contenido.categoria),
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

  Color obtenerColorTipo(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VIDEO':
        return Colors.red;
      case 'AUDIO':
        return Colors.purple;
      case 'IMAGEN':
        return Colors.green;
      case 'DOCUMENTO':
        return Colors.blue;
      case 'INTERACTIVO':
        return Colors.orange;
      case 'ARTICULO':
      case 'ARTÍCULO':
        return Colors.teal;
      case 'INFOGRAFIA':
      case 'INFOGRAFÍA':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class ContenidoDetailScreen extends ConsumerWidget {
  const ContenidoDetailScreen({super.key, required this.contenido});
  final ContenidoUnificado contenido;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(
        title: Text(contenido.titulo),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reproductor de contenido
            _buildContentPlayer(context, ref),
            
            // Información del contenido
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contenido.titulo,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    contenido.descripcion ?? '', // Corrección: descripcion es nullable
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Información adicional
                  _buildInfoSection(context, contenido),
                  
                  const SizedBox(height: 16),
                  
                  // Tags
                  if (contenido.tags?.isNotEmpty ?? false)
                    _buildTagsSection(context, contenido),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPlayer(BuildContext context, WidgetRef ref) {
    final apiService = ref.read(apiServiceProvider);
    final progresoService = ContenidoProgresoService(apiService);
    
    return MultimediaPlayer(
      contenido: contenido,
      progresoService: progresoService,
      onProgressUpdate: (duration) async {
        // Actualizar progreso cada 30 segundos
        if (duration.inSeconds % 30 == 0) {
          final totalDuration = contenido.duracionMinutos ?? 300; // Corrección: usar duracionMinutos
          final porcentaje = ((duration.inSeconds / totalDuration) * 100).round();
          
          await progresoService.actualizarProgreso(
            contenidoId: contenido.id,
            porcentajeProgreso: porcentaje.clamp(0, 100),
            tiempoVisto: duration.inSeconds,
          );
        }
      },
      onCompleted: () async {
        // Marcar como completado
        await progresoService.actualizarProgreso(
          contenidoId: contenido.id,
          porcentajeProgreso: 100,
          completado: true,
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Contenido completado!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, ContenidoUnificado contenido) {
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
            _buildInfoRow('Categoría', obtenerNombreCategoriaString(contenido.categoria)),
            _buildInfoRow('Tipo', obtenerNombreTipoString(contenido.tipo)), // Corrección: usar tipo
            _buildInfoRow('Nivel', obtenerNombreNivelString(contenido.nivel)), // Corrección: usar nivel
            if (contenido.duracionMinutos != null) // Corrección: usar duracionMinutos
              _buildInfoRow('Duración', '${(contenido.duracionMinutos! / 60).round()} minutos'),
            _buildInfoRow('Fecha', _formatearFecha(contenido.fechaActualizacion)), // Corrección: usar fechaActualizacion
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

  Widget _buildTagsSection(BuildContext context, ContenidoUnificado contenido) {
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
          children: contenido.tags?.map((tag) { // Corrección: usar tags
            return Chip(
              label: Text(tag),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            );
          }).toList() ?? [],
        ),
      ],
    );
  }


  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}


