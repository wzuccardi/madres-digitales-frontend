import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'control_form_page.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

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
      final response = await apiService.get<Map<String, dynamic>>('/controles', options: Options(headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0',
      }));
      final data = apiService.extractData(response.data);
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        final inner = data['controles'];
        if (inner is List) list = inner;
      }
      setState(() {
        controles = list;
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
                    final fecha = control['fecha_control']?.toString() ?? control['fecha']?.toString() ?? 'Sin fecha';
                    final obs = control['observaciones']?.toString() ?? control['descripcion']?.toString() ?? '';
                    return ListTile(
                      title: Text(fecha),
                      subtitle: Text(obs),
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
