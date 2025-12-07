import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/theme/app_theme.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/presentation/pages/gestante/gestante_form_mejorado_page.dart';


class GestantesScreen extends ConsumerStatefulWidget {
  const GestantesScreen({super.key});

  @override
  ConsumerState<GestantesScreen> createState() => _GestantesScreenState();
}

class _GestantesScreenState extends ConsumerState<GestantesScreen> {
  late final Future<List<Gestante>> _futureGestantes;

  @override
  void initState() {
    super.initState();
    final svc = ref.read(gestanteServiceProvider);
    _futureGestantes = svc.getGestantes(page: 1, limit: 40);
  }

  Future<void> _reload() async {
    final svc = ref.read(gestanteServiceProvider);
    setState(() {
      _futureGestantes = svc.getGestantes(page: 1, limit: 40);
    });
  }

  Future<void> _editarGestante(BuildContext context, Gestante gestante) async {
    // Convertir Gestante a Map para pasar al formulario
    final gestanteData = {
      'id': gestante.id,
      'documento': gestante.documento,
      'tipo_documento': gestante.tipoDocumento ?? 'cedula',
      'nombre': gestante.nombre,
      'telefono': gestante.telefono,
      'direccion': gestante.direccion,
      'municipio_id': gestante.municipioId,
      'eps': gestante.eps,
      'regimen_salud': gestante.regimen,
      'activa': gestante.activa,
      'riesgo_alto': gestante.riesgoAlto,
      'fecha_nacimiento': gestante.fechaNacimiento?.toIso8601String(),
      'fecha_ultima_menstruacion': gestante.fechaUltimaMestruacion?.toIso8601String(),
      'fecha_probable_parto': gestante.fechaProbableParto?.toIso8601String(),
      'coordenadas': gestante.coordenadas,
      'numero_embarazo': gestante.numeroEmbarazo ?? 1,
      'createdAt': gestante.createdAt.toIso8601String(),
    };

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GestanteFormMejoradoScreen(gestante: gestanteData),
      ),
    );

    if (result == true) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestantes'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Gestante>>(
        future: _futureGestantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? const <Gestante>[];
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pregnant_woman, size: 64, color: AppTheme.primaryColor),
                  const SizedBox(height: 16),
                  Text('Gestión de Gestantes', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('No hay gestantes registradas', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pregnant_woman, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Total: ${list.length}', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                // Resumen por municipio (Top 5)
                _ResumenMunicipios(gestantes: list),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final g = list[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text((index + 1).toString())),
                        title: Text(g.nombre.isNotEmpty ? g.nombre : 'Sin nombre'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.documento),
                            if (g.telefono.isNotEmpty)
                              Text('Tel: ${g.telefono}', style: const TextStyle(fontSize: 12)),
                            if (g.fechaUltimaMestruacion != null)
                              Text(
                                'FUM: ${g.fechaUltimaMestruacion!.day}/${g.fechaUltimaMestruacion!.month}/${g.fechaUltimaMestruacion!.year}',
                                style: const TextStyle(fontSize: 12, color: Colors.blue),
                              )
                            else
                              const Text(
                                'FUM: No registrada',
                                style: TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (g.riesgoAlto == true)
                              const Icon(Icons.warning, color: Colors.orange),
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                              onPressed: () => _editarGestante(context, g),
                              tooltip: 'Editar gestante',
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GestanteFormMejoradoScreen()),
          );
          if (result == true) {
            await _reload();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Gestante'),
      ),
    );
  }
}

class _ResumenMunicipios extends StatelessWidget {
  const _ResumenMunicipios({required this.gestantes});
  final List<Gestante> gestantes;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final g in gestantes) {
      final muni = (g.municipio ?? '').trim();
      if (muni.isEmpty) continue;
      counts[muni] = (counts[muni] ?? 0) + 1;
    }
    final items = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = items.take(5).toList();
    if (top.isEmpty) {
      return const SizedBox.shrink();
    }
    final max = top.first.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top municipios', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final e in top)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: max == 0 ? 0 : (e.value / max).clamp(0.0, 1.0),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${e.key} (${e.value})', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}
