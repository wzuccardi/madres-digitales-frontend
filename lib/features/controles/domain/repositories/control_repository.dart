import '../entities/control.dart';

abstract class ControlRepository {
  Future<List<Control>> fetchControles();
  Future<Control> createControl(Map<String, dynamic> data);
}
