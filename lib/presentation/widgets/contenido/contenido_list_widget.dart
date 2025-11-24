import 'package:flutter/material.dart';
import 'package:madres_digitales_flutter_new/features/contenido/domain/entities/contenido.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/pages/contenido_detail_page.dart';
import 'package:madres_digitales_flutter_new/features/contenido/presentation/utils/resource_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/application/providers/contenido_notifier.dart';

/// Widget para mostrar una lista de contenidos educativos
class ContenidoListWidget extends ConsumerStatefulWidget {

  const ContenidoListWidget({
    super.key,
    required this.contenidos,
    this.titulo,
    this.mostrarFiltros = false,
    this.refreshEnabled = false,
    this.onRefresh,
    this.onContenidoTap,
    this.emptyWidget,
    this.shrinkWrap = false,
    this.physics,
  });
  final List<Contenido> contenidos;
  final String? titulo;
  final bool mostrarFiltros;
  final bool refreshEnabled;
  final Future<void> Function()? onRefresh;
  final Function(Contenido)? onContenidoTap;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  ConsumerState<ContenidoListWidget> createState() => _ContenidoListWidgetState();
}

class _ContenidoListWidgetState extends ConsumerState<ContenidoListWidget> {
  String? _filtroTipo;
  String? _filtroCategoria;

  @override
  Widget build(BuildContext context) {
    final contenidosFiltrados = _getContenidosFiltrados();

    if (widget.titulo != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.titulo!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.mostrarFiltros)
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _mostrarFiltros,
                  ),
              ],
            ),
          ),
          _buildContenidoList(contenidosFiltrados),
        ],
      );
    }

    return _buildContenidoList(contenidosFiltrados);
  }

  Widget _buildContenidoList(List<Contenido> contenidos) {
    if (contenidos.isEmpty) {
      return widget.emptyWidget ?? _buildEmptyWidget();
    }

    final child = ListView.builder(
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      padding: const EdgeInsets.all(16),
      itemCount: contenidos.length,
      itemBuilder: (context, index) {
        final contenido = contenidos[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildContenidoCard(contenido),
        );
      },
    );

    if (widget.refreshEnabled && widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay contenido disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta ajustar los filtros o recargar la página',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenidoCard(Contenido contenido) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _abrirContenido(contenido),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con fallback robusto
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ResourceService.buildCachedImageWithFallback(
                  contenido.thumbnailUrl ?? contenido.url,
                  categoria: contenido.categoria.name,
                  tipo: contenido.tipo.name,
                  titulo: contenido.titulo,
                  width: 640,
                  height: 360,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: Colors.grey[300],
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
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 8),

                  // Descripción
                  Text(
                    contenido.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Metadata
                  Row(
                    children: [
                      _buildChip(
                        contenido.tipo.nombre,
                        contenido.tipo.color,
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        contenido.categoria.nombre,
                        Colors.blue,
                      ),
                      const Spacer(),
                      if (contenido.duracion != null)
                        Text(
                          '${contenido.duracion! ~/ 60} min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<Contenido> _getContenidosFiltrados() {
    var filtrados = widget.contenidos;

    if (_filtroTipo != null) {
      filtrados = filtrados
          .where((c) => c.tipo.name == _filtroTipo)
          .toList();
    }

    if (_filtroCategoria != null) {
      filtrados = filtrados
          .where((c) => c.categoria.name == _filtroCategoria)
          .toList();
    }

    return filtrados;
  }

  void _abrirContenido(Contenido contenido) {
    if (widget.onContenidoTap != null) {
      widget.onContenidoTap!(contenido);
      return;
    }

    ref.registrarVista(contenido.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContenidoDetailPage(contenidoId: contenido.id, contenido: contenido),
      ),
    );
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de contenido:'),
            Wrap(
              spacing: 8,
              children: ['video', 'audio', 'infografia', 'articulo', 'guia', 'curso', 'webinar', 'evaluacion'].map((tipo) {
                return FilterChip(
                  label: Text(TipoContenido.fromString(tipo).nombre),
                  selected: _filtroTipo == tipo,
                  onSelected: (selected) {
                    setState(() {
                      _filtroTipo = selected ? tipo : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Categoría:'),
            Wrap(
              spacing: 8,
              children: [
                'nutricion',
                'cuidado_prenatal',
                'signos_alarma',
                'lactancia',
                'parto',
                'posparto',
                'planificacion',
                'salud_mental',
                'ejercicio',
                'higiene',
                'derechos',
                'otros'
              ].map((categoria) {
                return FilterChip(
                  label: Text(CategoriaContenido.fromString(categoria).nombre),
                  selected: _filtroCategoria == categoria,
                  onSelected: (selected) {
                    setState(() {
                      _filtroCategoria = selected ? categoria : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filtroTipo = null;
                      _filtroCategoria = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  
}
