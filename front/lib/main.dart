import 'package:flutter/material.dart';
import 'package:ice_line_tracker/app.dart';
import 'package:ice_line_tracker/app_dependencies.dart';
import 'package:ice_line_tracker/data/api/api_client.dart';
import 'package:ice_line_tracker/data/api/nhl_seasons_service.dart';
import 'package:ice_line_tracker/data/api/nhl_standings_service.dart';
import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/repositories/bootstrap_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_bootstrap_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsStore = await PrefsStore.create();
  final diskCache = await HiveJsonCache.open();

  final apiClient = ApiClient();
  final remoteBootstrap = BootstrapRepository(
    standingsService: NhlStandingsService(apiClient.dio),
    seasonsService: NhlSeasonsService(apiClient.dio),
  );
  final cachedBootstrapRepository = CachedBootstrapRepository(
    remote: remoteBootstrap,
    diskCache: diskCache,
  );

  runApp(
    App(
      dependencies: AppDependencies(
        prefsStore: prefsStore,
        diskCache: diskCache,
        cachedBootstrapRepository: cachedBootstrapRepository,
      ),
    ),
  );
}
