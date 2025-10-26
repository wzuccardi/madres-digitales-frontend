import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/contenido_unificado.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../providers/service_providers.dart';
import '../widgets/multimedia_player.dart';
import '../services/contenido_progreso_service.dart';
import '../services/auth_service.dart';
import 'contenido_crud_screen.dart';

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
  switch (tipo.toUpperCase()) {
    case 'VIDEO':
      return Icons.videocam;
    case 'AUDIO':
      return Icons.audiotrack;
    case 'IMAGEN':
      return Icons.image;
    case 'DOCUMENTO':
      return Icons.description;
    case 'INTERACTIVO':
      return Icons.touch_app;
    case 'ARTICULO':
    case 'ARTÍCULO':
      return Icons.article;
    case 'INFOGRAFIA':
    case 'INFOGRAFÍA':
      return Icons.info;
    default:
      return Icons.help;
  }
}

Widget buildTipoChipString(String tipo) {
  return Chip(
    label: Text(obtenerNombreTipoString(tipo)),
    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
  );
}

Widget buildNivelChipString(String? nivel) {
  return Chip(
    label: Text(obtenerNombreNivelString(nivel)),
    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
  );
}

Widget buildDuracionChip(int duracion) {
  return Chip(
    label: Text('${(duracion / 60).round()} min'),
    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
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
  List<ContenidoUnificado> _contenidos = [];
  List<ContenidoUnificado> _contenidosFiltrados = [];
  bool _isLoading = true;
  String? _error;
  CategoriaContenido _categoriaSeleccionada = CategoriaContenido.nutricion;
  String _busqueda = '';

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
      // Esperar a que el servicio esté disponible
      final contenidoService = await ref.read(contenidoServiceProvider.future);
      final contenidos = await contenidoService.getContenidosByCategoria(_categoriaSeleccionada.name);
      setState(() {
        _contenidos = contenidos;
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

  void _filtrarContenidos(String query) {
    setState(() {
      _busqueda = query;
      if (query.isEmpty) {
        _contenidosFiltrados = _contenidos;
      } else {
        _contenidosFiltrados = _contenidos.where((contenido) {
          return contenido.titulo.toLowerCase().contains(query.toLowerCase()) ||
                  (contenido.descripcion?.toLowerCase().contains(query.toLowerCase()) ?? false) || // Corrección: descripcion es nullable
                  (contenido.tags?.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ?? false); // Corrección: usar tags
        }).toList();
      }
    });
  }

  void _mostrarBusqueda(BuildContext context) {
    // TODO: Implementar ContenidoSearchDelegate o reemplazar búsqueda
    // showSearch(
    //   context: context,
    //   delegate: ContenidoSearchDelegate(
    //     contenidos: _contenidos,
    //     onSearch: _filtrarContenidos,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAdmin = authService.hasAnyRole(['admin', 'super_admin', 'coordinador']);
    
    // Debug: Verificar rol del usuario
    print('🔍 ContenidoScreen: isAdmin = $isAdmin');
    print('🔍 ContenidoScreen: currentUser = ${authService.currentUser}');
    print('🔍 ContenidoScreen: userRole = ${authService.currentUser?['rol']}');

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
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ContenidoCrudScreen(),
                ),
              ).then((_) {
                // Recargar contenidos al volver
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          print('🟣 CONTENIDO_SCREEN: Botón presionado - navegando a CRUD');
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContenidoCrudScreen()),
          );
          if (result == true) _cargarContenidos();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Contenido'),
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () => abrirContenido(context, contenido),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Miniatura
            if (contenido.urlImagen != null) // Corrección: usar urlImagen
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: contenido.urlImagen!, // Corrección: usar urlImagen
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
                      obtenerIconoTipoString(contenido.tipo), // Corrección: usar tipo
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
                      buildTipoChipString(contenido.tipo), // Corrección: usar tipo
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  Text(
                    contenido.descripcion ?? '', // Corrección: descripcion es nullable
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Información adicional
                  Row(
                    children: [
                      buildNivelChipString(contenido.nivel), // Corrección: usar nivel
                      const SizedBox(width: 8),
                      if (contenido.duracionMinutos != null) // Corrección: usar duracionMinutos
                        buildDuracionChip(contenido.duracionMinutos!),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tags
                  if (contenido.tags?.isNotEmpty ?? false) // Corrección: usar tags
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: contenido.tags!.take(3).map((tag) { // Corrección: usar tags
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
  final ContenidoUnificado contenido;
  const ContenidoDetailScreen({super.key, required this.contenido});

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
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
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

