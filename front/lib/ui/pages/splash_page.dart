import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/app_startup_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_started) return;
      _started = true;
      unawaited(context.read<AppStartupProvider>().start());
    });
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Column(
                children: [
                  Text(
                    AppStrings.splashBrandTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.splashBrandSubtitle,
                    textAlign: TextAlign.center,
                    style: AppFonts.heading1.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.splashTagline,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
              const Spacer(flex: 4),
              if (startup.error == null)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    children: [
                      const Text(AppStrings.splashInitFailed),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: startup.retry,
                        child: const Text(AppStrings.refresh),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
