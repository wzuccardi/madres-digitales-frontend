import 'package:flutter/material.dart';
import '../../models/contenido_unificado.dart';
import '../../screens/reproductor_screen.dart';

/// Widget para mostrar una lista de contenidos educativos
class ContenidoListWidget extends StatefulWidget {
  final List<ContenidoUnificado> contenidos;
  final String? titulo;
  final bool mostrarFiltros;
  final bool refreshEnabled;
  final Future<void> Function()? onRefresh;
  final Function(ContenidoUnificado)? onContenidoTap;
  final Widget? emptyWidget;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

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

  @override
  State<ContenidoListWidget> createState() => _ContenidoListWidgetState();
}

class _ContenidoListWidgetState extends State<ContenidoListWidget> {
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

  Widget _buildContenidoList(List<ContenidoUnificado> contenidos) {
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

  Widget _buildContenidoCard(ContenidoUnificado contenido) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _abrirContenido(contenido),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen o placeholder
            if (contenido.urlImagen != null) // Corrección: usar urlImagen
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    contenido.urlImagen!, // Corrección: usar urlImagen
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            _getIconoTipo(contenido.tipo), // Corrección: usar tipo
                            size: 50,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Center(
                  child: Icon(
                    _getIconoTipo(contenido.tipo), // Corrección: usar tipo
                    size: 50,
                    color: Colors.grey[600],
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
                    contenido.descripcion ?? '', // Corrección: descripcion es nullable
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
                        _getNombreTipo(contenido.tipo), // Corrección: usar tipo
                        _getColorTipo(contenido.tipo), // Corrección: usar tipo
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        _getNombreCategoria(contenido.categoria),
                        Colors.blue,
                      ),
                      const Spacer(),
                      if (contenido.duracionMinutos != null) // Corrección: usar duracionMinutos
                        Text(
                          '${contenido.duracionMinutos} min', // Corrección: usar duracionMinutos
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

  List<ContenidoUnificado> _getContenidosFiltrados() {
    var filtrados = widget.contenidos;

    if (_filtroTipo != null) {
      filtrados = filtrados
          .where((c) => c.tipo == _filtroTipo) // Corrección: usar tipo
          .toList();
    }

    if (_filtroCategoria != null) {
      filtrados = filtrados
          .where((c) => c.categoria == _filtroCategoria)
          .toList();
    }

    return filtrados;
  }

  void _abrirContenido(ContenidoUnificado contenido) {
    if (widget.onContenidoTap != null) {
      widget.onContenidoTap!(contenido);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReproductorScreen(contenido: contenido),
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
              children: ['video', 'audio', 'documento', 'imagen'].map((tipo) {
                return FilterChip(
                  label: Text(_getNombreTipo(tipo)),
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
                  label: Text(_getNombreCategoria(categoria)),
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

  IconData _getIconoTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.audiotrack;
      case 'documento':
        return Icons.description;
      case 'imagen':
        return Icons.image;
      case 'articulo':
        return Icons.article;
      case 'infografia':
        return Icons.info;
      default:
        return Icons.library_books;
    }
  }

  String _getNombreTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return 'Video';
      case 'audio':
        return 'Audio';
      case 'documento':
        return 'Documento';
      case 'imagen':
        return 'Imagen';
      case 'articulo':
        return 'Artículo';
      case 'infografia':
        return 'Infografía';
      default:
        return 'Otro';
    }
  }

  String _getNombreCategoria(String categoria) {
    switch (categoria) {
      case 'nutricion':
        return 'Nutrición';
      case 'cuidado_prenatal':
        return 'Cuidado Prenatal';
      case 'signos_alarma':
        return 'Signos de Alarma';
      case 'lactancia':
        return 'Lactancia';
      case 'parto':
        return 'Parto';
      case 'posparto':
        return 'Posparto';
      case 'planificacion':
        return 'Planificación';
      case 'salud_mental':
        return 'Salud Mental';
      case 'ejercicio':
        return 'Ejercicio';
      case 'higiene':
        return 'Higiene';
      case 'derechos':
        return 'Derechos';
      case 'otros':
        return 'Otros';
      default:
        return 'Otro';
    }
  }

  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'video':
        return Colors.red;
      case 'audio':
        return Colors.purple;
      case 'documento':
        return Colors.blue;
      case 'imagen':
        return Colors.green;
      case 'articulo':
        return Colors.orange;
      case 'infografia':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}