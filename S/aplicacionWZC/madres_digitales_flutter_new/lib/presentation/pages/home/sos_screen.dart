import 'package:madres_digitales_flutter_new/data/services/gestante_service.dart';
import 'package:madres_digitales_flutter_new/core/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
// Corrección: Importar AlertaService
// Corrección: Importar ApiService
// Corrección: Importar GestanteService
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
// Corrección: Importar logger

class SOSScreen extends ConsumerStatefulWidget {
  const SOSScreen({super.key});

  @override
  ConsumerState<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends ConsumerState<SOSScreen>
    with TickerProviderStateMixin {
  int _countdown = 5;
  Position? _currentPosition;
  String _locationStatus = 'Obteniendo ubicación...';
  bool _alertSent = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configurar animación de pulso
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animación
    _pulseController.repeat(reverse: true);
    
    // Ocultar barra de estado para efecto completo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Iniciar proceso SOS
    _iniciarProcesoSOS();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    // Restaurar barra de estado
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _iniciarProcesoSOS() async {
    // 1. Obtener ubicación
    await _obtenerUbicacion();
    
    // 2. Enviar alerta SOS
    await _enviarAlertaSOS();
    
    // 3. Iniciar countdown
    _iniciarCountdown();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Permisos de ubicación denegados';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Permisos de ubicación denegados permanentemente';
        });
        return;
      }

      // Obtener posición actual
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _locationStatus = 
            'Ubicación: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
            '${_currentPosition!.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error obteniendo ubicación: $e';
      });
    }
  }

  Future<void> _enviarAlertaSOS() async {
    try {
      // TODO: Obtener gestanteId del usuario logueado desde el contexto de autenticación
      // Por ahora usamos el primer gestante disponible para demostración
      final apiService = ref.read(apiServiceProvider);
      final gestanteService = GestanteService(apiService);
      final gestantes = await gestanteService.obtenerGestantes();  // Corrección: Usar método correcto

      if (gestantes.isEmpty) {
        throw Exception('No hay gestantes registradas en el sistema');
      }

      final gestanteId = gestantes.first.id; // Usar la primera gestante como demo

      if (_currentPosition != null) {
        AppLogger.info('🚨 Enviando alerta SOS real al backend...');  // Corrección: Usar logger

        // Usar el servicio específico
        final alertaService = ref.read(alertaServiceProvider);

        await alertaService.enviarAlertaSOS(
          gestanteId: gestanteId,
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          accuracy: _currentPosition!.accuracy,
          mensaje: 'SOS automático desde app',
        );
        AppLogger.info('✅ Alerta SOS enviada exitosamente');
      } else {
        throw Exception('No se pudo obtener la ubicación actual');
      }

      setState(() {
        _alertSent = true;
      });
    } catch (e) {
      AppLogger.error('Error enviando alerta SOS', error: e);  // Corrección: Usar logger

      // Mostrar error al usuario pero continuar con el proceso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error enviando alerta: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Continuar con el proceso aunque falle el envío
      setState(() {
        _alertSent = true;
      });
    }
  }

  void _iniciarCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _iniciarCountdown();
      } else if (mounted) {
        _cerrarPantalla();
      }
    });
  }

  void _cerrarPantalla() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.shade800,
                Colors.red.shade900,
                Colors.red.shade900,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono SOS animado
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // Texto principal
              const Text(
                '¡ALERTA DE EMERGENCIA!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              Text(
                _alertSent ? '¡ENVIADA!' : 'ENVIANDO...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _alertSent ? Colors.greenAccent : Colors.yellowAccent,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Información de ubicación
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _locationStatus,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Countdown
              Text(
                'Regresando en $_countdown segundos...',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Botón cancelar
              ElevatedButton(
                onPressed: _cerrarPantalla,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                child: const Text(
                  'CERRAR',
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
    );
  }
}
