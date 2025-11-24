import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/blocs/contenido/contenido_provider.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/utils/resource_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/theme/app_theme.dart';

/// Widget para mostrar una tarjeta de contenido educativo
class ContenidoCardWidget extends ConsumerWidget {

  const ContenidoCardWidget({
    super.key,
    required this.contenido,
    this.width,
    this.height,
    this.showProgress = true,
    this.showStats = true,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.progress,
  });
  final Contenido contenido;
  final double? width;
  final double? height;
  final bool showProgress;
  final bool showStats;
  final Function(Contenido)? onTap;
  final Function(Contenido)? onFavoriteTap;
  final bool isFavorite;
  final double? progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagenUrl = contenido.thumbnailUrl ?? contenido.url;
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context, ref),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen o placeholder
              Expanded(
                flex: 3,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ResourceService.buildCachedImageWithFallback(
                          imagenUrl,
                          categoria: contenido.categoria.name,
                          tipo: contenido.tipo.name,
                          titulo: contenido.titulo,
                          width: 600,
                          height: 600,
                          fit: BoxFit.cover,
                          errorWidget: ColoredBox(
                            color: Colors.grey[300]!,
                            child: Center(
                              child: Icon(
                                  contenido.tipo.icono,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (onFavoriteTap != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () => onFavoriteTap!(contenido),
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 20,
                            ),
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.5)),
                              padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
                              shape: WidgetStateProperty.all(const CircleBorder()),
                            ),
                            tooltip: 'Favorito',
                          ),
                        ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: contenido.tipo.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            contenido.tipo.nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Información del contenido
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        contenido.titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Categoría
                      Text(
                        contenido.categoria.nombre,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Duración
                      if (contenido.duracion != null && contenido.duracion! > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${contenido.duracion! ~/ 60} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      
                      // Estadísticas
                      if (showStats) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final contenidoAsync = ref.watch(contenidoByIdProvider(contenido.id));
                            return contenidoAsync.when(
                              data: (result) {
                                final porcentaje = result.isSuccess
                                    ? (result.data?.progreso?.porcentaje)?.round()
                                    : null;
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      porcentaje != null ? '$porcentaje% progreso' : 'Sin datos',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading: () => Row(
                                children: [
                                  Icon(
                                    Icons.insights,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Cargando…',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              error: (_, __) => Row(
                                children: [
                                  Icon(
                                    Icons.insights,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sin datos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                      
                      // Progreso
                      if (showProgress && progress != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ]
                      else if (showProgress) ...[
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final contenidoAsync = ref.watch(contenidoByIdProvider(contenido.id));
                            return contenidoAsync.when(
                              data: (result) {
                                final porcentaje = result.isSuccess
                                    ? ((result.data?.progreso?.porcentaje ?? 0) / 100)
                                    : 0.0;
                                return LinearProgressIndicator(
                                  value: porcentaje,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                                );
                              },
                              loading: () => LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                              error: (_, __) => LinearProgressIndicator(
                                value: 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (onTap != null) {
      onTap!(contenido);
      return;
    }

    ref.registrarVista(contenido.id);
    final path = AppConstants.contenidoDetailRoute.replaceFirst(':id', contenido.id);
    context.push(path);
  }

  
}
