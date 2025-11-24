import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSAlertOverlay extends StatefulWidget {

  const SOSAlertOverlay({
    super.key,
    required this.alertData,
    required this.onDismiss,
  });
  final Map<String, dynamic> alertData;
  final VoidCallback onDismiss;

  @override
  State<SOSAlertOverlay> createState() => _SOSAlertOverlayState();
}

class _SOSAlertOverlayState extends State<SOSAlertOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  late Timer _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMap(double lat, double lng) async {
    final Uri launchUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final madrina = widget.alertData['madrina'] as Map<String, dynamic>?;
    final gestante = widget.alertData['gestante'] as Map<String, dynamic>?;
    final ubicacion = widget.alertData['ubicacion'] as Map<String, dynamic>?;
    final detalles = widget.alertData['detalles'] as Map<String, dynamic>?;

    return AnimatedBuilder(
      animation: _flashController,
      builder: (context, child) {
        return Container(
          color: Colors.red.withOpacity(0.3 + (_flashController.value * 0.4)),
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.emergency, color: Colors.red, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🚨 ALERTA SOS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                'Tiempo transcurrido: ${_formatDuration(_secondsElapsed)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: widget.onDismiss,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const Divider(height: 32, thickness: 2),

                    // Información de la Madrina
                    if (madrina != null) ...[
                      const Text(
                        '👤 MADRINA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Nombre', madrina['nombre'] ?? 'N/A'),
                      _buildInfoRow('Teléfono', madrina['telefono'] ?? 'N/A'),
                      _buildInfoRow('Email', madrina['email'] ?? 'N/A'),
                      _buildInfoRow('Municipio', madrina['municipio'] ?? 'N/A'),
                      
                      if (madrina['telefono'] != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _makePhoneCall(madrina['telefono']),
                          icon: const Icon(Icons.phone),
                          label: const Text('LLAMAR A MADRINA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      const Divider(height: 32, thickness: 2),
                    ],

                    // Información de la Gestante
                    if (gestante != null) ...[
                      const Text(
                        '🤰 GESTANTE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Nombre', gestante['nombre'] ?? 'N/A'),
                      _buildInfoRow('Documento', gestante['documento'] ?? 'N/A'),
                      _buildInfoRow('Teléfono', gestante['telefono'] ?? 'N/A'),
                      _buildInfoRow('Dirección', gestante['direccion'] ?? 'N/A'),
                      
                      if (gestante['alto_riesgo'] == true) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ALTO RIESGO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      if (gestante['factores_riesgo'] != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow('Factores de Riesgo', gestante['factores_riesgo']),
                      ],
                      const Divider(height: 32, thickness: 2),
                    ],

                    // Ubicación GPS
                    if (ubicacion != null) ...[
                      const Text(
                        '📍 UBICACIÓN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Latitud', ubicacion['latitud']?.toString() ?? 'N/A'),
                      _buildInfoRow('Longitud', ubicacion['longitud']?.toString() ?? 'N/A'),
                      
                      if (ubicacion['latitud'] != null && ubicacion['longitud'] != null) ...[
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openMap(
                            ubicacion['latitud'],
                            ubicacion['longitud'],
                          ),
                          icon: const Icon(Icons.map),
                          label: const Text('VER EN GOOGLE MAPS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                      ],
                      const Divider(height: 32, thickness: 2),
                    ],

                    // Detalles de la Emergencia
                    if (detalles != null) ...[
                      const Text(
                        '⚠️ DETALLES DE EMERGENCIA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Tipo', detalles['tipo'] ?? 'N/A'),
                      _buildInfoRow('Descripción', detalles['descripcion'] ?? 'N/A'),
                      _buildInfoRow('Síntomas', detalles['sintomas'] ?? 'N/A'),
                      _buildInfoRow('Urgencia', detalles['urgencia'] ?? 'MÁXIMA'),
                    ],

                    const SizedBox(height: 24),
                    
                    // Botón de cerrar
                    ElevatedButton(
                      onPressed: widget.onDismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text(
                        'CERRAR ALERTA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
