import '../models/control_model.dart';
import 'package:dio/dio.dart';

class ControlRepositoryImpl {
  final Dio dio;
  ControlRepositoryImpl(this.dio);

  Future<List<ControlModel>> fetchControles() async {
    final response = await dio.get('/controles');
    List data = response.data as List;
    return data.map((json) => ControlModel.fromJson(json)).toList();
  }

  Future<ControlModel> createControl(Map<String, dynamic> data) async {
    final response = await dio.post('/controles', data: data);
    return ControlModel.fromJson(response.data);
  }
}
