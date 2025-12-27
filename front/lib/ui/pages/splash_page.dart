import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/app_startup_provider.dart';
import 'package:ice_line_tracker/providers/settings_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _started = false;

  static const int _topSpacerFlex = 3;
  static const int _bottomSpacerFlex = 4;
  static const double _progressStrokeWidth = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_started) return;
      _started = true;
      _syncDevicePreviewFromSettings();
      unawaited(context.read<AppStartupProvider>().start());
    });
  }

  void _syncDevicePreviewFromSettings() {
    if (!kDebugMode || !mounted) return;

    final settings = context.read<SettingsProvider>();
    final enabled = settings.devicePreviewEnabled;

    final store = context.read<DevicePreviewStore>();
    store.data = store.data.copyWith(
      isToolbarVisible: enabled,
      isFrameVisible: enabled,
      isEnabled: enabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final startup = context.watch<AppStartupProvider>();
    final nextRoute = startup.consumeNextRoute();
    if (nextRoute != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(Navigator.of(context).pushReplacementNamed(nextRoute));
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.sidePadding),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Spacer(flex: _topSpacerFlex),
                Column(
                  children: [
                    Text(
                      AppStrings.splashBrandTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Gaps.hSm,
                    Text(
                      AppStrings.splashBrandSubtitle,
                      textAlign: TextAlign.center,
                      style: AppFonts.heading1.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    Gaps.hXl,
                    Text(
                      AppStrings.splashTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const Spacer(flex: _bottomSpacerFlex),
                if (startup.error == null)
                  const Padding(
                    padding: Insets.vXl,
                    child: CircularProgressIndicator(
                      strokeWidth: _progressStrokeWidth,
                    ),
                  )
                else
                  Padding(
                    padding: Insets.vXl,
                    child: Column(
                      children: [
                        const Text(AppStrings.splashInitFailed),
                        Gaps.hLg,
                        ElevatedButton(
                          onPressed: startup.retry,
                          child: const Text(AppStrings.refresh),
                        ),
                      ],
                    ),
                  ),
                Gaps.hSm,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
