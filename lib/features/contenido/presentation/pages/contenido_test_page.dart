import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/contenido_provider.dart';
import '../widgets/contenido_card.dart';

class ContenidoTestPage extends ConsumerWidget {
  const ContenidoTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Contenido'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(contenidoSimpleProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final contenidosState = ref.watch(contenidoSimpleProvider);

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
            padding: const EdgeInsets.all(16),
            itemCount: contenidosState.contenidos.length,
            itemBuilder: (context, index) {
              final contenido = contenidosState.contenidos[index];
              return ContenidoCard(
                contenido: contenido,
                onTap: () {
                  ref.read(contenidoSimpleProvider.notifier).selectContenido(contenido);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Seleccionado: ${contenido.titulo}')),
                  );
                },
                onToggleFavorito: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Alternar favorito: ${contenido.titulo}')),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ref.read(contenidoSimpleProvider.notifier).getContenidos();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}