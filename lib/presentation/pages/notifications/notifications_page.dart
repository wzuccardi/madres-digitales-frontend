import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/domain/entities/alerta.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_page_scaffold.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/common/v2_card_list_tile.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});
  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<Alerta> alertas = const [];
  bool isLoading = true;
  String? errorMessage;
  StreamSubscription? _alertCreatedSub;
  StreamSubscription? _alertReadSub;
  StreamSubscription? _alertStatusSub;

  @override
  void initState() {
    super.initState();
    _fetchAlertas();
    _subscribeRealtime();
  }

  Future<void> _fetchAlertas() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final repo = ref.read(alertaRepositoryProvider);
    final result = await repo.fetchAlertas();
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        errorMessage = result.errorOrThrow.message;
        isLoading = false;
      });
      return;
    }
    final all = result.dataOrThrow;
    final unread = all.where((a) => a.estado != AlertaEstado.resuelta).toList();
    setState(() {
      alertas = unread;
      isLoading = false;
    });
  }

  Future<void> _subscribeRealtime() async {
    final ws = ref.read(webSocketServiceProvider);
    await ws.connect();
    _alertCreatedSub = ws.stream<Map<String, dynamic>>('alerta:created').listen((_) async {
      await _fetchAlertas();
    });
    _alertReadSub = ws.stream<Map<String, dynamic>>('alerta:read').listen((_) async {
      await _fetchAlertas();
    });
    _alertStatusSub = ws.stream<Map<String, dynamic>>('alerta:status').listen((_) async {
      await _fetchAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return V2PageScaffold(
      title: 'Notificaciones',
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: _fetchAlertas,
                  child: ListView(
                    children: [
                      ...alertas.map((a) => V2CardListTile(
                            title: a.titulo,
                            subtitle: a.id,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Marcar como leída',
                                  icon: const Icon(Icons.mark_email_read_outlined),
                                  onPressed: () async {
                                    final repo = ref.read(alertaRepositoryProvider);
                                    final r = await repo.marcarComoLeida(a.id);
                                    if (r.isFailure) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(r.errorOrThrow.message)),
                                      );
                                    }
                                    await _fetchAlertas();
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Resolver',
                                  icon: const Icon(Icons.check_circle_outline),
                                  onPressed: () async {
                                    final repo = ref.read(alertaRepositoryProvider);
                                    final r = await repo.resolverAlerta(a.id);
                                    if (r.isFailure) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(r.errorOrThrow.message)),
                                      );
                                    }
                                    await _fetchAlertas();
                                  },
                                ),
                              ],
                            ),
                          )),
                      if (alertas.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('Sin notificaciones pendientes')),
                        ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _alertCreatedSub?.cancel();
    _alertReadSub?.cancel();
    _alertStatusSub?.cancel();
    super.dispose();
  }
}
