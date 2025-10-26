import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/permission_service.dart';
import '../../../../services/api_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PermissionService(apiService);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});