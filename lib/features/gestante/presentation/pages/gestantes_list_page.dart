import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_page_scaffold.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_card_list_tile.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_filter_bar.dart';

class GestantesListPage extends ConsumerStatefulWidget {
  const GestantesListPage({super.key});
  @override
  ConsumerState<GestantesListPage> createState() => _GestantesListPageState();
}

class _GestantesListPageState extends ConsumerState<GestantesListPage> {
  List<Gestante> gestantes = const [];
  bool isLoading = true;
  String? errorMessage;
  int page = 1;
  final int limit = 40;
  List<Map<String, String>> _municipios = [];
  List<Map<String, String>> _madrinas = [];
  String? _selectedMunicipioId;
  String? _selectedMadrinaId;
  bool _loadingMunicipios = true;
  bool _loadingMadrinas = true;

  @override
  void initState() {
    super.initState();
    _fetchGestantes(reset: true);
    _loadMunicipios();
    _loadMadrinas();
  }

  Future<void> _fetchGestantes({bool reset = false}) async {
    setState(() {
      if (reset) page = 1;
      isLoading = true;
      if (reset) gestantes = const [];
      errorMessage = null;
    });
    
    // Construir filtros para el backend
    final filters = <String, dynamic>{};
    if (_selectedMunicipioId != null) {
      filters['municipio_id'] = _selectedMunicipioId;
    }
    if (_selectedMadrinaId != null) {
      filters['madrina_id'] = _selectedMadrinaId;
    }
    
    final repo = ref.read(gestanteRepositoryProvider);
    final result = await repo.getGestantes(
      limit: limit, 
      offset: (page - 1) * limit,
      filters: filters,
    );
    
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        errorMessage = result.errorOrThrow.message;
        isLoading = false;
      });
      return;
    }
    final data = result.dataOrThrow;
    setState(() {
      gestantes = reset ? data : [...gestantes, ...data];
      isLoading = false;
    });
  }

  Future<void> _loadMunicipios() async {
    setState(() {
      _loadingMunicipios = true;
    });
    try {
      final ms = ref.read(municipioServiceProvider);
      final list = await ms.getMunicipios(activo: true, limit: 200);
      if (!mounted) return;
      setState(() {
        _municipios = list.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
        _loadingMunicipios = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMunicipios = false;
      });
    }
  }

  Future<void> _loadMadrinas() async {
    setState(() {
      _loadingMadrinas = true;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get<Map<String, dynamic>>('/api/usuarios');
      
      if (response.success && response.data != null) {
        final data = response.data!;
        final usuarios = data['data'] as List<dynamic>? ?? [];
        
        // Filtrar solo madrinas activas
        final madrinas = usuarios
            .where((u) => u['rol'] == 'madrina' && u['activo'] == true)
            .map((u) => {
                  'id': u['id'] as String,
                  'nombre': u['nombre'] as String? ?? u['email'] as String,
                })
            .toList();
        
        if (!mounted) return;
        setState(() {
          _madrinas = madrinas;
          _loadingMadrinas = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMadrinas = false;
      });
    }
  }

  Future<void> _loadMore() async {
    page += 1;
    await _fetchGestantes();
  }

  void _onMunicipioChanged(String? value) {
    setState(() {
      _selectedMunicipioId = value;
    });
    _fetchGestantes(reset: true);
  }

  void _onMadrinaChanged(String? value) {
    setState(() {
      _selectedMadrinaId = value;
    });
    _fetchGestantes(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return V2PageScaffold(
      title: 'Gestantes',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1),
          tooltip: 'Nueva Gestante',
          onPressed: () => context.go('/gestantes/nueva'),
        ),
      ],
      body: isLoading && gestantes.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null && gestantes.isEmpty
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: () => _fetchGestantes(reset: true),
                  child: ListView(
                    children: [
                      // Filtro por Municipio
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _loadingMunicipios
                            ? const Center(child: CircularProgressIndicator())
                            : V2FilterBar(
                                label: 'Municipio',
                                child: DropdownButton<String?>(
                                  value: _selectedMunicipioId,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                                    ..._municipios.map((m) => DropdownMenuItem<String?>(
                                          value: m['id'],
                                          child: Text(m['nombre']!),
                                        )),
                                  ],
                                  onChanged: _onMunicipioChanged,
                                ),
                              ),
                      ),
                      // Filtro por Madrina
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _loadingMadrinas
                            ? const Center(child: CircularProgressIndicator())
                            : V2FilterBar(
                                label: 'Madrina',
                                child: DropdownButton<String?>(
                                  value: _selectedMadrinaId,
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String?>(value: null, child: Text('Todas')),
                                    ..._madrinas.map((m) => DropdownMenuItem<String?>(
                                          value: m['id'],
                                          child: Text(m['nombre']!),
                                        )),
                                  ],
                                  onChanged: _onMadrinaChanged,
                                ),
                              ),
                      ),
                      // Mostrar contador de resultados
                      if (gestantes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            'Mostrando ${gestantes.length} gestante${gestantes.length != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      // Lista de gestantes
                      ...gestantes.map((g) => V2CardListTile(
                            title: g.nombre,
                            subtitle: '${g.id} · ${(g.municipio ?? '').isNotEmpty ? g.municipio! : (g.municipioId ?? '')}',
                            onTap: () => context.go('/gestantes/editar/${g.id}'),
                          )),
                      // Botón cargar más
                      if (gestantes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _loadMore,
                                  child: const Text('Cargar más'),
                                ),
                        ),
                      // Mensaje si no hay resultados
                      if (gestantes.isEmpty && !isLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No se encontraron gestantes con los filtros seleccionados'),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
