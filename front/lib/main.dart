import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/app.dart';
import 'package:ice_line_tracker/app_dependencies.dart';
import 'package:ice_line_tracker/data/api/api_client.dart';
import 'package:ice_line_tracker/data/api/nhl_club_schedule_service.dart';
import 'package:ice_line_tracker/data/api/nhl_club_stats_service.dart';
import 'package:ice_line_tracker/data/api/nhl_gamecenter_service.dart';
import 'package:ice_line_tracker/data/api/nhl_player_service.dart';
import 'package:ice_line_tracker/data/api/nhl_roster_service.dart';
import 'package:ice_line_tracker/data/api/nhl_schedule_service.dart';
import 'package:ice_line_tracker/data/api/nhl_seasons_service.dart';
import 'package:ice_line_tracker/data/api/nhl_standings_service.dart';
import 'package:ice_line_tracker/data/local/database/hive_json_cache.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/repositories/bootstrap_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_bootstrap_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_schedule_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_team_repository.dart';
import 'package:ice_line_tracker/data/repositories/game_center_repository.dart';
import 'package:ice_line_tracker/data/repositories/player_repository.dart';
import 'package:ice_line_tracker/data/repositories/schedule_repository.dart';
import 'package:ice_line_tracker/data/repositories/standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/team_repository.dart';
import 'package:ice_line_tracker/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _isDevicePreviewAvailable() => kDebugMode;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsStore = PrefsStore(sharedPrefs);
  final favoritesStore = FavoritesStore(sharedPrefs);
  final diskCache = await HiveJsonCache.open();

  final notificationService = NotificationService(
    prefsStore: prefsStore,
    favoritesStore: favoritesStore,
  );
  await notificationService.initializeCore();
  await notificationService.syncFinalAlerts();

  final apiClient = ApiClient();

  final remoteBootstrap = BootstrapRepository(
    standingsService: NhlStandingsService(apiClient.dio),
    seasonsService: NhlSeasonsService(apiClient.dio),
  );
  final cachedBootstrapRepository = CachedBootstrapRepository(
    remote: remoteBootstrap,
    diskCache: diskCache,
  );

  final remoteSchedule = ScheduleRepository(
    scheduleService: NhlScheduleService(apiClient.dio),
  );
  final cachedScheduleRepository = CachedScheduleRepository(
    remote: remoteSchedule,
    diskCache: diskCache,
  );

  final remoteStandings = StandingsRepository(
    standingsService: NhlStandingsService(apiClient.dio),
  );
  final cachedStandingsRepository = CachedStandingsRepository(
    remote: remoteStandings,
    diskCache: diskCache,
  );

  final gameCenterRepository = GameCenterRepository(
    service: NhlGameCenterService(apiClient.dio),
  );
  final teamRepository = TeamRepository(
    rosterService: NhlRosterService(apiClient.dio),
    clubStatsService: NhlClubStatsService(apiClient.dio),
    clubScheduleService: NhlClubScheduleService(apiClient.dio),
  );
  final cachedTeamRepository = CachedTeamRepository(
    remote: teamRepository,
    diskCache: diskCache,
  );
  final playerRepository = PlayerRepository(
    service: NhlPlayerService(apiClient.dio),
  );

  runApp(
    DevicePreview(
      enabled: _isDevicePreviewAvailable(),
      storage: DevicePreviewStorage.none(),
      data: const DevicePreviewData(
        isToolbarVisible: false,
        isFrameVisible: false,
      ),
      builder: (context) => App(
        dependencies: AppDependencies(
          prefsStore: prefsStore,
          favoritesStore: favoritesStore,
          diskCache: diskCache,
          notificationService: notificationService,
          cachedBootstrapRepository: cachedBootstrapRepository,
          cachedScheduleRepository: cachedScheduleRepository,
          cachedStandingsRepository: cachedStandingsRepository,
          gameCenterRepository: gameCenterRepository,
          cachedTeamRepository: cachedTeamRepository,
          playerRepository: playerRepository,
        ),
      ),
    ),
  );
}
