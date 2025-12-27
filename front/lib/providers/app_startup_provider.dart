import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/repositories/cached_bootstrap_repository.dart';

enum AppStartupStatus {
  idle,
  loading,
  ready,
  error,
}

class AppStartupProvider extends ChangeNotifier {
  AppStartupProvider({
    required CachedBootstrapRepository bootstrap,
    required PrefsStore prefsStore,
  }) : _bootstrap = bootstrap,
       _prefsStore = prefsStore;

  final CachedBootstrapRepository _bootstrap;
  final PrefsStore _prefsStore;

  static const Duration minSplashDuration = Duration(milliseconds: 5000);

  AppStartupStatus _status = AppStartupStatus.idle;
  AppStartupStatus get status => _status;

  Object? _error;
  Object? get error => _error;

  String? _nextRoute;
  String? get nextRoute => _nextRoute;

  bool get isLoading => _status == AppStartupStatus.loading;

  Future<void> start() async {
    if (_status == AppStartupStatus.loading ||
        _status == AppStartupStatus.ready) {
      return;
    }

    _status = AppStartupStatus.loading;
    _error = null;
    _nextRoute = null;
    notifyListeners();

    final startTime = DateTime.now();

    try {
      await Future.wait([
        _bootstrap.getTeams(),
        _bootstrap.getSeasons(),
      ]);

      final elapsed = DateTime.now().difference(startTime);
      if (elapsed < minSplashDuration) {
        await Future<void>.delayed(minSplashDuration - elapsed);
      }

      _nextRoute = _prefsStore.getFirstRun()
          ? AppRoutes.welcome
          : AppRoutes.home;
      _status = AppStartupStatus.ready;
      notifyListeners();
    } on Object catch (e) {
      _error = e;
      _status = AppStartupStatus.error;
      notifyListeners();
    }
  }

  String? consumeNextRoute() {
    final route = _nextRoute;
    _nextRoute = null;
    return route;
  }

  Future<void> retry() => start();
}
