import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cache_manager.dart';

final cacheServiceProvider = Provider<CacheManager>((ref) => CacheManager());

final cacheManagerProvider = Provider<CacheManager>((ref) => ref.read(cacheServiceProvider));