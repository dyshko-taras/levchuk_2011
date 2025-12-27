import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: Insets.allXl,
        children: [
          if (kDebugMode)
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.devicePreview),
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
          if (!kDebugMode)
            const Text(
              AppStrings.settingsTitle,
            ),
        ],
      ),
    );
  }
}
