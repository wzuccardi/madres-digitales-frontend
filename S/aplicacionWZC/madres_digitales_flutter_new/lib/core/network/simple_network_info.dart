
import 'dart:io';
import 'network_info.dart';

class SimpleNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

class NetworkInfoImpl extends SimpleNetworkInfo {}
