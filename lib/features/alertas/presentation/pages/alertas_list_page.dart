import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'alerta_form_page.dart';
import '../../../../../providers/service_providers.dart';

class AlertasListPage extends ConsumerStatefulWidget {
  const AlertasListPage({super.key});
  @override
  ConsumerState<AlertasListPage> createState() => _AlertasListPageState();
}

class _AlertasListPageState extends ConsumerState<AlertasListPage> {
  List<dynamic> alertas = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAlertas();
  }

  Future<void> fetchAlertas() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/alertas');
      setState(() {
        alertas = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar alertas: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AlertaFormPage()),
          ).then((_) => fetchAlertas());
        },
        child: const Icon(Icons.add_alert),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: alertas.length,
                  itemBuilder: (context, index) {
                    final alerta = alertas[index];
                    return ListTile(
                      title: Text(alerta['titulo'] ?? 'Sin título'),
                      subtitle: Text(alerta['descripcion'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final apiService = ref.read(apiServiceProvider);
                          await apiService.delete('/alertas/${alerta['id']}');
                          fetchAlertas();
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AlertaFormPage(alerta: alerta)),
                        ).then((_) => fetchAlertas());
                      },
                    );
                  },
                ),
    );
  }
}
