import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/control_repository_impl.dart';
import '../../data/models/control_model.dart';
import 'package:dio/dio.dart';

final controlRepositoryProvider = Provider<ControlRepositoryImpl>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
  return ControlRepositoryImpl(dio);
});

final controlesProvider = FutureProvider<List<ControlModel>>((ref) async {
  final repo = ref.watch(controlRepositoryProvider);
  return repo.fetchControles();
});
