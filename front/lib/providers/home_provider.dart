import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/local/prefs_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_schedule_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required CachedScheduleRepository schedule,
    required PrefsStore prefsStore,
    required FavoritesStore favoritesStore,
  }) : _schedule = schedule,
       _prefsStore = prefsStore,
       _favoritesStore = favoritesStore;

  final CachedScheduleRepository _schedule;
  final PrefsStore _prefsStore;
  final FavoritesStore _favoritesStore;

  String? _activeDateYyyyMmDd;
  String? get activeDateYyyyMmDd => _activeDateYyyyMmDd;

  AsyncState<NhlScheduleResponse> _state = const AsyncEmpty();
  AsyncState<NhlScheduleResponse> get state => _state;

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
    notifyListeners();

    try {
      final schedule = await _schedule.getScheduleByDate(
        yyyyMmDd,
        forceRefresh: forceRefresh,
      );
      _state = AsyncData(schedule);
      notifyListeners();
    } on Object catch (e, st) {
      _state = AsyncError(e, stackTrace: st);
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
