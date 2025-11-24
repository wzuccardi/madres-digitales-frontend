import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/providers/contenido_controller.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_state.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';

class ContenidoAdvancedSearchPage extends ConsumerStatefulWidget {
  const ContenidoAdvancedSearchPage({super.key});
  @override
  ConsumerState<ContenidoAdvancedSearchPage> createState() => _ContenidoAdvancedSearchPageState();
}

class _ContenidoAdvancedSearchPageState extends ConsumerState<ContenidoAdvancedSearchPage> {
  final _queryController = TextEditingController();
  CategoriaContenido? _categoria;
  TipoContenido? _tipo;
  NivelDificultad? _nivel;
  int _page = 1;
  final int _limit = 20;
  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contenidoControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Búsqueda avanzada')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _queryController, decoration: const InputDecoration(labelText: 'Buscar')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: DropdownButtonFormField<CategoriaContenido?>(
                  value: _categoria,
                  items: [
                    const DropdownMenuItem<CategoriaContenido?>(value: null, child: Text('Todas las categorías')),
                    ...CategoriaContenido.values.map((c) => DropdownMenuItem<CategoriaContenido?>(value: c, child: Text(c.name)))
                  ],
                  onChanged: (val) => setState(() => _categoria = val),
                  decoration: const InputDecoration(labelText: 'Categoría'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<TipoContenido?>(
                  value: _tipo,
                  items: [
                    const DropdownMenuItem<TipoContenido?>(value: null, child: Text('Todos los tipos')),
                    ...TipoContenido.values.map((t) => DropdownMenuItem<TipoContenido?>(value: t, child: Text(t.name)))
                  ],
                  onChanged: (val) => setState(() => _tipo = val),
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<NivelDificultad?>(
                  value: _nivel,
                  items: [
                    const DropdownMenuItem<NivelDificultad?>(value: null, child: Text('Todos los niveles')),
                    ...NivelDificultad.values.map((n) => DropdownMenuItem<NivelDificultad?>(value: n, child: Text(n.name)))
                  ],
                  onChanged: (val) => setState(() => _nivel = val),
                  decoration: const InputDecoration(labelText: 'Nivel'),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(
                onPressed: () async {
                  _page = 1;
                  await ref.read(contenidoControllerProvider.notifier).searchContenidos(
                        _queryController.text.trim(),
                        filters: {
                          'categoria': _categoria,
                          'tipo': _tipo,
                          'nivel': _nivel,
                          'page': _page,
                          'limit': _limit,
                        },
                      );
                },
                child: const Text('Buscar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(contenidoControllerProvider.notifier).getFavoritos('me');
                },
                child: const Text('Favoritos'),
              ),
            ]),
            const SizedBox(height: 12),
            Expanded(
              child: state.status == ContenidoStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        ...state.searchResults.map((c) => ListTile(title: Text(c.titulo ?? 'Contenido'), subtitle: Text(c.id))),
                        if (state.searchResults.length >= _limit)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: ElevatedButton(
                              onPressed: () async {
                                _page += 1;
                                await ref.read(contenidoControllerProvider.notifier).searchContenidos(
                                      _queryController.text.trim(),
                                      filters: {
                                        'categoria': _categoria,
                                        'tipo': _tipo,
                                        'nivel': _nivel,
                                        'page': _page,
                                        'limit': _limit,
                                      },
                                    );
                              },
                              child: const Text('Cargar más'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
