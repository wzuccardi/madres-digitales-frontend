// Pantalla SOS mejorada con alarma sonora fuerte y vibraciÃ³n intensa
// Proporciona una interfaz de emergencia clara y efectiva

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/sos_alarm_service.dart';
import '../services/auth_service.dart';
import '../services/geolocalizacion_service.dart';
import '../providers/service_providers.dart';

class SOSMejoradoScreen extends ConsumerStatefulWidget {
  final String? gestanteId;
  final double? latitud;
  final double? longitud;
  final String? descripcion;

  const SOSMejoradoScreen({
    super.key,
    this.gestanteId,
    this.latitud,
    this.longitud,
    this.descripcion,
  });

  @override
  ConsumerState<SOSMejoradoScreen> createState() => _SOSMejoradoScreenState();
}

class _SOSMejoradoScreenState extends ConsumerState<SOSMejoradoScreen>
    with TickerProviderStateMixin {
  int _countdown = 5;
  Position? _currentPosition;
  String _locationStatus = 'Obteniendo ubicaciÃ³n...';
  bool _alertSent = false;
  bool _isAlertActive = false;
  String _alertMessage = '';
  List<dynamic> _contactosCercanos = [];
  bool _mostrarMapa = false;
  final GeolocalizacionService _geoService = GeolocalizacionService();
  
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _flashController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _flashAnimation;
  
  final SOSAlarmService _sosService = SOSAlarmService();
  Timer? _countdownTimer;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    
    // Configurar animaciones
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
    
    _flashAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animaciÃ³n de pulso
    _pulseController.repeat(reverse: true);
    
    // Ocultar barra de estado para efecto completo
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Iniciar proceso SOS
    _iniciarProcesoSOS();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _flashController.dispose();
    _countdownTimer?.cancel();
    _flashTimer?.cancel();
    _sosService.detenerAlarma();
    // Restaurar barra de estado
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _iniciarProcesoSOS() async {
    // 1. Obtener ubicaciÃ³n
    await _obtenerUbicacion();
    
    // 2. Enviar alerta SOS
    await _enviarAlertaSOS();
  }

  Future<void> _obtenerUbicacion() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = 'Permisos de ubicaciÃ³n denegados';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = 'Permisos de ubicaciÃ³n denegados permanentemente';
        });
        return;
      }

      // Obtener posiciÃ³n actual
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _locationStatus =
            'UbicaciÃ³n: ${_currentPosition!.latitude.toStringAsFixed(6)}, '
            '${_currentPosition!.longitude.toStringAsFixed(6)}';
      });

      // Buscar contactos cercanos (IPS/hospitales)
      await _buscarContactosCercanos();
    } catch (e) {
      setState(() {
        _locationStatus = 'Error obteniendo ubicaciÃ³n: $e';
      });
    }
  }

  Future<void> _buscarContactosCercanos() async {
    if (_currentPosition == null) return;

    try {
      final contactos = await _geoService.buscarCercanos(
        latitud: _currentPosition!.latitude,
        longitud: _currentPosition!.longitude,
        radio: 5, // 5 km de radio
        tipo: 'ips', // Buscar solo IPS
        limit: 10,
      );

      setState(() {
        _contactosCercanos = contactos;
      });
    } catch (e) {
      // No interrumpir el flujo si falla la bÃºsqueda de contactos
    }
  }

  Future<void> _enviarAlertaSOS() async {
    try {
      setState(() {
        _alertMessage = 'ENVIANDO ALERTA SOS...';
      });

      final gestanteId = widget.gestanteId ?? await _obtenerGestanteIdActual();
      
      if (gestanteId == null) {
        setState(() {
          _alertMessage = 'ERROR: No se pudo identificar la gestante';
        });
        return;
      }

      final position = _currentPosition ??
          Position(
            latitude: widget.latitud ?? 0.0,
            longitude: widget.longitud ?? 0.0,
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0
          );


      // Activar alarma SOS completa
      final resultado = await _sosService.activarAlarmaSOSConUbicacion(
        gestanteId: gestanteId,
        descripcion: widget.descripcion ?? 'Alerta SOS de emergencia activada',
      );

      setState(() {
        _alertSent = resultado['success'] ?? false;
        _alertMessage = resultado['mensaje'] ?? 'Error desconocido';
      });

      if (_alertSent) {
        
        _iniciarCountdown();
        _iniciarEfectosVisuales();
      } else {
      }
    } catch (e) {
      setState(() {
        _alertSent = false;
        _alertMessage = 'Error: $e';
      });
      
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
      
      // Continuar con el proceso aunque falle el envÃ­o
      _iniciarCountdown();
      _iniciarEfectosVisuales();
    }
  }

  Future<String?> _obtenerGestanteIdActual() async {
    try {
      // Intentar obtener gestante desde el contexto de autenticaciÃ³n
      final authService = AuthService();
      final userId = authService.userId;
      
      if (userId != null) {
        // AquÃ­ podrÃ­as obtener la gestante asociada al usuario
        // Por ahora, usamos la primera gestante disponible
        final simpleDataService = ref.read(simpleDataServiceProvider);
        final gestantes = await simpleDataService.obtenerGestantes();
        
        if (gestantes.isNotEmpty) {
          return gestantes.first['id']?.toString();
        }
      }
    } catch (e) {
    }
    
    return null;
  }

  void _iniciarCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        
        // VibraciÃ³n en cada segundo
        HapticFeedback.lightImpact();
      } else if (mounted) {
        timer.cancel();
        _mostrarDialogoEmergencia();
      }
    });
  }

  void _iniciarEfectosVisuales() {
    setState(() {
      _isAlertActive = true;
    });
    
    // Iniciar animaciÃ³n de sacudida
    _shakeController.repeat(reverse: true);
    
    // Iniciar parpadeo de pantalla
    _flashController.repeat(reverse: true);
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isAlertActive) {
        timer.cancel();
        _flashController.stop();
        _flashController.reset();
      }
    });
  }

  void _cancelarSOS() {
    _countdownTimer?.cancel();
    _flashTimer?.cancel();
    _shakeController.stop();
    _shakeController.reset();
    _flashController.stop();
    _flashController.reset();
    _sosService.detenerAlarma();
    
    setState(() {
      _isAlertActive = false;
      _countdown = 5;
      _alertMessage = '';
    });
    
    Navigator.of(context).pop();
  }

  void _mostrarDialogoEmergencia() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.red.withOpacity(0.8),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700], size: 28),
            const SizedBox(width: 8),
            const Text('EMERGENCIA ACTIVADA'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Â¡ALERTA SOS ENVIADA!\n\n'
              'Se ha notificado a los servicios de emergencia '
              'y a tu madrina comunitaria.\n\n'
              'MantÃ©n la calma, ayuda estÃ¡ en camino.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.notifications_active,
                    color: Colors.red[700],
                    size: 60,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _sosService.detenerAlarma();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red[700],
            ),
            child: const Text('ENTENDIDO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isAlertActive ? Colors.red.shade900 : Colors.white,
      body: AnimatedBuilder(
        animation: _flashAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isAlertActive 
                    ? [
                        Colors.red.shade800,
                        Colors.red.shade900,
                        Colors.red.shade900,
                      ]
                    : [
                        Colors.white,
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
              ),
              // Efecto de flash
              color: _isAlertActive 
                  ? Colors.red.withOpacity(_flashAnimation.value * 0.3)
                  : null,
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isAlertActive) ...[
                    _buildInitialUI(),
                  ] else ...[
                    _buildActiveUI(),
                  ],
                  
                  const SizedBox(height: 40),
                  
                  _buildLocationInfo(),
                  
                  const SizedBox(height: 40),
                  
                  if (!_isAlertActive) ...[
                    _buildStartButton(),
                  ] else ...[
                    _buildActiveControls(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialUI() {
    return Column(
      children: [
        Icon(
          Icons.emergency,
          size: 100,
          color: Colors.red[500],
        ),
        const SizedBox(height: 20),
        Text(
          'BOTÃ“N DE EMERGENCIA',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Presiona solo en caso de emergencia real',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActiveUI() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 
                         (Random().nextBool() ? 1 : -1), 0),
          child: Column(
            children: [
              Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _alertMessage,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Suelta para cancelar',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isAlertActive
            ? Colors.white.withOpacity(0.2)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: _isAlertActive
            ? Border.all(color: Colors.white.withOpacity(0.3))
            : null,
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_on,
            color: _isAlertActive ? Colors.white : Colors.grey[700],
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            _locationStatus,
            style: TextStyle(
              fontSize: 14,
              color: _isAlertActive ? Colors.white : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          
          // Mostrar contactos cercanos si hay disponibles
          if (_contactosCercanos.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'IPS cercanas:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _isAlertActive ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ..._contactosCercanos.take(3).map((contacto) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                contacto['nombre'] ?? 'IPS sin nombre',
                style: TextStyle(
                  fontSize: 12,
                  color: _isAlertActive ? Colors.white70 : Colors.grey[600],
                ),
              ),
            )),
            
            // BotÃ³n para mostrar mapa
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => setState(() => _mostrarMapa = !_mostrarMapa),
              icon: Icon(
                _mostrarMapa ? Icons.map_outlined : Icons.map,
                color: _isAlertActive ? Colors.white : Colors.red[700],
              ),
              label: Text(
                _mostrarMapa ? 'Ocultar mapa' : 'Ver en mapa',
                style: TextStyle(
                  color: _isAlertActive ? Colors.white : Colors.red[700],
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAlertActive
                    ? Colors.white.withOpacity(0.2)
                    : Colors.red[50],
                foregroundColor: _isAlertActive ? Colors.white : Colors.red[700]!,
                side: BorderSide(
                  color: _isAlertActive ? Colors.white : Colors.red[700]!,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTapDown: (_) => _iniciarProcesoSOS(),
      onTapUp: (_) => _cancelarSOS(),
      onTapCancel: () => _cancelarSOS(),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.red[600],
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    spreadRadius: 10,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sos,
                    size: 80,
                    color: Colors.white,
                  ),
                  Text(
                    'SOS',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveControls() {
    return Column(
      children: [
        Text(
          'Regresando en $_countdown segundos...',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 20),
        
        ElevatedButton(
          onPressed: _cancelarSOS,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
          ),
          child: const Text(
            'CANCELAR',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
