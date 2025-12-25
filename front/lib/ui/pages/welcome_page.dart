import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _getStarted(BuildContext context) async {
    final prefs = await PrefsStore.create();
    await prefs.setFirstRun(value: false);

    if (!context.mounted) return;
    await Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.welcomeTitle)),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _getStarted(context),
          child: const Text(AppStrings.getStarted),
        ),
      ),
    );
  }
}
