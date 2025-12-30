// ignore_for_file: unreachable_from_main // WorkManager runs callback in background isolate.

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/core/endpoints.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:workmanager/workmanager.dart';

const String _kFinalAlertTaskName = 'final_alert_notification';
const String _kFinalAlertChannelId = 'final_alerts';
const String _kFinalAlertChannelName = 'Final alerts';

const Duration _estimatedGameDuration = Duration(minutes: 165);
const Duration _pollDelay = Duration(minutes: 10);
const int _maxPollAttempts = 18;

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task != _kFinalAlertTaskName) return true;
    final gameId = inputData?['gameId'];
    if (gameId is! int) return true;

    final awayAbbrev =
        inputData?['awayTeam'] as String? ?? AppStrings.notAvailable;
    final homeAbbrev =
        inputData?['homeTeam'] as String? ?? AppStrings.notAvailable;
    final attempt = inputData?['attempt'] as int? ?? 0;

    final notifications = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await notifications.initialize(settings);

    final landing = await _fetchLanding(gameId);
    final isFinal = _isFinalFromLanding(landing);
    if (!isFinal) {
      if (attempt >= _maxPollAttempts) return true;

      await Workmanager().registerOneOffTask(
        _finalAlertUniqueName(gameId),
        _kFinalAlertTaskName,
        initialDelay: _pollDelay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        inputData: <String, Object?>{
          'gameId': gameId,
          'awayTeam': awayAbbrev,
          'homeTeam': homeAbbrev,
          'attempt': attempt + 1,
        },
      );
      return true;
    }

    const androidDetails = AndroidNotificationDetails(
      _kFinalAlertChannelId,
      _kFinalAlertChannelName,
      channelDescription: 'Final score alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    final (title, body) = _finalNotificationText(
      landing,
      awayFallback: awayAbbrev,
      homeFallback: homeAbbrev,
    );

    await notifications.show(
      gameId,
      title,
      body,
      const NotificationDetails(android: androidDetails),
      payload: 'route=${AppRoutes.gameCenter}&gameId=$gameId',
    );

    return true;
  });
}

class NotificationService {
  NotificationService({
    required PrefsStore prefsStore,
    required FavoritesStore favoritesStore,
  }) : _prefs = prefsStore,
       _favorites = favoritesStore;

  final PrefsStore _prefs;
  final FavoritesStore _favorites;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initializeCore() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    await Workmanager().initialize(
      callbackDispatcher,
    );

    _initialized = true;
  }

  Future<bool> ensureNotificationPermission() async {
    if (!_initialized) await initializeCore();

    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;

    final enabled = await android.areNotificationsEnabled() ?? true;
    if (enabled) return true;

    await android.requestNotificationsPermission();
    return (await android.areNotificationsEnabled()) ?? false;
  }

  Future<void> scheduleFinalAlert(NhlScheduledGame game) async {
    if (!_initialized) await initializeCore();
    if (!_prefs.getFinalAlertsEnabled()) return;

    final startUtc = DateTime.tryParse(game.startTimeUTC)?.toUtc();
    if (startUtc == null) return;
    if (game.gameState.toUpperCase() == 'FINAL' ||
        game.gameState.toUpperCase() == 'OFF') {
      return;
    }

    final estimatedEndUtc = startUtc.add(_estimatedGameDuration);
    final delay = estimatedEndUtc.difference(DateTime.now().toUtc());
    if (delay.isNegative) return;

    await Workmanager().registerOneOffTask(
      _finalAlertUniqueName(game.id),
      _kFinalAlertTaskName,
      initialDelay: delay,
      inputData: <String, Object?>{
        'gameId': game.id,
        'awayTeam': game.awayTeam.abbrev,
        'homeTeam': game.homeTeam.abbrev,
      },
    );
  }

  Future<void> cancelFinalAlert(int gameId) async {
    if (!_initialized) await initializeCore();
    await Workmanager().cancelByUniqueName(_finalAlertUniqueName(gameId));
    await _notifications.cancel(gameId);
  }

  Future<void> syncFinalAlerts() async {
    if (!_initialized) await initializeCore();

    final finalEnabledGlobally = _prefs.getFinalAlertsEnabled();
    final favoriteGameIds = _favorites.getFavoriteGameIds();

    for (final gameId in favoriteGameIds) {
      final enabledPerGame =
          _favorites.getGameAlertEnabled(gameId, GameAlertType.final_);

      if (!finalEnabledGlobally || !enabledPerGame) {
        await cancelFinalAlert(gameId);
        continue;
      }

      final game = _favorites.getFavoriteGame(gameId);
      if (game == null) continue;
      await scheduleFinalAlert(game);
    }
  }

  Future<bool> showTestFinalAlert() async {
    final granted = await ensureNotificationPermission();
    if (!granted) return false;

    const androidDetails = AndroidNotificationDetails(
      _kFinalAlertChannelId,
      _kFinalAlertChannelName,
      channelDescription: 'Final score alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    await _notifications.show(
      id,
      AppStrings.final_,
      AppStrings.testNotificationBody,
      const NotificationDetails(android: androidDetails),
      payload: 'route=${AppRoutes.gameCenter}&gameId=0',
    );

    return true;
  }
}

String _finalAlertUniqueName(int gameId) => 'final_alert_$gameId';

Future<Map<String, Object?>?> _fetchLanding(int gameId) async {
  try {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.nhlWebApiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: <String, Object?>{
          'Accept': 'application/json',
        },
      ),
    );

    final res = await dio.get<Object>('/gamecenter/$gameId/landing');
    final data = res.data;
    if (data is Map) {
      return data.cast<String, Object?>();
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return decoded.cast<String, Object?>();
      }
    }
  } on Object {
    // Ignore and allow retry polling.
  }
  return null;
}

bool _isFinalFromLanding(Map<String, Object?>? landing) {
  final raw = landing;
  if (raw == null) return false;

  final gameState = raw['gameState'];
  if (gameState is String) {
    final v = gameState.toUpperCase();
    if (v == 'FINAL' || v == 'OFF') return true;
  }

  final scheduleState = raw['gameScheduleState'];
  if (scheduleState is String && scheduleState.toUpperCase() == 'OFF') {
    return true;
  }

  return false;
}

(String title, String body) _finalNotificationText(
  Map<String, Object?>? landing, {
  required String awayFallback,
  required String homeFallback,
}) {
  final raw = landing;
  if (raw == null) return (AppStrings.final_, '$awayFallback @ $homeFallback');

  final home = raw['homeTeam'];
  final away = raw['awayTeam'];

  final homeMap = home is Map ? home.cast<String, Object?>() : null;
  final awayMap = away is Map ? away.cast<String, Object?>() : null;

  final homeAbbrev = (homeMap?['abbrev'] as String?) ?? homeFallback;
  final awayAbbrev = (awayMap?['abbrev'] as String?) ?? awayFallback;

  final homeScore = homeMap?['score'];
  final awayScore = awayMap?['score'];

  if (homeScore is num && awayScore is num) {
    return (
      AppStrings.final_,
      '$awayAbbrev ${awayScore.toInt()} – ${homeScore.toInt()} $homeAbbrev',
    );
  }

  return (AppStrings.final_, '$awayAbbrev @ $homeAbbrev');
}
