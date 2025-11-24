import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/core/providers/usecase_providers.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'gestante_form_mejorado_screen.dart';

class GestantesScreen extends ConsumerStatefulWidget {
  const GestantesScreen({super.key});

  @override
  ConsumerState<GestantesScreen> createState() => _GestantesScreenState();
}

class _GestantesScreenState extends ConsumerState<GestantesScreen> {
  List<Gestante> _gestantesList = [];
  List<Gestante> _filteredGestantesList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
      final authState = ref.read(authProvider);
      final madrinaId = authState.user?.id;
      final usecase = ref.read(getGestantesUseCaseProvider);
      final result = await usecase(GetGestantesParams(limit: 100, offset: 0, madrinaId: madrinaId));
      if (result.isSuccess) {
        final gestantes = result.data!;
        setState(() {
          _gestantesList = gestantes;
          _filteredGestantesList = gestantes;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar gestantes: ${result.error}')),
          );
        }
      }
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
          final nombre = '${gestante.nombre} ${gestante.apellido}'.toLowerCase();
          final documento = gestante.documento.toLowerCase();
          final searchLower = query.toLowerCase();
          return nombre.contains(searchLower) || documento.contains(searchLower);
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

  Widget _buildGestanteCard(Gestante gestante) {
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
          '${gestante.nombre} ${gestante.apellido}'.trim().isEmpty ? 'Sin nombre' : '${gestante.nombre} ${gestante.apellido}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: ${gestante.id}'),
            Text('Doc: ${gestante.documento}'),
            if (gestante.telefono.isNotEmpty)
              Text('📞 ${gestante.telefono}'),
            if (gestante.eps != null)
              Text('🏥 ${gestante.eps}'),
            if (gestante.fechaProbableParto != null)
              Text('📅 FPP: ${_formatDate(gestante.fechaProbableParto!)}'),
          ],
        ),
        trailing: Icon(
          gestante.activa ? Icons.check_circle : Icons.cancel,
          color: gestante.activa ? Colors.green : Colors.grey,
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
