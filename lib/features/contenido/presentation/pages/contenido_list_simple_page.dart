import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contenido_provider.dart';
import '../widgets/contenido_card.dart';
import '../../domain/entities/contenido.dart';

class ContenidoListSimplePage extends ConsumerStatefulWidget {
  const ContenidoListSimplePage({super.key});

  @override
  ConsumerState<ContenidoListSimplePage> createState() => _ContenidoListSimplePageState();
}

class _ContenidoListSimplePageState extends ConsumerState<ContenidoListSimplePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Cargar los contenidos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contenidoSimpleProvider.notifier).getContenidos();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      final state = ref.read(contenidoSimpleProvider);
      if (!state.hasReachedMax && !_isLoading) {
        _isLoading = true;
        ref.read(contenidoSimpleProvider.notifier).getContenidos(
          page: state.page + 1,
          categoria: state.categoria,
          tipo: state.tipo,
          nivel: state.nivel,
        );
        _isLoading = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenidosState = ref.watch(contenidoSimpleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contenido Educativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(contenidoSimpleProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(contenidoSimpleProvider.notifier).refresh();
        },
        child: Builder(
          builder: (context) {
            if (contenidosState.status == ContenidoStatus.loading && contenidosState.contenidos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (contenidosState.status == ContenidoStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${contenidosState.error ?? "Error desconocido"}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(contenidoSimpleProvider.notifier).refresh();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (contenidosState.contenidos.isEmpty) {
              return const Center(
                child: Text('No hay contenidos disponibles'),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: contenidosState.contenidos.length + (contenidosState.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == contenidosState.contenidos.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final contenido = contenidosState.contenidos[index];
                return ContenidoCard(
                  contenido: contenido,
                  onTap: () {
                    ref.read(contenidoSimpleProvider.notifier).selectContenido(contenido);
                    // Navegar a la página de detalle
                    // Navigator.pushNamed(
                    //   context,
                    //   '/contenido_detalle',
                    //   arguments: contenido,
                    // );
                  },
                  onToggleFavorito: () {
                    // Por ahora, no implementamos la alternancia de favorito
                    // ref.read(contenidoSimpleProvider.notifier).toggleFavorito(contenido.id);
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFilterDialog(context);
        },
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar contenido'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Ingrese término de búsqueda',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (searchController.text.isNotEmpty) {
                ref.read(contenidoSimpleProvider.notifier).searchContenidos(
                  query: searchController.text,
                );
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final contenidosState = ref.read(contenidoSimpleProvider);
    CategoriaContenido? categoria = contenidosState.categoria;
    TipoContenido? tipo = contenidosState.tipo;
    NivelDificultad? nivel = contenidosState.nivel;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filtrar contenido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro de categoría
              DropdownButtonFormField<CategoriaContenido>(
                initialValue: categoria,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: CategoriaContenido.values.map((value) {
                  return DropdownMenuItem<CategoriaContenido>(
                    value: value,
                    child: Text(value.value.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    categoria = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Filtro de tipo
              DropdownButtonFormField<TipoContenido>(
                initialValue: tipo,
                decoration: const InputDecoration(labelText: 'Tipo'),
                items: TipoContenido.values.map((value) {
                  return DropdownMenuItem<TipoContenido>(
                    value: value,
                    child: Text(value.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    tipo = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Filtro de nivel
              DropdownButtonFormField<NivelDificultad>(
                initialValue: nivel,
                decoration: const InputDecoration(labelText: 'Nivel'),
                items: NivelDificultad.values.map((value) {
                  return DropdownMenuItem<NivelDificultad>(
                    value: value,
                    child: Text(value.value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    nivel = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(contenidoSimpleProvider.notifier).getContenidos(
                  categoria: categoria,
                  tipo: tipo,
                  nivel: nivel,
                );
              },
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}