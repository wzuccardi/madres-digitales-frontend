import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madres_digitales_flutter_new/domain/entities/gestante.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/get_gestantes_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/create_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/update_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/delete_gestante_usecase.dart';
import 'package:madres_digitales_flutter_new/domain/usecases/gestante/assign_gestante_to_madrina_usecase.dart';
import 'package:madres_digitales_flutter_new/core/errors/app_error.dart';
import 'package:madres_digitales_flutter_new/core/types/result.dart';
import 'service_providers.dart';

final getGestantesUseCaseProvider = Provider<GetGestantesUseCase>((ref) {
  final repo = ref.read(gestanteRepositoryProvider);
  return GetGestantesUseCase(repo);
});

final createGestanteUseCaseProvider = Provider<CreateGestanteUseCase>((ref) {
  final repo = ref.read(gestanteRepositoryProvider);
  return CreateGestanteUseCase(repo);
});

final updateGestanteUseCaseProvider = Provider<UpdateGestanteUseCase>((ref) {
  final repo = ref.read(gestanteRepositoryProvider);
  return UpdateGestanteUseCase(repo);
});

final deleteGestanteUseCaseProvider = Provider<DeleteGestanteUseCase>((ref) {
  final repo = ref.read(gestanteRepositoryProvider);
  return DeleteGestanteUseCase(repo);
});

final assignGestanteToMadrinaUseCaseProvider = Provider<AssignGestanteToMadrinaUseCase>((ref) {
  final repo = ref.read(gestanteRepositoryProvider);
  return AssignGestanteToMadrinaUseCase(repo);
});

final gestantesListProvider = FutureProvider.family<Result<List<Gestante>, AppError>, GetGestantesParams>((ref, params) async {
  final uc = ref.read(getGestantesUseCaseProvider);
  return await uc(params);
});