import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/gestante_repository_impl.dart';
import '../../data/models/gestante_model.dart';
import 'package:dio/dio.dart';

final gestanteRepositoryProvider = Provider<GestanteRepositoryImpl>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
  return GestanteRepositoryImpl(dio);
});

final gestantesProvider = FutureProvider<List<GestanteModel>>((ref) async {
  final repo = ref.watch(gestanteRepositoryProvider);
  return repo.fetchGestantes();
});
