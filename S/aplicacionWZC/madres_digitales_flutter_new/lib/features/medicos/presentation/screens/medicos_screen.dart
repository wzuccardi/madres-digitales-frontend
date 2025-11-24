import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_page_scaffold.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_card_list_tile.dart';

class MedicosScreen extends ConsumerStatefulWidget {
  const MedicosScreen({super.key});
  @override
  ConsumerState<MedicosScreen> createState() => _MedicosScreenState();
}

class _MedicosScreenState extends ConsumerState<MedicosScreen> {
  List<dynamic> medicos = const [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMedicos();
  }

  Future<void> _fetchMedicos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final service = ref.read(medicoServiceProvider);
      final data = await service.getAllMedicos();
      setState(() {
        medicos = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return V2PageScaffold(
      title: 'Médicos',
      actions: [
        IconButton(
          icon: const Icon(Icons.person_add),
          tooltip: 'Nuevo Médico',
          onPressed: () => context.go('/medicos/nuevo'),
        ),
      ],
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchMedicos,
                  child: ListView.builder(
                    itemCount: medicos.length,
                    itemBuilder: (context, index) {
                      final m = medicos[index] as Map<String, dynamic>;
                      return V2CardListTile(
                        title: m['nombre']?.toString() ?? '-',
                        subtitle: m['id']?.toString() ?? '',
                        onTap: () {
                          final id = m['id']?.toString();
                          if (id != null && id.isNotEmpty) {
                            context.go('/medicos/editar/$id');
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}