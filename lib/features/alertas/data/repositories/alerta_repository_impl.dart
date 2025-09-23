import '../models/alerta_model.dart';
import 'package:dio/dio.dart';

class AlertaRepositoryImpl {
  final Dio dio;
  AlertaRepositoryImpl(this.dio);

  Future<List<AlertaModel>> fetchAlertas() async {
    final response = await dio.get('/alertas');
    List data = response.data as List;
    return data.map((json) => AlertaModel.fromJson(json)).toList();
  }

  Future<AlertaModel> createAlerta(Map<String, dynamic> data) async {
    final response = await dio.post('/alertas', data: data);
    return AlertaModel.fromJson(response.data);
  }
}
