// Centro de Notificaciones Avanzado con Alertas Automáticas
// Integra el sistema de alertas automáticas del backend

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/alerta_service.dart';  // Corrección: Importar AlertaService (incluye el modelo Alerta)
import '../services/api_service.dart';  // Corrección: Importar ApiService
import '../services/notification_service.dart';  // Importar NotificationService
import '../utils/logger.dart';  // Corrección: Importar logger
import '../shared/widgets/app_bar_with_logo.dart';

class CentroNotificacionesScreen extends ConsumerStatefulWidget {
  const CentroNotificacionesScreen({super.key});

  @override
  ConsumerState<CentroNotificacionesScreen> createState() => _CentroNotificacionesScreenState();
}

class _CentroNotificacionesScreenState extends ConsumerState<CentroNotificacionesScreen>
    with SingleTickerProviderStateMixin {
  
  List<Alerta> _alertas = [];  // Corrección: Usar Alerta
  List<Alerta> _alertasCriticas = [];  // Corrección: Usar Alerta
  List<Alerta> _alertasAltas = [];  // Corrección: Usar Alerta
  List<Alerta> _alertasMedias = [];  // Corrección: Usar Alerta
  bool _isLoading = true;
  late TabController _tabController;
  Timer? _sincronizacionTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _cargarAlertas();
    
    // ✅ Sincronizar estado con backend periódicamente
    _sincronizacionTimer = Timer.periodic(const Duration(minutes: 2), (_) => _sincronizarLectura());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sincronizacionTimer?.cancel();
    super.dispose();
  }

  Future<void> _cargarAlertas() async {
    setState(() => _isLoading = true);

    try {
      // Usar el servicio específico
      final apiService = ref.read(apiServiceProvider);  // Usar el provider
      final alertaService = AlertaService(apiService);  // Corrección: Crear instancia de AlertaService
      
      final alertas = await alertaService.obtenerAlertas();  // Corrección: Usar método correcto
      
      // Filtrar por tipo (usando el campo tipo en lugar de prioridad)
      final criticas = alertas.where((a) =>
        a.tipo == 'urgent' && !a.leida).toList();  // Corrección: Usar propiedades correctas
      final altas = alertas.where((a) =>
        a.tipo == 'warning' && !a.leida).toList();  // Corrección: Usar propiedades correctas
      final medias = alertas.where((a) =>
        (a.tipo == 'info' || a.tipo == 'warning') && !a.leida).toList();  // Corrección: Usar propiedades correctas
      
      setState(() {
        _alertas = alertas.where((a) => !a.leida).toList();  // Corrección: Usar propiedad correcta
        _alertasCriticas = criticas;
        _alertasAltas = altas;
        _alertasMedias = medias;
        _isLoading = false;
      });

      // Mostrar notificación si hay alertas críticas
      if (criticas.isNotEmpty && mounted) {
        _mostrarNotificacionCritica(criticas.length);
      }
    } catch (e) {
      appLogger.error('Error cargando alertas', error: e);  // Corrección: Usar logger
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar alertas: $e')),
        );
      }
    }
  }

  void _mostrarNotificacionCritica(int cantidad) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Text('⚠️ $cantidad alerta${cantidad > 1 ? 's' : ''} crítica${cantidad > 1 ? 's' : ''}'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'VER',
          textColor: Colors.white,
          onPressed: () {
            _tabController.animateTo(1); // Ir a tab de críticas
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithLogo(
        title: 'Centro de Notificaciones',
        actions: [
          // Badge con contador de alertas críticas
          if (_alertasCriticas.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.notifications_active, size: 28),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_alertasCriticas.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarAlertas,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.list),
                  const SizedBox(width: 8),
                  Text('Todas (${_alertas.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Críticas (${_alertasCriticas.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text('Altas (${_alertasAltas.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Medias (${_alertasMedias.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAlertasList(_alertas, 'Todas'),
                _buildAlertasList(_alertasCriticas, 'Críticas'),
                _buildAlertasList(_alertasAltas, 'Altas'),
                _buildAlertasList(_alertasMedias, 'Medias'),
              ],
            ),
    );
  }

  Widget _buildAlertasList(List<Alerta> alertas, String tipo) {  // Corrección: Usar Alerta
    if (alertas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tipo == 'Críticas' ? Icons.check_circle :
              tipo == 'Altas' ? Icons.check_circle_outline :
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay alertas $tipo',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarAlertas,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alertas.length,
        itemBuilder: (context, index) {
          final alerta = alertas[index];
          return _buildAlertaCard(alerta);
        },
      ),
    );
  }

  Widget _buildAlertaCard(Alerta alerta) {  // Corrección: Usar Alerta
    final isCritica = alerta.tipo == 'urgent';  // Corrección: Usar propiedad correcta
    final isAlta = alerta.tipo == 'warning';  // Corrección: Usar propiedad correcta
    
    Color cardColor = isCritica ? Colors.red[50]! :
                     isAlta ? Colors.orange[50]! :
                     Colors.blue[50]!;
    
    Color iconColor = isCritica ? Colors.red :
                     isAlta ? Colors.orange :
                     Colors.blue;
    
    IconData icon = isCritica ? Icons.error :
                   isAlta ? Icons.warning :
                   Icons.info;

    return Card(
      color: cardColor,
      elevation: isCritica ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: iconColor,
          width: isCritica ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _mostrarDetalleAlerta(alerta),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con prioridad
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alerta.tipo.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                        Text(
                          'Tipo: ${alerta.tipo.toUpperCase()}',  // Corrección: Usar propiedad correcta
                          style: TextStyle(
                            fontSize: 12,
                            color: iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCritica)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Descripción
              Text(
                alerta.mensaje,  // Corrección: Usar propiedad correcta
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Fecha
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatFecha(alerta.fechaCreacion),  // Corrección: Usar propiedad correcta
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDetalleAlerta(Alerta alerta) {  // Corrección: Usar Alerta
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              alerta.tipo == 'urgent' ? Icons.error :  // Corrección: Usar propiedad correcta
              alerta.tipo == 'warning' ? Icons.warning :
              Icons.info,
              color: alerta.tipo == 'urgent' ? Colors.red :  // Corrección: Usar propiedad correcta
                     alerta.tipo == 'warning' ? Colors.orange :
                     Colors.blue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                alerta.tipo.toUpperCase(),
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetalleRow('Tipo', alerta.tipo.toUpperCase()),  // Corrección: Usar propiedad correcta
              _buildDetalleRow('Título', alerta.titulo),  // Corrección: Usar propiedad correcta
              _buildDetalleRow('Mensaje', alerta.mensaje),  // Corrección: Usar propiedad correcta
              _buildDetalleRow('Fecha', _formatFecha(alerta.fechaCreacion)),  // Corrección: Usar propiedad correcta
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _marcarComoResuelta(alerta);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Marcar como Resuelta'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _marcarComoResuelta(Alerta alerta) async {  // Corrección: Usar Alerta
    try {
      // Usar el servicio específico
      final apiService = ApiService();  // Corrección: Crear instancia de ApiService
      final alertaService = AlertaService(apiService);  // Corrección: Crear instancia de AlertaService
      
      await alertaService.marcarComoLeida(alerta.id);  // Corrección: Usar método correcto
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alerta marcada como leída')),
      );
      _cargarAlertas();
    } catch (e) {
      appLogger.error('Error marcando alerta como leída', error: e);  // Corrección: Usar logger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al marcar alerta como leída: $e')),
      );
    }
  }
  
  /// Sincronizar estado de lectura con el backend
  Future<void> _sincronizarLectura() async {
    try {
      // Obtener alertas no leídas
      final alertasNoLeidas = _alertas.where((alerta) => !alerta.leida).toList();
      
      if (alertasNoLeidas.isEmpty) return;
      
      // Usar NotificationService para sincronizar
      final notificationService = NotificationService.instance;
      
      for (final alerta in alertasNoLeidas) {
        await notificationService.marcarComoLeido(alerta.id);
      }
      
      // Recargar alertas después de sincronizar
      if (mounted) {
        _cargarAlertas();
      }
      
      appLogger.info('Sincronización de lectura completada para ${alertasNoLeidas.length} alertas');
    } catch (e) {
      appLogger.error('Error en sincronización de lectura', error: e);
    }
  }

  String _formatFecha(DateTime fecha) {
    final now = DateTime.now();
    final diff = now.difference(fecha);
    
    if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes} minutos';
    } else if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} horas';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}

