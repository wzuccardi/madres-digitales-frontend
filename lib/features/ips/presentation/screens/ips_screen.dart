import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/data/services/ips_service.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_page_scaffold.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_card_list_tile.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_filter_bar.dart';

class IpsScreen extends ConsumerStatefulWidget {
  const IpsScreen({super.key});
  @override
  ConsumerState<IpsScreen> createState() => _IpsScreenState();
}

class _IpsScreenState extends ConsumerState<IpsScreen> {
  List<IPS> ips = const [];
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, String>> _municipios = [];
  String? _selectedMunicipioId;
  bool _loadingMunicipios = true;

  @override
  void initState() {
    super.initState();
    _fetchIps();
    _loadMunicipios();
  }

  Future<void> _fetchIps() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final service = ref.read(ipsServiceProvider);
      final data = await service.getAllIPS();
      setState(() {
        ips = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMunicipios() async {
    setState(() { _loadingMunicipios = true; });
    try {
      final ms = ref.read(municipioServiceProvider);
      final list = await ms.getMunicipios(activo: true, limit: 200);
      setState(() {
        _municipios = list.map((m) => {'id': m.id, 'nombre': m.nombre}).toList();
        _loadingMunicipios = false;
      });
    } catch (_) {
      setState(() { _loadingMunicipios = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return V2PageScaffold(
      title: 'IPS',
      actions: [
        IconButton(
          icon: const Icon(Icons.add_business),
          tooltip: 'Nueva IPS',
          onPressed: () => context.go('/ips/nuevo'),
        ),
      ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchIps,
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
                      ...ips.where((i) {
                        if (_selectedMunicipioId == null) return true;
                        return i.municipioId == _selectedMunicipioId;
                      }).map((i) => V2CardListTile(
                            title: i.nombre,
                            subtitle: '${i.id} · ${(i.municipioId ?? '')}',
                            onTap: () => context.go('/ips/editar/${i.id}'),
                          )),
                    ],
                  ),
                ),
    );
  }
}