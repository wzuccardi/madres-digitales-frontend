import '../models/user_model.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl {
  final Dio dio;
  AuthRepositoryImpl(this.dio);

  Future<UserModel> login(String email, String password) async {
    final response = await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return UserModel.fromJson(response.data['user']);
  }

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await dio.post('/auth/register', data: data);
    return UserModel.fromJson(response.data['user']);
  }
}
