// Pantalla de gestantes simplificada basada en medicos_screen.dart
// Usa datos dinámicos para evitar problemas de mapeo

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../providers/service_providers.dart';

import 'gestante_form_mejorado_screen.dart';

class GestantesScreen extends ConsumerStatefulWidget {
  const GestantesScreen({super.key});

  @override
  ConsumerState<GestantesScreen> createState() => _GestantesScreenState();
}

class _GestantesScreenState extends ConsumerState<GestantesScreen> {
  late final ApiService _apiService;
  List<dynamic> _gestantesList = [];
  List<dynamic> _filteredGestantesList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = ref.read(apiServiceProvider);
    _loadGestantes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadGestantes() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get('/gestantes');

      // Manejar estructura de respuesta del backend igual que IPS
      List<dynamic> gestantes = [];
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        // Estructura: { success: true, data: { gestantes: [...], total: ... } }
        if (responseMap['data'] is Map && responseMap['data']['gestantes'] != null) {
          gestantes = responseMap['data']['gestantes'] as List<dynamic>;
        }
        // Estructura: { success: true, data: [...] }
        else if (responseMap['success'] == true && responseMap['data'] is List) {
          gestantes = responseMap['data'] as List<dynamic>;
        }
      } else if (response.data is List) {
        // La respuesta es directamente una lista
        gestantes = response.data as List<dynamic>;
      }

      setState(() {
        _gestantesList = gestantes;
        _filteredGestantesList = gestantes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar gestantes: $e')),
        );
      }
    }
  }

  void _filterGestantes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredGestantesList = _gestantesList;
      } else {
        _filteredGestantesList = _gestantesList.where((gestante) {
          final nombre = gestante['nombre']?.toString().toLowerCase() ?? '';
          final documento = gestante['documento']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nombre.contains(searchLower) ||
                 documento.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestantes'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGestantes,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o documento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterGestantes('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterGestantes,
            ),
          ),

          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  '${_filteredGestantesList.length} gestantes encontradas',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Lista de gestantes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredGestantesList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pregnant_woman_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No hay gestantes registradas'
                                  : 'No se encontraron gestantes',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGestantesList.length,
                        itemBuilder: (context, index) {
                          final gestante = _filteredGestantesList[index];
                          return _buildGestanteCard(gestante);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GestanteFormMejoradoScreen()),
          );
          if (result == true) _loadGestantes();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Gestante'),
      ),

    );
  }

  Widget _buildGestanteCard(dynamic gestante) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink[100],
          child: const Icon(
            Icons.pregnant_woman,
            color: Colors.pink,
          ),
        ),
        title: Text(
          gestante['nombre'] ?? 'Sin nombre',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${gestante['id'] ?? 'N/A'}'),
            Text('Doc: ${gestante['documento'] ?? 'N/A'}'),
            if (gestante['telefono'] != null)
              Text('📞 ${gestante['telefono']}'),
            if (gestante['eps'] != null)
              Text('🏥 ${gestante['eps']}'),
            if (gestante['fecha_probable_parto'] != null)
              Text('📅 FPP: ${_formatDate(DateTime.parse(gestante['fecha_probable_parto']))}'),
          ],
        ),
        trailing: Icon(
          gestante['activa'] ? Icons.check_circle : Icons.cancel,
          color: gestante['activa'] ? Colors.green : Colors.grey,
          size: 20,
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}