import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/providers/settings_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _versionLabel;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVersion());
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      _versionLabel = AppStrings.settingsVersionLabel
          .replaceFirst('{version}', info.version)
          .replaceFirst('{build}', info.buildNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: Insets.allLg,
        children: [
          const Text(AppStrings.dateDefaults, style: AppFonts.heading2),
          Gaps.hSm,
          AppSegmentedControl<DefaultDatePreset>(
            value: settings.defaultDatePreset,
            onChanged: (preset) => unawaited(
              settings.setDefaultDatePreset(preset),
            ),
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
          ),
          Gaps.hXl,
          const Text(AppStrings.notifications, style: AppFonts.heading2),
          Gaps.hSm,
          _SwitchRow(
            label: AppStrings.goalAlerts,
            value: settings.goalAlertsEnabled,
            onChanged: (v) =>
                unawaited(settings.setGoalAlertsEnabled(enabled: v)),
          ),
          _SwitchRow(
            label: AppStrings.finalAlerts,
            value: settings.finalAlertsEnabled,
            onChanged: (v) =>
                unawaited(settings.setFinalAlertsEnabled(enabled: v)),
          ),
          _SwitchRow(
            label: AppStrings.preGameReminders,
            value: settings.preGameRemindersEnabled,
            onChanged: (v) =>
                unawaited(settings.setPreGameRemindersEnabled(enabled: v)),
          ),
          Gaps.hXl,
          const Text(AppStrings.appSection, style: AppFonts.heading2),
          Gaps.hSm,
          const _InfoCard(text: AppStrings.poweredByNhlStatsApiV1),
          Gaps.hMd,
          _NavRow(
            label: AppStrings.appVersion,
            trailing: _versionLabel,
            onTap: _versionLabel == null
                ? null
                : () => _openAppVersion(context, _versionLabel!),
          ),
          Gaps.hMd,
          _NavRow(
            label: AppStrings.openSourceLicenses,
            onTap: () => showLicensePage(context: context),
          ),
          if (kDebugMode) ...[
            Gaps.hXl,
            const Text(AppStrings.devicePreview, style: AppFonts.heading2),
            Gaps.hSm,
            _SwitchRow(
              label: AppStrings.devicePreview,
              value: settings.devicePreviewEnabled,
              onChanged: (value) {
                final store = context.read<DevicePreviewStore>();
                store.data = store.data.copyWith(
                  isToolbarVisible: value,
                  isFrameVisible: value,
                  isEnabled: value,
                );
                unawaited(settings.setDevicePreviewEnabled(enabled: value));
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});

  final String text;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.segmentedControl,
        borderRadius: AppRadius.md,
        border: Border.all(color: _borderColor, width: _borderWidth),
      ),
      padding: Insets.allLg,
      child: Text(
        text,
        style: AppFonts.bodyRegular.copyWith(color: AppColors.textBlack),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final String? trailing;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.segmentedControl,
            borderRadius: AppRadius.md,
            border: Border.all(color: _borderColor, width: _borderWidth),
          ),
          padding: Insets.allLg,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.bodySemibold.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: AppFonts.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gaps.wSm,
              ],
              SvgPicture.asset(
                AppIcons.chevronRight,
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                colorFilter: const ColorFilter.mode(
                  AppColors.textBlack,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openAppVersion(BuildContext context, String version) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(AppStrings.appVersion),
        content: Text(version),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.ok),
          ),
        ],
      );
    },
  );
}
