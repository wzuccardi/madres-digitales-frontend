import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/contenido_provider.dart';
import 'widgets/contenido_card.dart';
import 'pages/contenido_form_page.dart';

class ContenidoListPage extends ConsumerWidget {
  const ContenidoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contenidosState = ref.watch(contenidoSimpleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Contenido Educativo')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContenidoFormPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: contenidosState.status == ContenidoStatus.loading && contenidosState.contenidos.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : contenidosState.status == ContenidoStatus.failure
              ? Center(
                  child: Text('Error: ${contenidosState.error ?? "Error desconocido"}'),
                )
              : contenidosState.contenidos.isEmpty
                  ? const Center(
                      child: Text('No hay contenidos disponibles'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: contenidosState.contenidos.length +
                          (contenidosState.hasReachedMax ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == contenidosState.contenidos.length) {
                          // Cargar más contenidos
                          ref.read(contenidoSimpleProvider.notifier).getContenidos(
                            page: contenidosState.page + 1,
                            categoria: contenidosState.categoria,
                            tipo: contenidosState.tipo,
                            nivel: contenidosState.nivel,
                          );
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
                            // Navegar a la página de detalle
                            // Navigator.pushNamed(
                            //   context,
                            //   '/contenido_detalle',
                            //   arguments: contenido,
                            // );
                          },
                          onToggleFavorito: () {
                            // Alternar favorito
                            // ref.read(contenidoSimpleProvider.notifier).toggleFavorito(contenido.id);
                          },
                        );
                      },
                    ),
    );
  }
}

