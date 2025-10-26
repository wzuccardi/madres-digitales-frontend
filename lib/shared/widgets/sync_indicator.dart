import 'package:flutter/material.dart';
import '../../services/sync_service.dart';
import '../../services/database/daos/sync_queue_dao.dart';

/// Widget que muestra el estado de sincronización y conectividad
class SyncIndicator extends StatefulWidget {
  const SyncIndicator({super.key});

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> {
  final _syncService = SyncService();
  final _syncQueueDao = SyncQueueDao();
  
  bool _isConnected = true;
  bool _isSyncing = false;
  int _pendingItems = 0;
  DateTime? _lastSyncTime;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _listenToStreams();
  }

  void _loadStatus() async {
    final status = await _syncService.getStatus();
    if (mounted) {
      setState(() {
        _pendingItems = status['pendingItems'] ?? 0;
        _isSyncing = status['isSyncing'] ?? false;
        if (status['lastSyncTimestamp'] != null) {
          _lastSyncTime = DateTime.parse(status['lastSyncTimestamp']);
        }
      });
    }
  }

  void _listenToStreams() {
    // Escuchar cambios de conectividad
    _syncService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });

    // Escuchar cambios de sincronización
    _syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isSyncing = status.isSyncing;
          if (status.lastSyncTime != null) {
            _lastSyncTime = status.lastSyncTime;
          }
        });
        _loadStatus(); // Recargar contadores
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSyncDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_pendingItems > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_pendingItems',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (_isSyncing) {
      return const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (!_isConnected) {
      return const Icon(
        Icons.cloud_off,
        size: 16,
        color: Colors.white,
      );
    }

    if (_pendingItems > 0) {
      return const Icon(
        Icons.cloud_upload,
        size: 16,
        color: Colors.white,
      );
    }

    return const Icon(
      Icons.cloud_done,
      size: 16,
      color: Colors.white,
    );
  }

  Color _getBackgroundColor() {
    if (_isSyncing) {
      return Colors.blue;
    }

    if (!_isConnected) {
      return Colors.grey;
    }

    if (_pendingItems > 0) {
      return Colors.orange;
    }

    return Colors.green;
  }

  String _getStatusText() {
    if (_isSyncing) {
      return 'Sincronizando...';
    }

    if (!_isConnected) {
      return 'Sin conexión';
    }

    if (_pendingItems > 0) {
      return 'Pendiente';
    }

    return 'Sincronizado';
  }

  void _showSyncDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado de Sincronización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(
              'Conectividad',
              _isConnected ? 'Conectado' : 'Sin conexión',
              _isConnected ? Icons.wifi : Icons.wifi_off,
              _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Estado',
              _isSyncing ? 'Sincronizando...' : 'Inactivo',
              _isSyncing ? Icons.sync : Icons.check_circle,
              _isSyncing ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'Items pendientes',
              '$_pendingItems',
              Icons.cloud_upload,
              _pendingItems > 0 ? Colors.orange : Colors.green,
            ),
            if (_lastSyncTime != null) ...[
              const SizedBox(height: 12),
              _buildStatusRow(
                'Última sincronización',
                _formatLastSync(_lastSyncTime!),
                Icons.access_time,
                Colors.grey,
              ),
            ],
          ],
        ),
        actions: [
          if (!_isSyncing && _isConnected)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _syncNow();
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sincronizar ahora'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatLastSync(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Hace unos segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }

  void _syncNow() async {
    final result = await _syncService.syncAll();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

/// Widget compacto de indicador de sincronización para AppBar
class CompactSyncIndicator extends StatefulWidget {
  const CompactSyncIndicator({super.key});

  @override
  State<CompactSyncIndicator> createState() => _CompactSyncIndicatorState();
}

class _CompactSyncIndicatorState extends State<CompactSyncIndicator> {
  final _syncService = SyncService();
  bool _isConnected = true;
  bool _isSyncing = false;
  int _pendingItems = 0;

  @override
  void initState() {
    super.initState();
    _loadStatus();
    _listenToStreams();
  }

  void _loadStatus() async {
    final status = await _syncService.getStatus();
    if (mounted) {
      setState(() {
        _pendingItems = status['pendingItems'] ?? 0;
        _isSyncing = status['isSyncing'] ?? false;
      });
    }
  }

  void _listenToStreams() {
    _syncService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });

    _syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _isSyncing = status.isSyncing;
        });
        _loadStatus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            _getIcon(),
            color: _getColor(),
          ),
          onPressed: () {
            // Mostrar diálogo de sincronización
            showDialog(
              context: context,
              builder: (context) => const SyncIndicator(),
            );
          },
        ),
        if (_pendingItems > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _pendingItems > 99 ? '99+' : '$_pendingItems',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getIcon() {
    if (_isSyncing) return Icons.sync;
    if (!_isConnected) return Icons.cloud_off;
    if (_pendingItems > 0) return Icons.cloud_upload;
    return Icons.cloud_done;
  }

  Color _getColor() {
    if (_isSyncing) return Colors.blue;
    if (!_isConnected) return Colors.grey;
    if (_pendingItems > 0) return Colors.orange;
    return Colors.green;
  }
}

