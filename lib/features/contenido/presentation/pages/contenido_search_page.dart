import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../blocs/contenido/contenido_state.dart';
import '../widgets/contenido_card_enhanced.dart';
import '../widgets/contenido_filter_widget.dart';
import 'contenido_detail_page.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class ContenidoSearchPage extends ConsumerStatefulWidget {
  const ContenidoSearchPage({super.key});

  @override
  ConsumerState<ContenidoSearchPage> createState() => _ContenidoSearchPageState();
}

class _ContenidoSearchPageState extends ConsumerState<ContenidoSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  String _lastSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _lastSearchQuery = query;
    });

    ref.searchContenidos(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _lastSearchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final contenidoState = ref.watch(contenidoBlocProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar contenidos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Buscar videos, artículos, podcasts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtros
          ContenidoFilterWidget(
            onFilterChanged: (categoria, tipo, nivel) {
              if (_lastSearchQuery.isNotEmpty) {
                ref.searchContenidos(_lastSearchQuery, filters: {
                  'categoria': categoria,
                  'tipo': tipo,
                  'nivel': nivel,
                });
              }
            },
          ),
          
          // Resultados de búsqueda
          Expanded(
            child: _buildSearchResults(contenidoState),
          ),
        ],
      ),
      floatingActionButton: _isSearching
          ? FloatingActionButton(
              onPressed: () {
                ref.refreshContenidos();
              },
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildSearchResults(ContenidoState contenidoState) {
    if (!_isSearching) {
      // Mensaje inicial
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Busca contenido educativo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Encuentra videos, artículos, podcasts y más',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Cargando
    if (contenidoState.status == ContenidoStatus.loading) {
      return const LoadingWidget(message: 'Buscando contenidos...');
    }

    // Error
    if (contenidoState.status == ContenidoStatus.failure) {
      return CustomErrorWidget(
        message: contenidoState.error ?? 'Error desconocido',
        onRetry: () => _performSearch(),
      );
    }

    // Sin resultados
    if (contenidoState.searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otras palabras o ajusta los filtros',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSearch,
              child: const Text('Limpiar búsqueda'),
            ),
          ],
        ),
      );
    }

    // Resultados encontrados
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${contenidoState.searchResults.length} resultados para "$_lastSearchQuery"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: contenidoState.searchResults.length,
            itemBuilder: (context, index) {
              final contenido = contenidoState.searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ContenidoCardEnhanced(
                  contenido: contenido,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContenidoDetailPage(
                          contenidoId: contenido.id,
                          contenido: contenido,
                        ),
                      ),
                    );
                  },
                  onToggleFavorito: () {
                    ref.toggleFavorito(contenido.id);
                  },
                  showProgress: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}