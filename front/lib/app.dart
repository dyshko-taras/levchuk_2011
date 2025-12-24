import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_theme.dart';

/// Application root widget.
class App extends StatelessWidget {
  /// Creates the application root widget.
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    const enableDevicePreview = !kReleaseMode && !kProfileMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.splashBrandTitle,
      locale: enableDevicePreview ? DevicePreview.locale(context) : null,
      builder: enableDevicePreview ? DevicePreview.appBuilder : null,
      theme: appTheme(),
      home: const Scaffold(
        body: Center(child: Text(AppStrings.splashBrandTitle)),
      ),
    );
  }
}
