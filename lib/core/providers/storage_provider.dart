import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:madres_digitales_flutter_new/core/storage/local_storage_manager.dart';

/// Provider para LocalStorageManager
final localStorageProvider = FutureProvider<LocalStorageManager>((ref) async {
  return LocalStorageManagerFactory.create();
});

/// Provider para SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider para PathProvider
final pathProviderProvider = FutureProvider<String>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
});
