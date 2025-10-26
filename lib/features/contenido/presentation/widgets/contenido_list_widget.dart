import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contenido.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../blocs/contenido/contenido_event.dart';
import '../blocs/contenido/contenido_state.dart';
import 'contenido_card_enhanced.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class ContenidoListWidget extends ConsumerWidget {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contenidoState = ref.watch(contenidoBlocProvider);
    final contenidoBloc = ref.read(contenidoBlocProvider.notifier);

    // Cargar contenidos al inicializar si es necesario
    if (contenidoState.status == ContenidoStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.loadContenidos(
          categoria: categoria,
          tipo: tipo,
          nivel: nivel,
        );
      });
    }

    // Widget de carga
    if (contenidoState.status == ContenidoStatus.loading &&
        contenidoState.contenidos.isEmpty) {
      return loadingWidget ?? const LoadingWidget(message: 'Cargando contenidos...');
    }

    // Widget de error
    if (contenidoState.status == ContenidoStatus.failure &&
        contenidoState.contenidos.isEmpty) {
      return errorWidget ?? CustomErrorWidget(
        message: contenidoState.error ?? 'Error desconocido',
        onRetry: () {
          ref.loadContenidos(
            categoria: categoria,
            tipo: tipo,
            nivel: nivel,
            forceRefresh: true,
          );
        },
      );
    }

    // Widget de lista de contenidos
    Widget contenidoListView;

    if (enablePullToRefresh) {
      contenidoListView = RefreshIndicator(
        onRefresh: () async {
          await contenidoBloc.mapEventToState(
            LoadContenidosEvent(
              categoria: categoria,
              tipo: tipo,
              nivel: nivel,
              forceRefresh: true,
            ),
          );
        },
        child: _buildContenidoListView(
          contenidoState,
          ref,
          contenidoBloc,
        ),
      );
    } else {
      contenidoListView = _buildContenidoListView(
        contenidoState,
        ref,
        contenidoBloc,
      );
    }

    // Widget de carga inferior para paginación
    Widget contenidoListWithPagination = contenidoListView;

    if (enablePagination) {
      contenidoListWithPagination = NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!contenidoState.hasReachedMax &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              contenidoState.status != ContenidoStatus.loading) {
            // Cargar más contenidos
            contenidoBloc.mapEventToState(
              LoadContenidosEvent(
                categoria: categoria,
                tipo: tipo,
                nivel: nivel,
                page: contenidoState.page + 1,
                limit: contenidoState.limit,
              ),
            );
          }
          return false;
        },
        child: contenidoListView,
      );
    }

    return contenidoListWithPagination;
  }

  Widget _buildContenidoListView(
    ContenidoState contenidoState,
    WidgetRef ref,
    dynamic contenidoBloc,
  ) {
    // Widget vacío si no hay contenidos
    if (contenidoState.contenidos.isEmpty) {
      return emptyWidget ??
          _buildEmptyContent(
            'No hay contenidos disponibles',
            'Intenta ajustar tus filtros o vuelve a intentarlo más tarde.',
          );
    }

    // Widget de lista de contenidos
    return ListView.builder(
      controller: scrollController,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: contenidoState.contenidos.length + (contenidoState.isRefreshing ? 1 : 0),
      itemBuilder: (context, index) {
        // Último item con indicador de carga
        if (index == contenidoState.contenidos.length &&
            contenidoState.isRefreshing) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final contenido = contenidoState.contenidos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ContenidoCardEnhanced(
            contenido: contenido,
            onTap: () {
              if (onItemTap != null) {
                onItemTap!(contenido);
              } else {
                // Navegar a pantalla de detalles por defecto
                ref.loadContenidoById(contenido.id);
                // Aquí se podría agregar la navegación a la pantalla de detalles
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