import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_images.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/providers/prefs_provider.dart';
import 'package:ice_line_tracker/providers/settings_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/buttons/primary_button.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void _onGetStartedPressed() {
    unawaited(_getStarted());
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PrefsProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _WelcomeHero(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    AppSpacing.x2l,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.welcomeDefaultDateLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppSegmentedControl<DefaultDatePreset>(
                        items: const [
                          AppSegmentedControlItem(
                            value: DefaultDatePreset.today,
                            label: AppStrings.today,
                          ),
                          AppSegmentedControlItem(
                            value: DefaultDatePreset.yesterday,
                            label: AppStrings.yesterday,
                          ),
                          AppSegmentedControlItem(
                            value: DefaultDatePreset.tomorrow,
                            label: AppStrings.tomorrow,
                          ),
                        ],
                        value: prefs.draftDefaultDatePreset,
                        onChanged: prefs.setDraftDefaultDatePreset,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.welcomePushAlertsLabel,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Switch.adaptive(
                            value: prefs.draftFinalAlertsEnabled,
                            onChanged: prefs.saving
                                ? null
                                : (v) => unawaited(
                                    _onFinalAlertsChanged(context, v),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppStrings.welcomePushAlertsHelper,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      PrimaryButton(
                        label: AppStrings.getStarted,
                        isLoading: prefs.saving,
                        onPressed: prefs.saving ? null : _onGetStartedPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getStarted() async {
    final prefs = context.read<PrefsProvider>();
    await prefs.completeWelcome();

    if (!mounted) return;
    context.read<SettingsProvider>().reloadFromPrefs();
    await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  Future<void> _onFinalAlertsChanged(BuildContext context, bool enabled) async {
    final prefs = context.read<PrefsProvider>();
    final ok = await prefs.setDraftFinalAlertsEnabled(enabled: enabled);
    if (!ok && context.mounted) {
      await _showNotificationsPermissionDialog(context);
    }
  }
}

class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero();

  static const double _heightFactor = 0.52;
  static const double _minHeight = 320;
  static const double _maxHeight = 520;

  static const double _overlayAlphaTop = 0.30;
  static const double _overlayAlphaMid = 0.50;
  static const double _overlayAlphaBottom = 0.85;
  static const List<double> _overlayStops = [0, 0.55, 0.82, 1];

  static const double _titleFontSize = 28;
  static const double _descriptionFontSize = 18;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final heroHeight = (height * _heightFactor).clamp(_minHeight, _maxHeight);

    return SizedBox(
      height: heroHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppImages.welcomeHero,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: _overlayAlphaTop),
                    Colors.white.withValues(alpha: _overlayAlphaMid),
                    AppColors.backgroundWhite.withValues(
                      alpha: _overlayAlphaBottom,
                    ),
                    AppColors.backgroundWhite,
                  ],
                  stops: _overlayStops,
                ),
              ),
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.welcomeTitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.heading1.copyWith(
                      fontSize: _titleFontSize,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AppStrings.welcomeDescription,
                    textAlign: TextAlign.center,
                    style: AppFonts.bodyLarge.copyWith(
                      fontSize: _descriptionFontSize,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showNotificationsPermissionDialog(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(AppStrings.notificationsPermissionTitle),
        content: const Text(AppStrings.notificationsPermissionBody),
        actions: [
          TextButton(
            onPressed: () => unawaited(openAppSettings()),
            child: const Text(AppStrings.openSystemSettings),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      );
    },
  );
}
