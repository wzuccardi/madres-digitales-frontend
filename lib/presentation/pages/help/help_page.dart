import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class HelpPage extends ConsumerStatefulWidget {
  const HelpPage({super.key});
  @override
  ConsumerState<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends ConsumerState<HelpPage> {
  bool _loading = true;
  String? _error;
  String _content = '';
  @override
  void initState() {
    super.initState();
    _loadContent();
  }
  Future<void> _loadContent() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ref.read(apiServiceProvider);
      final resp = await api.get<Map<String, dynamic>>('/api/help');
      if (resp.success && resp.data != null) {
        final obj = api.extractObject(resp.data);
        final text = (obj['content'] ?? obj['help'] ?? obj['data'] ?? '').toString();
        setState(() { _content = text.isNotEmpty ? text : 'Ayuda y soporte'; _loading = false; });
      } else {
        setState(() { _content = 'Ayuda y soporte'; _loading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error cargando ayuda'; _loading = false; });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 8),
                      ElevatedButton(onPressed: _loadContent, child: const Text('Reintentar')),
                    ],
                  )
                : SingleChildScrollView(child: Text(_content)),
      ),
    );
  }
}
