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
  final int limit = 20;
  List<Map<String, String>> _municipios = [];
  String? _selectedMunicipioId;
  bool _loadingMunicipios = true;

  @override
  void initState() {
    super.initState();
    _fetchGestantes(reset: true);
    _loadMunicipios();
  }

  Future<void> _fetchGestantes({bool reset = false}) async {
    setState(() {
      if (reset) page = 1;
      isLoading = true;
      if (reset) gestantes = const [];
      errorMessage = null;
    });
    final repo = ref.read(gestanteRepositoryProvider);
    final result = await repo.getGestantes(limit: limit, offset: (page - 1) * limit);
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

  Future<void> _loadMore() async {
    page += 1;
    await _fetchGestantes();
  }

  @override
  Widget build(BuildContext context) {
    final selectedNombre = _selectedMunicipioId == null
        ? null
        : (_municipios.firstWhere(
              (m) => m['id'] == _selectedMunicipioId,
              orElse: () => {'id': _selectedMunicipioId!, 'nombre': ''},
            ))['nombre'];
    final visibles = (_selectedMunicipioId == null)
        ? gestantes
        : gestantes.where((g) {
            if (g.municipioId != null && g.municipioId == _selectedMunicipioId) return true;
            if (selectedNombre != null && selectedNombre.isNotEmpty && (g.municipio ?? '').toLowerCase() == selectedNombre.toLowerCase()) return true;
            return false;
          }).toList();

    return V2PageScaffold(
      title: 'Gestantes',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add_alt_1),
          tooltip: 'Nueva Gestante',
          onPressed: () => context.go('/gestantes/nueva'),
        ),
      ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: () => _fetchGestantes(reset: true),
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _loadingMunicipios
                            ? const Center(child: CircularProgressIndicator())
                            : V2FilterBar(
                                label: 'Municipio',
                                child: DropdownButton<String?>(
                                  value: _selectedMunicipioId,
                                  items: [
                                    const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                                    ..._municipios.map((m) => DropdownMenuItem<String?>(value: m['id'], child: Text(m['nombre']!))),
                                  ],
                                  onChanged: (v) => setState(() => _selectedMunicipioId = v),
                                ),
                              ),
                      ),
                      ...visibles.map((g) => V2CardListTile(
                            title: g.nombre,
                            subtitle: '${g.id} · ${(g.municipio ?? '').isNotEmpty ? g.municipio! : (g.municipioId ?? '')}',
                            onTap: () => context.go('/gestantes/editar/${g.id}'),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: ElevatedButton(onPressed: _loadMore, child: const Text('Cargar más')),
                      ),
                    ],
                  ),
                ),
    );
  }
}
