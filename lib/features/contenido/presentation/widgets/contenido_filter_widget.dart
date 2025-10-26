import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/contenido.dart';
import '../blocs/contenido/contenido_provider.dart';
import '../../../../shared/theme/app_theme.dart';

class ContenidoFilterWidget extends ConsumerStatefulWidget {
  final CategoriaContenido? initialCategoria;
  final TipoContenido? initialTipo;
  final NivelDificultad? initialNivel;
  final Function(CategoriaContenido?, TipoContenido?, NivelDificultad?)? onFilterChanged;
  final bool showCategoriaFilter;
  final bool showTipoFilter;
  final bool showNivelFilter;
  final bool showSearchBar;
  final String? searchHint;
  final EdgeInsets? padding;

  const ContenidoFilterWidget({
    super.key,
    this.initialCategoria,
    this.initialTipo,
    this.initialNivel,
    this.onFilterChanged,
    this.showCategoriaFilter = true,
    this.showTipoFilter = true,
    this.showNivelFilter = true,
    this.showSearchBar = true,
    this.searchHint,
    this.padding,
  });

  @override
  ConsumerState<ContenidoFilterWidget> createState() => _ContenidoFilterWidgetState();
}

class _ContenidoFilterWidgetState extends ConsumerState<ContenidoFilterWidget> {
  late TextEditingController _searchController;
  CategoriaContenido? _selectedCategoria;
  TipoContenido? _selectedTipo;
  NivelDificultad? _selectedNivel;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selectedCategoria = widget.initialCategoria;
    _selectedTipo = widget.initialTipo;
    _selectedNivel = widget.initialNivel;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          if (widget.showSearchBar) ...[
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint ?? 'Buscar contenidos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => _applyFilters(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Botón para expandir filtros
          Row(
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                label: Text(_isExpanded ? 'Ocultar' : 'Mostrar'),
              ),
            ],
          ),
          
          // Filtros expandibles
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            
            // Filtro de categoría
            if (widget.showCategoriaFilter) ...[
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Opción "Todas"
                  FilterChip(
                    label: const Text('Todas'),
                    selected: _selectedCategoria == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoria = selected ? null : _selectedCategoria;
                      });
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.primaryColor,
                  ),
                  // Opciones de categorías
                  ...CategoriaContenido.values.map((categoria) {
                    return FilterChip(
                      label: Text(_getCategoriaLabel(categoria)),
                      selected: _selectedCategoria == categoria,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoria = selected ? categoria : null;
                        });
                        _applyFilters();
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.primaryColor,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Filtro de tipo
            if (widget.showTipoFilter) ...[
              const Text(
                'Tipo de contenido',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Opción "Todos"
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedTipo == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedTipo = selected ? null : _selectedTipo;
                      });
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.secondaryColor,
                  ),
                  // Opciones de tipos
                  ...TipoContenido.values.map((tipo) {
                    return FilterChip(
                      label: Text(_getTipoLabel(tipo)),
                      selected: _selectedTipo == tipo,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTipo = selected ? tipo : null;
                        });
                        _applyFilters();
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.2),
                      checkmarkColor: AppTheme.secondaryColor,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Filtro de nivel
            if (widget.showNivelFilter) ...[
              const Text(
                'Nivel de dificultad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Opción "Todos"
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _selectedNivel == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedNivel = selected ? null : _selectedNivel;
                      });
                      _applyFilters();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
                    checkmarkColor: AppTheme.accentColor,
                  ),
                  // Opciones de niveles
                  ...NivelDificultad.values.map((nivel) {
                    return FilterChip(
                      label: Text(_getNivelLabel(nivel)),
                      selected: _selectedNivel == nivel,
                      onSelected: (selected) {
                        setState(() {
                          _selectedNivel = selected ? nivel : null;
                        });
                        _applyFilters();
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: _getNivelColor(nivel).withValues(alpha: 0.2),
                      checkmarkColor: _getNivelColor(nivel),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
            ],
            
            // Botón para limpiar filtros
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearFilters,
                    child: const Text('Limpiar filtros'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _applyFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _applyFilters() {
    // Aplicar filtros usando el BLoC
    ref.loadContenidos(
      categoria: _selectedCategoria,
      tipo: _selectedTipo,
      nivel: _selectedNivel,
    );

    // Aplicar búsqueda si hay texto
    if (_searchController.text.isNotEmpty) {
      ref.searchContenidos(_searchController.text, filters: {
        'categoria': _selectedCategoria,
        'tipo': _selectedTipo,
        'nivel': _selectedNivel,
      });
    }

    // Notificar cambio de filtros si se proporcionó una función
    if (widget.onFilterChanged != null) {
      widget.onFilterChanged!(
        _selectedCategoria,
        _selectedTipo,
        _selectedNivel,
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategoria = null;
      _selectedTipo = null;
      _selectedNivel = null;
    });
    _applyFilters();
  }

  String _getCategoriaLabel(CategoriaContenido categoria) {
    switch (categoria) {
      case CategoriaContenido.nutricion:
        return 'Nutrición';
      case CategoriaContenido.ejercicio:
        return 'Ejercicio';
      case CategoriaContenido.saludMental:
        return 'Salud Mental';
      case CategoriaContenido.preparacionParto:
        return 'Preparación Parto';
      case CategoriaContenido.cuidadoBebe:
        return 'Cuidado Bebé';
      case CategoriaContenido.lactancia:
        return 'Lactancia';
      case CategoriaContenido.desarrolloInfantil:
        return 'Desarrollo Infantil';
      case CategoriaContenido.seguridad:
        return 'Seguridad';
    }
  }

  String _getTipoLabel(TipoContenido tipo) {
    switch (tipo) {
      case TipoContenido.articulo:
        return 'Artículo';
      case TipoContenido.video:
        return 'Video';
      case TipoContenido.podcast:
        return 'Podcast';
      case TipoContenido.infografia:
        return 'Infografía';
      case TipoContenido.guia:
        return 'Guía';
      case TipoContenido.curso:
        return 'Curso';
      case TipoContenido.webinar:
        return 'Webinar';
      case TipoContenido.evaluacion:
        return 'Evaluación';
    }
  }

  String _getNivelLabel(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return 'Básico';
      case NivelDificultad.intermedio:
        return 'Intermedio';
      case NivelDificultad.avanzado:
        return 'Avanzado';
    }
  }

  Color _getNivelColor(NivelDificultad nivel) {
    switch (nivel) {
      case NivelDificultad.basico:
        return Colors.green;
      case NivelDificultad.intermedio:
        return Colors.orange;
      case NivelDificultad.avanzado:
        return Colors.red;
    }
  }
}