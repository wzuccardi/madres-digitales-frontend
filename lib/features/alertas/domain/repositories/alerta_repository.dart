import '../entities/alerta.dart';

abstract class AlertaRepository {
  Future<List<Alerta>> fetchAlertas();
  Future<Alerta> createAlerta(Map<String, dynamic> data);
}
