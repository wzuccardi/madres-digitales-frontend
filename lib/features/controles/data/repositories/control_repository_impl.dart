import '../models/control_model.dart';
import 'package:dio/dio.dart';

class ControlRepositoryImpl {
  final Dio dio;
  ControlRepositoryImpl(this.dio);

  Future<List<ControlModel>> fetchControles() async {
    final response = await dio.get('/controles');

    // Manejar estructura de respuesta del backend: { success: true, data: { controles: [...] } }
    List<dynamic> controlesData = [];
    if (response.data is Map && response.data['data'] != null) {
      final dataMap = response.data['data'];
      if (dataMap is Map && dataMap['controles'] != null) {
        final controlesValue = dataMap['controles'];
        if (controlesValue is List) {
          controlesData = controlesValue;
        }
      }
    } else if (response.data is List) {
      controlesData = response.data;
    }

    return controlesData.map((json) => ControlModel.fromJson(json)).toList();
  }

  Future<ControlModel> createControl(Map<String, dynamic> data) async {
    final response = await dio.post('/controles', data: data);
    return ControlModel.fromJson(response.data);
  }
}
