import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';
import 'package:madres_digitales_flutter_new/presentation/widgets/sos/sos_emergency_overlay.dart';

/// Provider que escucha alertas SOS en tiempo real
/// Solo activo para admin, coordinadores y médicos
class SOSListenerNotifier extends StateNotifier<SOSListenerState> {
  
  SOSListenerNotifier(this.ref) : super(const SOSListenerState());
  final Ref ref;
  StreamSubscription? _sosSubscription;

  /// Iniciar escucha de alertas SOS
  Future<void> iniciarEscucha() async {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.toLowerCase();
    
    // Solo escuchar si es admin, coordinador o médico
    if (userRole != AppConstants.adminRole &&
        userRole != AppConstants.superAdminRole &&
        userRole != AppConstants.coordinatorRole &&
        userRole != AppConstants.medicoRole) {
      return;
    }

    try {
      final ws = ref.read(webSocketServiceProvider);
      await ws.connect();
      
      // Unirse a la sala según el rol
      if (userRole == AppConstants.adminRole || userRole == AppConstants.superAdminRole) {
        // Los admins se unen a la sala 'admin'
      } else if (userRole == AppConstants.coordinatorRole) {
        // Los coordinadores se unen a la sala 'coordinador'
      } else if (userRole == AppConstants.medicoRole) {
        // Los médicos se unen a la sala 'medico'
      }
      
      // Escuchar eventos de SOS
      _sosSubscription = ws.stream<Map<String, dynamic>>('sos:emergencia').listen((data) {
        print('🚨 ALERTA SOS RECIBIDA: $data');
        state = SOSListenerState(
          alertaActiva: true,
          alertaData: data,
          timestamp: DateTime.now(),
        );
      });
      
      print('✅ Escucha de alertas SOS iniciada para rol: $userRole');
    } catch (e) {
      print('❌ Error iniciando escucha SOS: $e');
    }
  }

  /// Detener escucha de alertas SOS
  void detenerEscucha() {
    _sosSubscription?.cancel();
    _sosSubscription = null;
  }

  /// Marcar alerta como vista
  void marcarComoVista() {
    state = const SOSListenerState();
  }

  @override
  void dispose() {
    detenerEscucha();
    super.dispose();
  }
}

/// Estado del listener de SOS
class SOSListenerState {

  const SOSListenerState({
    this.alertaActiva = false,
    this.alertaData,
    this.timestamp,
  });
  final bool alertaActiva;
  final Map<String, dynamic>? alertaData;
  final DateTime? timestamp;
}

/// Provider del listener de SOS
final sosListenerProvider = StateNotifierProvider<SOSListenerNotifier, SOSListenerState>((ref) {
  return SOSListenerNotifier(ref);
});

/// Widget que muestra el overlay de SOS cuando hay una alerta activa
class SOSListenerWidget extends ConsumerStatefulWidget {

  const SOSListenerWidget({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SOSListenerWidget> createState() => _SOSListenerWidgetState();
}

class _SOSListenerWidgetState extends ConsumerState<SOSListenerWidget> {
  @override
  void initState() {
    super.initState();
    // Iniciar escucha después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosListenerProvider.notifier).iniciarEscucha();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(sosListenerProvider);

    return Stack(
      children: [
        // Contenido normal
        widget.child,
        
        // Overlay de emergencia SOS
        if (sosState.alertaActiva && sosState.alertaData != null)
          Positioned.fill(
            child: SOSEmergencyOverlay(
              alertaData: sosState.alertaData!,
              onDismiss: () {
                ref.read(sosListenerProvider.notifier).marcarComoVista();
              },
            ),
          ),
      ],
    );
  }
}
