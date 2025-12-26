import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/repositories/cached_bootstrap_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.prefsStore,
    required this.diskCache,
    required this.cachedBootstrapRepository,
  });

  final PrefsStore prefsStore;
  final HiveJsonCache diskCache;
  final CachedBootstrapRepository cachedBootstrapRepository;
}
