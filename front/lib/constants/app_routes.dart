import 'package:flutter/widgets.dart';
import 'package:ice_line_tracker/enums/main_tab.dart';
import 'package:ice_line_tracker/ui/pages/game_center_page.dart';
import 'package:ice_line_tracker/ui/pages/main_shell_page.dart';
import 'package:ice_line_tracker/ui/pages/settings_page.dart';
import 'package:ice_line_tracker/ui/pages/splash_page.dart';
import 'package:ice_line_tracker/ui/pages/team_page.dart';
import 'package:ice_line_tracker/ui/pages/welcome_page.dart';

/// App route names.
class AppRoutes {
  const AppRoutes._();

  /// Splash screen.
  static const String splash = '/splash';

  /// Welcome/onboarding screen.
  static const String welcome = '/welcome';

  /// Root/Main shell entry.
  static const String root = '/';

  /// Home tab.
  static const String home = '/home';

  /// Standings tab.
  static const String standings = '/standings';

  /// Compare tab.
  static const String compare = '/compare';

  /// Favorites tab.
  static const String favorites = '/favorites';

  /// Predictions tab.
  static const String predictions = '/predictions';

  /// Settings page.
  static const String settings = '/settings';

  /// Game center details.
  static const String gameCenter = '/game-center';

  /// Team page.
  static const String team = '/team';

  /// Player page.
  static const String player = '/player';

  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
    splash: (_) => const SplashPage(),
    welcome: (_) => const WelcomePage(),
    root: (_) => const MainShellPage(initialTab: MainTab.home),
    home: (_) => const MainShellPage(initialTab: MainTab.home),
    standings: (_) => const MainShellPage(initialTab: MainTab.standings),
    compare: (_) => const MainShellPage(initialTab: MainTab.compare),
    favorites: (_) => const MainShellPage(initialTab: MainTab.favorites),
    predictions: (_) => const MainShellPage(
      initialTab: MainTab.predictions,
    ),
    settings: (_) => const SettingsPage(),
    gameCenter: (_) => const GameCenterPage(),
    team: (_) => const TeamPage(),
  };
}
