import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/application/providers/contenido_notifier.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/usecases/get_contenidos.dart';
import 'contenido_card_enhanced.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/pages/contenido_detail_page.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/loading_widget.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/error_widget.dart';

class ContenidoListWidget extends ConsumerWidget {

  const ContenidoListWidget({
    super.key,
    this.categoria,
    this.tipo,
    this.nivel,
    this.enablePagination = true,
    this.enablePullToRefresh = true,
    this.showProgress = true,
    this.emptyWidget,
    this.loadingWidget,
    this.errorWidget,
    this.onItemTap,
    this.onToggleFavorito,
    this.padding,
    this.physics,
    this.scrollController,
  });
  final CategoriaContenido? categoria;
  final TipoContenido? tipo;
  final NivelDificultad? nivel;
  final bool enablePagination;
  final bool enablePullToRefresh;
  final bool showProgress;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function(Contenido)? onItemTap;
  final Function(Contenido)? onToggleFavorito;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = GetContenidosParams(
      categoria: categoria,
      tipo: tipo,
      nivel: nivel,
    );
    final async = ref.watch(contenidosProvider(params));

    if (async.isLoading) {
      return loadingWidget ?? const LoadingWidget(message: 'Cargando contenidos...');
    }
    if (async.hasError) {
      return errorWidget ?? CustomErrorWidget(
        message: async.error.toString(),
        onRetry: () => ref.refresh(contenidosProvider(params)),
      );
    }
    final contenidos = async.value?.data ?? const <Contenido>[];
    if (contenidos.isEmpty) {
      return emptyWidget ?? _buildEmptyContent(
        'No hay contenidos disponibles',
        'Intenta ajustar tus filtros o vuelve a intentarlo más tarde.',
      );
    }

    final listView = _buildContenidoListView(contenidos, ref);
    if (enablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: () async {
          final _ = ref.refresh(contenidosProvider(params));
        },
        child: listView,
      );
    }
    return listView;
  }

  Widget _buildContenidoListView(
    List<Contenido> contenidos,
    WidgetRef ref,
  ) {
    return ListView.builder(
      controller: scrollController,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: contenidos.length,
      itemBuilder: (context, index) {
        final contenido = contenidos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ContenidoCardEnhanced(
            contenido: contenido,
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(contenido);
              } else {
                ref.registrarVista(contenido.id);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContenidoDetailPage(
                      contenidoId: contenido.id,
                      contenido: contenido,
                    ),
                  ),
                );
              }
            },
            onToggleFavorito: onToggleFavorito != null
                ? () => onToggleFavorito!(contenido)
                : () => ref.toggleFavorito(contenido.id),
            showProgress: showProgress,
          ),
        );
      },
    );
  }

  Widget _buildEmptyContent(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
