import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/core/network/api_service.dart';
import 'package:madres_digitales_flutter_new/data/services/permission_service.dart';


final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
