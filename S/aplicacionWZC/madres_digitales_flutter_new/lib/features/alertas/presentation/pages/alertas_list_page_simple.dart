import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

class AlertasListPageSimple extends ConsumerStatefulWidget {
  const AlertasListPageSimple({super.key});
  
  @override
  ConsumerState<AlertasListPageSimple> createState() => _AlertasListPageSimpleState();
}

class _AlertasListPageSimpleState extends ConsumerState<AlertasListPageSimple> {
  List<Map<String, dynamic>> alertas = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlertas();
  }

  Future<void> _loadAlertas() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response = await apiService.get('/alertas?_t=$timestamp');

      if (!mounted) return;

      List<Map<String, dynamic>> alertasList = [];
      
      // Procesar la respuesta
      if (response.data is List) {
        alertasList = List<Map<String, dynamic>>.from(response.data);
      } else if (response.data is Map) {
        final dataMap = response.data as Map<String, dynamic>;
        if (dataMap.containsKey('alertas') && dataMap['alertas'] is List) {
          alertasList = List<Map<String, dynamic>>.from(dataMap['alertas']);
        }
      }

      setState(() {
        alertas = alertasList;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alertas (${alertas.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlertas,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAlertas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : alertas.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No hay alertas', style: TextStyle(fontSize: 18)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAlertas,
                            child: const Text('Recargar'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: alertas.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final alerta = alertas[index];
                        
                        // Extraer datos con fallbacks
                        final id = alerta['id'] ?? 'sin-id';
                        final tipo = alerta['tipo_alerta'] ?? alerta['tipo'] ?? 'Sin tipo';
                        final prioridad = alerta['nivel_prioridad'] ?? alerta['prioridad'] ?? 'media';
                        final mensaje = alerta['mensaje'] ?? 'Sin mensaje';
                        final resuelta = alerta['resuelta'] == true;
                        final fecha = alerta['fecha_creacion'] ?? alerta['fechaCreacion'] ?? '';
                        
                        // Determinar color
                        Color color = Colors.grey;
                        if (prioridad.toString().toLowerCase().contains('critica')) {
                          color = Colors.red;
                        } else if (prioridad.toString().toLowerCase().contains('alta')) {
                          color = Colors.orange;
                        } else if (prioridad.toString().toLowerCase().contains('media')) {
                          color = Colors.yellow.shade700;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              resuelta ? Icons.check_circle : Icons.warning,
                              color: resuelta ? Colors.green : color,
                              size: 32,
                            ),
                            title: Text(
                              mensaje,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: resuelta ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Tipo: $tipo'),
                                Text(
                                  'Prioridad: $prioridad',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (fecha.isNotEmpty)
                                  Text(
                                    'Fecha: $fecha',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                              ],
                            ),
                            trailing: !resuelta
                                ? IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () async {
                                      try {
                                        final apiService = ref.read(apiServiceProvider);
                                        await apiService.put('/alertas/$id', data: {'resuelta': true});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Alerta resuelta')),
                                        );
                                        _loadAlertas();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('❌ Error: $e')),
                                        );
                                      }
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
}
