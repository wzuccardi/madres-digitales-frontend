import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madres_digitales_flutter_new/presentation/providers/auth_provider.dart';
import 'package:madres_digitales_flutter_new/core/constants/app_constants.dart';

class RouteGuard extends ConsumerWidget {
  const RouteGuard({super.key, required this.allowedRoles, required this.child});
  final List<String> allowedRoles;
  final Widget child;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    if (!auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(AppConstants.loginRoute);
      });
      return const SizedBox.shrink();
    }
    final role = auth.user?.role ?? '';
    if (allowedRoles.isNotEmpty && !allowedRoles.contains(role)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 48),
              const SizedBox(height: 12),
              const Text('Acceso denegado'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go(AppConstants.dashboardRoute),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }
    return child;
  }
}
