import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contenido.dart';
import '../../data/services/resource_service.dart';

class ContenidoCardEnhanced extends ConsumerWidget {
  final Contenido contenido;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorito;
  final double? height;
  final double? width;
  final bool showProgress;
  final bool showCategory;
  final bool showDuration;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final double? borderRadius;
  final bool enableHeroAnimation;

  const ContenidoCardEnhanced({
    super.key,
    required this.contenido,
    this.onTap,
    this.onToggleFavorito,
    this.height,
    this.width,
    this.showProgress = true,
    this.showCategory = true,
    this.showDuration = true,
    this.margin,
    this.padding,
    this.borderRadius,
    this.enableHeroAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardHeight = height ?? 200.0;
    final cardWidth = width ?? double.infinity;
    final cardBorderRadius = borderRadius ?? 12.0;
    final cardMargin = margin ?? const EdgeInsets.all(8.0);
    final cardPadding = padding ?? const EdgeInsets.all(12.0);

    Widget card = Container(
      width: cardWidth,
      height: cardHeight,
      margin: cardMargin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: Padding(
          padding: cardPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del contenido
              _buildImage(cardBorderRadius),
              const SizedBox(width: 12),
              // Información del contenido
              Expanded(
                child: _buildContentInfo(),
              ),
            ],
          ),
        ),
      ),
    );

    // Agregar animación Hero si está habilitada
    if (enableHeroAnimation) {
      card = Hero(
        tag: 'contenido_${contenido.id}',
        child: Material(
          type: MaterialType.transparency,
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildImage(double borderRadius) {
    final imageHeight = height != null ? height! - 24 : 176.0;
    final imageWidth = imageHeight * 16 / 9; // Relación de aspecto 16:9

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: ResourceService.buildCachedImageWithFallback(
        contenido.thumbnailUrl,
        categoria: contenido.categoria.name,
        tipo: contenido.tipo.name,
        titulo: contenido.titulo,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildContentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoría y duración
        if (showCategory || showDuration)
          _buildMetadata(),
        
        const SizedBox(height: 4),
        
        // Título
        Text(
          contenido.titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: 4),
        
        // Descripción
        Text(
          contenido.descripcion,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const Spacer(),
        
        // Barra de progreso y botón de favorito
        Row(
          children: [
            // Barra de progreso
            if (showProgress && contenido.progreso != null)
              Expanded(
                child: _buildProgressBar(),
              ),
            
            // Botón de favorito
            if (onToggleFavorito != null) ...[
              if (showProgress && contenido.progreso != null)
                const SizedBox(width: 8),
              _buildFavoriteButton(),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        // Categoría
        if (showCategory)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getCategoryColor(contenido.categoria).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getCategoryLabel(contenido.categoria),
              style: TextStyle(
                fontSize: 10,
                color: _getCategoryColor(contenido.categoria),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Duración
        if (showDuration && contenido.duracion != null) ...[
          if (showCategory) const SizedBox(width: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 2),
              Text(
                _formatDuration(contenido.duracion!),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProgressBar() {
    final progreso = contenido.progreso!;
    final porcentaje = progreso.porcentaje / 100;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${progreso.porcentaje.toStringAsFixed(0)}% completado',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: porcentaje,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getCategoryColor(contenido.categoria),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return IconButton(
      icon: Icon(
        contenido.favorito ? Icons.favorite : Icons.favorite_border,
        color: contenido.favorito ? Colors.red : Colors.grey[600],
        size: 20,
      ),
      onPressed: onToggleFavorito,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 24,
        minHeight: 24,
      ),
    );
  }

  Color _getCategoryColor(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return const Color(0xFF4CAF50);
      case CategoriaContenido.ejercicio:
        return const Color(0xFF2196F3);
      case CategoriaContenido.saludMental:
        return const Color(0xFF9C27B0);
      case CategoriaContenido.preparacionParto:
        return const Color(0xFFFF9800);
      case CategoriaContenido.cuidadoBebe:
        return const Color(0xFFE91E63);
      case CategoriaContenido.lactancia:
        return const Color(0xFF00BCD4);
      case CategoriaContenido.desarrolloInfantil:
        return const Color(0xFF8BC34A);
      case CategoriaContenido.seguridad:
        return const Color(0xFFF44336);
    }
  }

  String _getCategoryLabel(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return 'Nutrición';
      case CategoriaContenido.ejercicio:
        return 'Ejercicio';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
      case CategoriaContenido.preparacionParto:
        return 'Parto';
      case CategoriaContenido.cuidadoBebe:
        return 'Bebé';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.desarrolloInfantil:
        return 'Desarrollo';
      case CategoriaContenido.seguridad:
        return 'Seguridad';
    }
  }

  String _formatDuration(int segundos) {
    final minutos = segundos ~/ 60;
    final seg = segundos % 60;
    return '$minutos:${seg.toString().padLeft(2, '0')}';
  }
}