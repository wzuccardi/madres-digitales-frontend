import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/alerta_repository_impl.dart';
import '../../data/models/alerta_model.dart';
import 'package:dio/dio.dart';

final alertaRepositoryProvider = Provider<AlertaRepositoryImpl>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
  return AlertaRepositoryImpl(dio);
});

final alertasProvider = FutureProvider<List<AlertaModel>>((ref) async {
  final repo = ref.watch(alertaRepositoryProvider);
  return repo.fetchAlertas();
});
