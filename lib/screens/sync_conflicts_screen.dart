import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/logger_service.dart';
import '../services/api_service.dart';

/// Pantalla para resolver conflictos de sincronización
class SyncConflictsScreen extends StatefulWidget {
  const SyncConflictsScreen({super.key});

  @override
  State<SyncConflictsScreen> createState() => _SyncConflictsScreenState();
}

class _SyncConflictsScreenState extends State<SyncConflictsScreen> {
  final _logger = LoggerService();
  late final Dio _dio;
  
  List<Map<String, dynamic>> _conflicts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Usar la instancia compartida de ApiService para heredar el token
    _dio = ApiService().dioInstance;
    _loadConflicts();
  }

  Future<void> _loadConflicts() async {
    try {
      setState(() => _isLoading = true);

      final response = await _dio.get('/sync/conflicts');
      final data = response.data['data'] as List;

      setState(() {
        _conflicts = data.cast<Map<String, dynamic>>();
        _isLoading = false;
      });

      _logger.info('Conflictos cargados', data: {'count': _conflicts.length});
    } catch (e, stackTrace) {
      _logger.error('Error cargando conflictos', error: e, stackTrace: stackTrace);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando conflictos: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conflictos de Sincronización'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConflicts,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_conflicts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay conflictos pendientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Todos los datos están sincronizados',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _conflicts.length,
      itemBuilder: (context, index) {
        final conflict = _conflicts[index];
        return _buildConflictCard(conflict);
      },
    );
  }

  Widget _buildConflictCard(Map<String, dynamic> conflict) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getEntityTitle(conflict),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Tipo: ${conflict['entityType']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versión local: ${conflict['localVersion']} | Versión servidor: ${conflict['serverVersion']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showConflictDetails(conflict),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Ver detalles'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEntityTitle(Map<String, dynamic> conflict) {
    final entityType = conflict['entityType'];
    final localData = conflict['localData'] as Map<String, dynamic>;
    
    switch (entityType) {
      case 'gestante':
        return localData['nombre'] ?? 'Gestante sin nombre';
      case 'control':
        return 'Control Prenatal';
      case 'alerta':
        return 'Alerta';
      default:
        return entityType;
    }
  }

  void _showConflictDetails(Map<String, dynamic> conflict) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ConflictDetailsSheet(
            conflict: conflict,
            scrollController: scrollController,
            onResolved: () {
              Navigator.pop(context);
              _loadConflicts();
            },
          );
        },
      ),
    );
  }
}

/// Sheet para mostrar detalles del conflicto y resolverlo
class ConflictDetailsSheet extends StatefulWidget {
  final Map<String, dynamic> conflict;
  final ScrollController scrollController;
  final VoidCallback onResolved;

  const ConflictDetailsSheet({
    super.key,
    required this.conflict,
    required this.scrollController,
    required this.onResolved,
  });

  @override
  State<ConflictDetailsSheet> createState() => _ConflictDetailsSheetState();
}

class _ConflictDetailsSheetState extends State<ConflictDetailsSheet> {
  final _logger = LoggerService();
  late final Dio _dio;
  
  String _selectedResolution = 'local_wins';
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    // Usar la instancia compartida de ApiService para heredar el token
    _dio = ApiService().dioInstance;
  }

  @override
  Widget build(BuildContext context) {
    final localData = widget.conflict['localData'] as Map<String, dynamic>;
    final serverData = widget.conflict['serverData'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Título
          const Text(
            'Resolver Conflicto',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Selecciona qué versión deseas mantener',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Opciones de resolución
          RadioListTile<String>(
            title: const Text('Mantener cambios locales'),
            subtitle: const Text('Usar la versión de este dispositivo'),
            value: 'local_wins',
            groupValue: _selectedResolution,
            onChanged: (value) {
              setState(() => _selectedResolution = value!);
            },
          ),
          RadioListTile<String>(
            title: const Text('Usar cambios del servidor'),
            subtitle: const Text('Descartar cambios locales'),
            value: 'server_wins',
            groupValue: _selectedResolution,
            onChanged: (value) {
              setState(() => _selectedResolution = value!);
            },
          ),
          
          const Divider(height: 32),

          // Comparación de datos
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              children: [
                const Text(
                  'Comparación de datos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDataColumn(
                        'Local',
                        localData,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDataColumn(
                        'Servidor',
                        serverData,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isResolving ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isResolving ? null : _resolveConflict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isResolving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Resolver'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataColumn(String title, Map<String, dynamic> data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...data.entries.map((entry) {
          if (entry.key.startsWith('_') || entry.key == 'id') {
            return const SizedBox.shrink();
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.value?.toString() ?? 'null',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _resolveConflict() async {
    try {
      setState(() => _isResolving = true);

      await _dio.post(
        '/sync/conflicts/${widget.conflict['id']}/resolve',
        data: {
          'resolution': _selectedResolution,
        },
      );

      _logger.info('Conflicto resuelto', data: {
        'conflictId': widget.conflict['id'],
        'resolution': _selectedResolution,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conflicto resuelto exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }

      widget.onResolved();
    } catch (e, stackTrace) {
      _logger.error('Error resolviendo conflicto', error: e, stackTrace: stackTrace);
      
      setState(() => _isResolving = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resolviendo conflicto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

