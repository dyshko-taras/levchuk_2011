import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/app_dependencies.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/app_startup_provider.dart';
import 'package:ice_line_tracker/providers/compare_provider.dart';
import 'package:ice_line_tracker/providers/favorites_provider.dart';
import 'package:ice_line_tracker/providers/game_center_provider.dart';
import 'package:ice_line_tracker/providers/home_provider.dart';
import 'package:ice_line_tracker/providers/player_provider.dart';
import 'package:ice_line_tracker/providers/predictions_provider.dart';
import 'package:ice_line_tracker/providers/prefs_provider.dart';
import 'package:ice_line_tracker/providers/settings_provider.dart';
import 'package:ice_line_tracker/providers/shell_navigation_provider.dart';
import 'package:ice_line_tracker/providers/standings_provider.dart';
import 'package:ice_line_tracker/providers/team_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Application root widget.
class App extends StatelessWidget {
  /// Creates the application root widget.
  const App({
    required this.dependencies,
    super.key,
  });

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    const enableDevicePreview = !kReleaseMode && !kProfileMode;

    return MultiProvider(
      providers: [
        Provider.value(value: dependencies.prefsStore),
        Provider.value(value: dependencies.favoritesStore),
        Provider.value(value: dependencies.diskCache),
        Provider.value(value: dependencies.cachedBootstrapRepository),
        Provider.value(value: dependencies.cachedScheduleRepository),
        Provider.value(value: dependencies.cachedStandingsRepository),
        Provider.value(value: dependencies.gameCenterRepository),
        Provider.value(value: dependencies.cachedTeamRepository),
        Provider.value(value: dependencies.playerRepository),
        ChangeNotifierProvider(
          create: (_) => PrefsProvider(dependencies.prefsStore),
        ),
        ChangeNotifierProvider(
          create: (_) => AppStartupProvider(
            bootstrap: dependencies.cachedBootstrapRepository,
            prefsStore: dependencies.prefsStore,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ShellNavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(dependencies.favoritesStore),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(dependencies.prefsStore),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            schedule: dependencies.cachedScheduleRepository,
            prefsStore: dependencies.prefsStore,
            favoritesStore: dependencies.favoritesStore,
            gameCenter: dependencies.gameCenterRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => StandingsProvider(
            standings: dependencies.cachedStandingsRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GameCenterProvider(
            repository: dependencies.gameCenterRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => TeamProvider(
            repository: dependencies.cachedTeamRepository,
            standings: dependencies.cachedStandingsRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(
            repository: dependencies.playerRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CompareProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PredictionsProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.splashBrandTitle,
        theme: appTheme(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        locale: enableDevicePreview ? DevicePreview.locale(context) : null,
        builder: enableDevicePreview ? DevicePreview.appBuilder : null,
      ),
    );
  }
}
