// lib/services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final StreamController<List<ConnectivityResult>> _controller = 
      StreamController<List<ConnectivityResult>>.broadcast();
  
  Stream<List<ConnectivityResult>> get connectivityStream => _controller.stream;
  
  Future<bool> get isConnected async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) || 
           result.contains(ConnectivityResult.wifi);
  }
  
  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((result) {
      _controller.add(result);
    });
  }
  
  void dispose() {
    _controller.close();
  }
}

// Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  service.startMonitoring();
  return service.connectivityStream;
});

final isConnectedProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityStreamProvider);
  return connectivity.when(
    data: (results) => results.contains(ConnectivityResult.mobile) || 
                     results.contains(ConnectivityResult.wifi),
    loading: () => true, // Asumir conectividad por defecto
    error: (_, __) => false,
  );
});

