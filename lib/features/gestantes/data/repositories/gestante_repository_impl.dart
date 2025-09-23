import '../models/gestante_model.dart';
import 'package:dio/dio.dart';

class GestanteRepositoryImpl {
  final Dio dio;
  GestanteRepositoryImpl(this.dio);

  Future<List<GestanteModel>> fetchGestantes() async {
    final response = await dio.get('/gestantes');
    List data = response.data as List;
    return data.map((json) => GestanteModel.fromJson(json)).toList();
  }
}
