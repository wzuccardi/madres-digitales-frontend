import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Overlay de emergencia SOS que se muestra en toda la pantalla
/// cuando se recibe una alerta SOS crítica
class SOSEmergencyOverlay extends ConsumerStatefulWidget {

  const SOSEmergencyOverlay({
    super.key,
    required this.alertaData,
    required this.onDismiss,
  });
  final Map<String, dynamic> alertaData;
  final VoidCallback onDismiss;

  @override
  ConsumerState<SOSEmergencyOverlay> createState() => _SOSEmergencyOverlayState();
}

class _SOSEmergencyOverlayState extends ConsumerState<SOSEmergencyOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Animation<Color?> _flashAnimation;
  Timer? _soundTimer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    
    // Animación de flash rojo
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _flashAnimation = ColorTween(
      begin: Colors.red.withOpacity(0.3),
      end: Colors.red.withOpacity(0.8),
    ).animate(_flashController);

    _flashController.repeat(reverse: true);

    // Contador de tiempo
    _soundTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashController.dispose();
    _soundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final madrina = widget.alertaData['madrina'] as Map<String, dynamic>?;
    final gestante = widget.alertaData['gestante'] as Map<String, dynamic>?;
    final ubicacion = widget.alertaData['ubicacion'] as Map<String, dynamic>?;
    final emergencia = widget.alertaData['emergencia'] as Map<String, dynamic>?;

    return AnimatedBuilder(
      animation: _flashAnimation,
      builder: (context, child) {
        return Material(
          color: _flashAnimation.value,
          child: SafeArea(
            child: Stack(
              children: [
                // Contenido principal
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Encabezado de emergencia
                      _buildEmergencyHeader(),
                      
                      const SizedBox(height: 24),
                      
                      // Información de la madrina
                      _buildMadrinaCard(madrina),
                      
                      const SizedBox(height: 16),
                      
                      // Información de la gestante
                      if (gestante != null) ...[
                        _buildGestanteCard(gestante),
                        const SizedBox(height: 16),
                      ],
                      
                      // Ubicación GPS
                      if (ubicacion != null) ...[
                        _buildUbicacionCard(ubicacion),
                        const SizedBox(height: 16),
                      ],
                      
                      // Detalles de la emergencia
                      if (emergencia != null) ...[
                        _buildEmergenciaCard(emergencia),
                        const SizedBox(height: 16),
                      ],
                      
                      // Acciones
                      _buildActionButtons(madrina, ubicacion),
                      
                      const SizedBox(height: 80), // Espacio para el botón flotante
                    ],
                  ),
                ),
                
                // Botón de cerrar
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: widget.onDismiss,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'CERRAR ALERTA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono de emergencia
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency,
              size: 64,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          const Text(
            '🚨 EMERGENCIA SOS 🚨',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Tiempo transcurrido
          Text(
            'Hace $_secondsElapsed segundos',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje
          Text(
            widget.alertaData['mensaje'] ?? 'Emergencia SOS activada',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMadrinaCard(Map<String, dynamic>? madrina) {
    if (madrina == null) return const SizedBox.shrink();

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Text(
                  'MADRINA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Nombre', madrina['nombre'] ?? '-'),
            _buildInfoRow('Teléfono', madrina['telefono'] ?? '-'),
            _buildInfoRow('Email', madrina['email'] ?? '-'),
            _buildInfoRow('Municipio', madrina['municipio_id'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _buildGestanteCard(Map<String, dynamic> gestante) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pregnant_woman, color: Colors.purple, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'GESTANTE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                if (gestante['riesgo_alto'] == true) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'ALTO RIESGO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Nombre', gestante['nombre'] ?? '-'),
            _buildInfoRow('Documento', gestante['documento'] ?? '-'),
            _buildInfoRow('Teléfono', gestante['telefono'] ?? '-'),
            _buildInfoRow('Dirección', gestante['direccion'] ?? '-'),
            if (gestante['factores_riesgo'] != null && (gestante['factores_riesgo'] as List).isNotEmpty)
              _buildInfoRow('Factores de Riesgo', (gestante['factores_riesgo'] as List).join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildUbicacionCard(Map<String, dynamic> ubicacion) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 28),
                SizedBox(width: 12),
                Text(
                  'UBICACIÓN GPS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Latitud', ubicacion['latitud']?.toString() ?? '-'),
            _buildInfoRow('Longitud', ubicacion['longitud']?.toString() ?? '-'),
            if (ubicacion['descripcion'] != null)
              _buildInfoRow('Descripción', ubicacion['descripcion']),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergenciaCard(Map<String, dynamic> emergencia) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text(
                  'DETALLES DE EMERGENCIA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Tipo', emergencia['tipo'] ?? '-'),
            _buildInfoRow('Descripción', emergencia['descripcion'] ?? '-'),
            _buildInfoRow('Nivel de Urgencia', emergencia['nivel_urgencia'] ?? '-'),
            if (emergencia['sintomas'] != null && (emergencia['sintomas'] as List).isNotEmpty)
              _buildInfoRow('Síntomas', (emergencia['sintomas'] as List).join(', ')),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic>? madrina, Map<String, dynamic>? ubicacion) {
    return Column(
      children: [
        // Llamar a la madrina
        if (madrina?['telefono'] != null)
          ElevatedButton.icon(
            onPressed: () => _llamarTelefono(madrina!['telefono']),
            icon: const Icon(Icons.phone, size: 28),
            label: const Text(
              'LLAMAR A LA MADRINA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Ver ubicación en Google Maps
        if (ubicacion?['google_maps_url'] != null)
          ElevatedButton.icon(
            onPressed: () => _abrirMaps(ubicacion!['google_maps_url']),
            icon: const Icon(Icons.map, size: 28),
            label: const Text(
              'VER UBICACIÓN EN MAPA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _llamarTelefono(String telefono) async {
    final uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _abrirMaps(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
