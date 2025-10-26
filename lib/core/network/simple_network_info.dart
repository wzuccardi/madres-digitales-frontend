
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class SimpleNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    // Por ahora, siempre devuelve true
    // En una implementación real, verificaría la conectividad de red
    return true;
  }
}