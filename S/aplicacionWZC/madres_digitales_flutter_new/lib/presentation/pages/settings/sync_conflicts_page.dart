import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class SyncConflictsPage extends ConsumerStatefulWidget {
  const SyncConflictsPage({super.key});
  @override
  ConsumerState<SyncConflictsPage> createState() => _SyncConflictsPageState();
}

class _SyncConflictsPageState extends ConsumerState<SyncConflictsPage> {
  List<Map<String, dynamic>> _conflicts = const [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadConflicts();
  }
  Future<void> _loadConflicts() async {
    setState(() { _loading = true; });
    try {
      final offline = await ref.read(offlineServiceProvider.future);
      final list = offline.getConflicts();
      setState(() { _conflicts = list; _loading = false; });
    } catch (_) {
      setState(() { _loading = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conflictos de sincronización')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ..._conflicts.map((c) => Card(
                      child: ListTile(
                        title: Text('Recurso: ${c['resource'] ?? 'N/A'}'),
                        subtitle: Text('Detalle: ${c['detail'] ?? ''}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              tooltip: 'Aceptar local',
                              onPressed: () async {
                                final offline = await ref.read(offlineServiceProvider.future);
                                await offline.resolveConflictLocal(c);
                                await _loadConflicts();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.cloud),
                              tooltip: 'Aceptar remoto',
                              onPressed: () async {
                                final offline = await ref.read(offlineServiceProvider.future);
                                await offline.resolveConflictRemote(c);
                                await _loadConflicts();
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
                if (_conflicts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('Sin conflictos')),
                  ),
              ],
            ),
    );
  }
}
