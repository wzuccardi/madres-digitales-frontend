import 'package:flutter_riverpod/flutter_riverpod.dart';

class MadrinaSessionState {
  const MadrinaSessionState({this.madrinaId});
  final String? madrinaId;
}

class MadrinaSessionNotifier extends StateNotifier<MadrinaSessionState> {
  MadrinaSessionNotifier() : super(const MadrinaSessionState());

  Future<bool> tienePermiso(String gestanteId, String permiso) async {
    return true;
  }
}

final madrinaSessionProvider = StateNotifierProvider<MadrinaSessionNotifier, MadrinaSessionState>((ref) {
  return MadrinaSessionNotifier();
});