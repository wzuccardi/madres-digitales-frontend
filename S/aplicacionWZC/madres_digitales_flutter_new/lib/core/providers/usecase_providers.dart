import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/sign_in_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/sign_up_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/sign_out_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/get_current_user_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/refresh_token_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/auth/verify_token_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/create_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/update_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/delete_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/assign_gestante_to_madrina_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/sos/get_active_sos_alerts_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/sos/get_sos_statistics_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/sos/update_sos_status_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/generate_report_usecase.dart';
import 'package:madres_digitales_flutter_new/core/providers/service_providers.dart';

// Auth Use Cases Providers
final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignInUseCase(authRepository);
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignUpUseCase(authRepository);
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return SignOutUseCase(authRepository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(authRepository);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(authRepository);
});

final verifyTokenUseCaseProvider = Provider<VerifyTokenUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return VerifyTokenUseCase(authRepository);
});

// Gestante Use Cases Providers
final getGestantesUseCaseProvider = Provider<GetGestantesUseCase>((ref) {
  final repo = ref.watch(gestanteRepositoryProvider);
  return GetGestantesUseCase(repo);
});

final createGestanteUseCaseProvider = Provider<CreateGestanteUseCase>((ref) {
  final repo = ref.watch(gestanteRepositoryProvider);
  return CreateGestanteUseCase(repo);
});

final updateGestanteUseCaseProvider = Provider<UpdateGestanteUseCase>((ref) {
  final repo = ref.watch(gestanteRepositoryProvider);
  return UpdateGestanteUseCase(repo);
});

final deleteGestanteUseCaseProvider = Provider<DeleteGestanteUseCase>((ref) {
  final repo = ref.watch(gestanteRepositoryProvider);
  return DeleteGestanteUseCase(repo);
});

final assignGestanteToMadrinaUseCaseProvider = Provider<AssignGestanteToMadrinaUseCase>((ref) {
  final repo = ref.watch(gestanteRepositoryProvider);
  return AssignGestanteToMadrinaUseCase(repo);
});

// SOS Use Cases Providers
final getActiveSosAlertsUseCaseProvider = Provider<GetActiveSOSAlertsUseCase>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  return GetActiveSOSAlertsUseCase(repo);
});

final getSosStatisticsUseCaseProvider = Provider<GetSOSStatisticsUseCase>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  return GetSOSStatisticsUseCase(repo);
});

final updateSosStatusUseCaseProvider = Provider<UpdateSOSStatusUseCase>((ref) {
  final repo = ref.watch(sosRepositoryProvider);
  return UpdateSOSStatusUseCase(repo);
});

// Report Use Cases Providers
final generateReportUseCaseProvider = Provider<GenerateReportUseCase>((ref) {
  final repo = ref.watch(reportRepositoryProvider);
  return GenerateReportUseCase(repo);
});
