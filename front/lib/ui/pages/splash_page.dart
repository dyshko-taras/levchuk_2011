import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _routeNext();
    });
  }

  Future<void> _routeNext() async {
    final prefs = await PrefsStore.create();
    final firstRun = prefs.getFirstRun();

    if (!mounted) return;

    final nextRoute = firstRun ? AppRoutes.welcome : AppRoutes.home;
    await Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppStrings.splashBrandTitle),
      ),
    );
  }
}
