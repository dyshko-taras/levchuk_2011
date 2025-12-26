import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/app_dependencies.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/app_startup_provider.dart';
import 'package:ice_line_tracker/providers/prefs_provider.dart';
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
        Provider.value(value: dependencies.diskCache),
        Provider.value(value: dependencies.cachedBootstrapRepository),
        ChangeNotifierProvider(
          create: (_) => PrefsProvider(dependencies.prefsStore),
        ),
        ChangeNotifierProvider(
          create: (_) => AppStartupProvider(
            bootstrap: dependencies.cachedBootstrapRepository,
            prefsStore: dependencies.prefsStore,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: AppStrings.splashBrandTitle,
        locale: enableDevicePreview ? DevicePreview.locale(context) : null,
        builder: enableDevicePreview ? DevicePreview.appBuilder : null,
        theme: appTheme(),
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
      ),
    );
  }
}
