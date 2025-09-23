import '../entities/gestante.dart';

abstract class GestanteRepository {
  Future<List<Gestante>> fetchGestantes();
}
