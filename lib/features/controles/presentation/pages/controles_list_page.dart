import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'control_form_page.dart';
import '../../../../../providers/service_providers.dart';

class ControlesListPage extends ConsumerStatefulWidget {
  const ControlesListPage({super.key});
  @override
  ConsumerState<ControlesListPage> createState() => _ControlesListPageState();
}

class _ControlesListPageState extends ConsumerState<ControlesListPage> {
  List<dynamic> controles = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchControles();
  }

  Future<void> fetchControles() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/controles');
      setState(() {
        controles = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar controles: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controles Prenatales')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ControlFormPage()),
          ).then((_) => fetchControles());
        },
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  itemCount: controles.length,
                  itemBuilder: (context, index) {
                    final control = controles[index];
                    return ListTile(
                      title: Text(control['fecha'] ?? 'Sin fecha'),
                      subtitle: Text(control['descripcion'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final apiService = ref.read(apiServiceProvider);
                          await apiService.delete('/controles/${control['id']}');
                          fetchControles();
                        },
                      ),
                      // Puedes agregar navegación al formulario de edición aquí
                    );
                  },
                ),
    );
  }
}
