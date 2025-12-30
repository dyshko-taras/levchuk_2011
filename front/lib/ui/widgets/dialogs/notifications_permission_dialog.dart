import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsPermissionDialog {
  const NotificationsPermissionDialog._();

  static Future<void> show(BuildContext context) async {
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
}
