import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_schedule_repository.dart';
import 'package:ice_line_tracker/data/repositories/game_center_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class HomeGameDetails {
  const HomeGameDetails({
    required this.periodNumber,
    required this.periodType,
    required this.timeRemaining,
    required this.awaySog,
    required this.homeSog,
    required this.inIntermission,
    required this.gameState,
    required this.gameScheduleState,
  });

  final int? periodNumber;
  final String? periodType;
  final String? timeRemaining;
  final int? awaySog;
  final int? homeSog;
  final bool? inIntermission;
  final String? gameState;
  final String? gameScheduleState;
}

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required CachedScheduleRepository schedule,
    required PrefsStore prefsStore,
    required FavoritesStore favoritesStore,
    required GameCenterRepository gameCenter,
  }) : _schedule = schedule,
       _prefsStore = prefsStore,
       _favoritesStore = favoritesStore,
       _gameCenter = gameCenter;

  final CachedScheduleRepository _schedule;
  final PrefsStore _prefsStore;
  final FavoritesStore _favoritesStore;
  final GameCenterRepository _gameCenter;

  String? _activeDateYyyyMmDd;
  String? get activeDateYyyyMmDd => _activeDateYyyyMmDd;

  AsyncState<NhlScheduleResponse> _state = const AsyncEmpty();
  AsyncState<NhlScheduleResponse> get state => _state;

  bool _showingCached = false;
  bool get showingCached => _showingCached;

  NhlScheduleResponse? _lastSuccessful;

  final Map<int, HomeGameDetails> _detailsByGameId = {};
  final Set<int> _detailsInFlight = <int>{};

  HomeGameDetails? detailsForGame(int gameId) => _detailsByGameId[gameId];

  Future<void> ensureGameDetails(int gameId) async {
    if (_detailsByGameId.containsKey(gameId)) return;
    if (_detailsInFlight.contains(gameId)) return;

    _detailsInFlight.add(gameId);
    try {
      final landing = await _gameCenter.getLanding(gameId);
      if (landing is! Map) return;

      final m = Map<String, Object?>.from(landing);
      final away = m['awayTeam'];
      final home = m['homeTeam'];
      final clock = m['clock'];
      final period = m['periodDescriptor'];

      final awaySog = away is Map
          ? (Map<String, Object?>.from(away)['sog'] as num?)
          : null;
      final homeSog = home is Map
          ? (Map<String, Object?>.from(home)['sog'] as num?)
          : null;

      final timeRemaining = clock is Map
          ? (Map<String, Object?>.from(clock)['timeRemaining'] as String?)
          : null;
      final inIntermission = clock is Map
          ? (Map<String, Object?>.from(clock)['inIntermission'] as bool?)
          : null;

      final periodNumber = period is Map
          ? (Map<String, Object?>.from(period)['number'] as num?)?.toInt()
          : null;
      final periodType = period is Map
          ? (Map<String, Object?>.from(period)['periodType'] as String?)
          : null;

      _detailsByGameId[gameId] = HomeGameDetails(
        periodNumber: periodNumber,
        periodType: periodType,
        timeRemaining: timeRemaining,
        awaySog: awaySog?.toInt(),
        homeSog: homeSog?.toInt(),
        inIntermission: inIntermission,
        gameState: m['gameState'] as String?,
        gameScheduleState: m['gameScheduleState'] as String?,
      );
      notifyListeners();
    } finally {
      _detailsInFlight.remove(gameId);
    }
  }

  Future<void> loadDefault({bool forceRefresh = false}) {
    return loadPreset(
      _prefsStore.getDefaultDatePreset(),
      forceRefresh: forceRefresh,
    );
  }

  Future<void> loadPreset(
    DefaultDatePreset preset, {
    bool forceRefresh = false,
  }) {
    final now = DateTime.now();
    final date = switch (preset) {
      DefaultDatePreset.today => now,
      DefaultDatePreset.yesterday => now.subtract(const Duration(days: 1)),
      DefaultDatePreset.tomorrow => now.add(const Duration(days: 1)),
    };
    return loadByDate(_toYyyyMmDd(date), forceRefresh: forceRefresh);
  }

  Future<void> loadByDate(
    String yyyyMmDd, {
    bool forceRefresh = false,
  }) async {
    _activeDateYyyyMmDd = yyyyMmDd;
    _state = const AsyncLoading();
    _showingCached = false;
    notifyListeners();

    try {
      final schedule = await _schedule.getScheduleByDate(
        yyyyMmDd,
        forceRefresh: forceRefresh,
      );
      _state = AsyncData(schedule);
      _lastSuccessful = schedule;
      _showingCached = false;
      _detailsByGameId.clear();
      notifyListeners();
    } on Object catch (e, st) {
      final last = _lastSuccessful;
      if (last != null) {
        _state = AsyncData(last);
        _showingCached = true;
      } else {
        _state = AsyncError(e, stackTrace: st);
      }
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final date = _activeDateYyyyMmDd;
    if (date == null) {
      return loadDefault(forceRefresh: true);
    }
    return loadByDate(date, forceRefresh: true);
  }

  bool isFavoriteTeam(String teamAbbrev) =>
      _favoritesStore.getFavoriteTeamAbbrevs().contains(teamAbbrev);

  bool isFavoriteGame(int gameId) =>
      _favoritesStore.getFavoriteGameIds().contains(gameId);

  Future<bool> toggleFavoriteTeam(String teamAbbrev) =>
      _favoritesStore.toggleFavoriteTeam(teamAbbrev);

  Future<bool> toggleFavoriteGame(int gameId) =>
      _favoritesStore.toggleFavoriteGame(gameId);

  bool getGameAlertEnabled(int gameId, GameAlertType type) =>
      _favoritesStore.getGameAlertEnabled(gameId, type);

  Future<void> setGameAlertEnabled(
    int gameId,
    GameAlertType type, {
    required bool enabled,
  }) => _favoritesStore.setGameAlertEnabled(gameId, type, enabled: enabled);

  static String _toYyyyMmDd(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
