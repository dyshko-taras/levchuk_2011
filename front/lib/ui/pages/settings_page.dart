import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: const Center(child: Text(AppStrings.settingsTitle)),
    );
  }
}
