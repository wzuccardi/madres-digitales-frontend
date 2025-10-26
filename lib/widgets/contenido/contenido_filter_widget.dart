import 'package:flutter/material.dart';

/// Widget para filtrar contenidos educativos
class ContenidoFilterWidget extends StatefulWidget {
  final String? tipoInicial;
  final String? categoriaInicial;
  final Function(String? tipo, String? categoria)? onFilterChanged;
  final bool mostrarCategoria;

  const ContenidoFilterWidget({
    super.key,
    this.tipoInicial,
    this.categoriaInicial,
    this.onFilterChanged,
    this.mostrarCategoria = true,
  });

  @override
  State<ContenidoFilterWidget> createState() => _ContenidoFilterWidgetState();
}

class _ContenidoFilterWidgetState extends State<ContenidoFilterWidget> {
  String? _tipoSeleccionado;
  String? _categoriaSeleccionada;

  @override
  void initState() {
    super.initState();
    _tipoSeleccionado = widget.tipoInicial;
    _categoriaSeleccionada = widget.categoriaInicial;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Filtro por tipo
          const Text(
            'Tipo de contenido:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['video', 'audio', 'documento', 'imagen', 'articulo', 'infografia'].map((tipo) {
              return FilterChip(
                label: Text(_getNombreTipo(tipo)),
                selected: _tipoSeleccionado == tipo,
                onSelected: (selected) {
                  setState(() {
                    _tipoSeleccionado = selected ? tipo : null;
                  });
                  _notificarCambioFiltro();
                },
                backgroundColor: Colors.grey[200],
                selectedColor: _getColorTipo(tipo).withValues(alpha: 0.2),
                checkmarkColor: _getColorTipo(tipo),
              );
            }).toList(),
          ),
          
          if (widget.mostrarCategoria) ...[
            const SizedBox(height: 16),
            
            // Filtro por categoría
            const Text(
              'Categoría:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
                  selected: _categoriaSeleccionada == categoria,
                  onSelected: (selected) {
                    setState(() {
                      _categoriaSeleccionada = selected ? categoria : null;
                    });
                    _notificarCambioFiltro();
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue.withValues(alpha: 0.2),
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _limpiarFiltros,
                child: const Text('Limpiar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aplicar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _notificarCambioFiltro() {
    if (widget.onFilterChanged != null) {
      widget.onFilterChanged!(_tipoSeleccionado, _categoriaSeleccionada);
    }
  }

  void _limpiarFiltros() {
    setState(() {
      _tipoSeleccionado = null;
      _categoriaSeleccionada = null;
    });
    _notificarCambioFiltro();
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