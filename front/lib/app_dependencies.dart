import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/repositories/cached_bootstrap_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_schedule_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/game_center_repository.dart';
import 'package:ice_line_tracker/data/repositories/player_repository.dart';
import 'package:ice_line_tracker/data/repositories/team_repository.dart';

class AppDependencies {
  const AppDependencies({
    required this.prefsStore,
    required this.favoritesStore,
    required this.diskCache,
    required this.cachedBootstrapRepository,
    required this.cachedScheduleRepository,
    required this.cachedStandingsRepository,
    required this.gameCenterRepository,
    required this.teamRepository,
    required this.playerRepository,
  });

  final PrefsStore prefsStore;
  final FavoritesStore favoritesStore;
  final HiveJsonCache diskCache;
  final CachedBootstrapRepository cachedBootstrapRepository;
  final CachedScheduleRepository cachedScheduleRepository;
  final CachedStandingsRepository cachedStandingsRepository;
  final GameCenterRepository gameCenterRepository;
  final TeamRepository teamRepository;
  final PlayerRepository playerRepository;
}
