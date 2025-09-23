// Auth provider using Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import 'package:dio/dio.dart';

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));
  return AuthRepositoryImpl(dio);
});

final userProvider = Provider<UserModel?>((ref) => null);
