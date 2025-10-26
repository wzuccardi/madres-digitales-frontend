import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contenido.dart';
import '../blocs/contenido/contenido_event.dart';
import '../blocs/contenido/contenido_state.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../widgets/contenido_card_enhanced.dart';
import '../widgets/contenido_filter_widget.dart';
import 'contenido_form_page.dart';
import 'contenido_detail_page.dart';

class ContenidoAdminPage extends ConsumerStatefulWidget {
  const ContenidoAdminPage({super.key});

  @override
  ConsumerState<ContenidoAdminPage> createState() => _ContenidoAdminPageState();
}

class _ContenidoAdminPageState extends ConsumerState<ContenidoAdminPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  CategoriaContenido? _categoriaSeleccionada;
  TipoContenido? _tipoSeleccionado;
  NivelDificultad? _nivelSeleccionado;
  String _terminoBusqueda = '';
  
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _cargarContenidos();
    
    // Configurar scroll para paginación infinita
    _scrollController.addListener(_onScroll);
    
    // Configurar listener para búsqueda
    _searchController.addListener(() {
      setState(() {
        _terminoBusqueda = _searchController.text;
      });
      _realizarBusqueda();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const delta = 200.0; // Umbral para cargar más datos
    
    if (maxScroll - currentScroll < delta && 
        !_isLoadingMore && 
        _hasMoreData) {
      _cargarMasContenidos();
    }
  }

  void _cargarContenidos({bool refrescar = false}) {
    if (refrescar) {
      _currentPage = 1;
      _hasMoreData = true;
    }
    
    ref.read(contenidoBlocProvider.notifier).mapEventToState(
      LoadContenidosEvent(
        categoria: _categoriaSeleccionada,
        tipo: _tipoSeleccionado,
        nivel: _nivelSeleccionado,
        page: _currentPage,
        limit: _pageSize,
        forceRefresh: refrescar,
      ),
    );
  }

  void _cargarMasContenidos() {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    _currentPage++;
    
    ref.read(contenidoBlocProvider.notifier).mapEventToState(
      LoadContenidosEvent(
        categoria: _categoriaSeleccionada,
        tipo: _tipoSeleccionado,
        nivel: _nivelSeleccionado,
        page: _currentPage,
        limit: _pageSize,
      ),
    );
    
    // Escuchar el estado para determinar si hay más datos
    ref.listen<ContenidoState>(contenidoBlocProvider, (previous, state) {
      if (state.status == ContenidoStatus.success && _isLoadingMore) {
        setState(() {
          _isLoadingMore = false;
          _hasMoreData = state.contenidos.length >= _pageSize;
        });
      } else if (state.status == ContenidoStatus.failure && _isLoadingMore) {
        setState(() {
          _isLoadingMore = false;
          _currentPage--; // Revertir página en caso de error
        });
      }
    });
  }

  void _realizarBusqueda() {
    if (_terminoBusqueda.isEmpty) {
      _cargarContenidos(refrescar: true);
    } else {
      ref.read(contenidoBlocProvider.notifier).mapEventToState(
        SearchContenidosEvent(
          query: _terminoBusqueda,
          filters: {
            'categoria': _categoriaSeleccionada?.value,
            'tipo': _tipoSeleccionado?.value,
            'nivel': _nivelSeleccionado?.value,
          },
        ),
      );
    }
  }

  void _aplicarFiltros({
    CategoriaContenido? categoria,
    TipoContenido? tipo,
    NivelDificultad? nivel,
  }) {
    setState(() {
      _categoriaSeleccionada = categoria;
      _tipoSeleccionado = tipo;
      _nivelSeleccionado = nivel;
    });
    _cargarContenidos(refrescar: true);
  }

  void _irAFormulario({Contenido? contenido}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContenidoFormPage(contenido: contenido),
      ),
    ).then((_) {
      // Refrescar la lista al regresar del formulario
      _cargarContenidos(refrescar: true);
    });
  }

  void _irADetalles(Contenido contenido) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContenidoDetailPage(contenidoId: contenido.id),
      ),
    ).then((_) {
      // Refrescar la lista al regresar de detalles
      _cargarContenidos(refrescar: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contenidoBlocProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Contenidos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarContenidos(refrescar: true),
            tooltip: 'Refrescar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _irAFormulario(),
            tooltip: 'Nuevo contenido',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _cargarContenidos(refrescar: true),
        child: Column(
          children: [
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar contenidos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _terminoBusqueda.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            
            // Filtros
            ContenidoFilterWidget(
              initialCategoria: _categoriaSeleccionada,
              initialTipo: _tipoSeleccionado,
              initialNivel: _nivelSeleccionado,
              onFilterChanged: (categoria, tipo, nivel) {
                _aplicarFiltros(
                  categoria: categoria,
                  tipo: tipo,
                  nivel: nivel,
                );
              },
            ),
            
            // Lista de contenidos
            Expanded(
              child: _buildContenidoList(state),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _irAFormulario(),
        tooltip: 'Nuevo contenido',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContenidoList(ContenidoState state) {
    if (state.status == ContenidoStatus.loading && _currentPage == 1) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (state.status == ContenidoStatus.failure && _currentPage == 1) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar contenidos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Error desconocido',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _cargarContenidos(refrescar: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (state.contenidos.isEmpty) {
      return Center(
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
              _terminoBusqueda.isNotEmpty
                  ? 'No se encontraron resultados para "$_terminoBusqueda"'
                  : 'No hay contenidos disponibles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_terminoBusqueda.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Limpiar búsqueda'),
              )
            else
              ElevatedButton(
                onPressed: () => _irAFormulario(),
                child: const Text('Crear primer contenido'),
              ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: state.contenidos.length + (_hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.contenidos.length) {
          // Indicador de carga al final
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        final contenido = state.contenidos[index];
        
        return Dismissible(
          key: Key(contenido.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await _confirmarEliminacion(contenido);
          },
          onDismissed: (direction) {
            // Eliminar el contenido
            ref.read(contenidoBlocProvider.notifier).mapEventToState(
              DeleteContenidoEvent(contenido.id),
            );
            
            // Mostrar mensaje
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contenido eliminado'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: ContenidoCardEnhanced(
            contenido: contenido,
            onTap: () => _irADetalles(contenido),
            onToggleFavorito: null, // No mostrar favoritos en modo admin
            enableHeroAnimation: false,
          ),
        );
      },
    );
  }

  Future<bool> _confirmarEliminacion(Contenido contenido) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Contenido'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${contenido.titulo}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'ELIMINAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;
  }
}