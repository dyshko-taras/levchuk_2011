import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._store) {
    _favoriteTeamAbbrevs = _store.getFavoriteTeamAbbrevs();
    _favoriteGameIds = _store.getFavoriteGameIds();
  }

  final FavoritesStore _store;

  late Set<String> _favoriteTeamAbbrevs;
  Set<String> get favoriteTeamAbbrevs => _favoriteTeamAbbrevs;

  late Set<int> _favoriteGameIds;
  Set<int> get favoriteGameIds => _favoriteGameIds;

  bool isFavoriteTeam(String teamAbbrev) =>
      _favoriteTeamAbbrevs.contains(teamAbbrev);
  bool isFavoriteGame(int gameId) => _favoriteGameIds.contains(gameId);

  NhlScheduledGame? getFavoriteGame(int gameId) =>
      _store.getFavoriteGame(gameId);

  Future<bool> toggleFavoriteTeam(String teamAbbrev) async {
    final added = await _store.toggleFavoriteTeam(teamAbbrev);
    _favoriteTeamAbbrevs = _store.getFavoriteTeamAbbrevs();
    notifyListeners();
    return added;
  }

  Future<bool> toggleFavoriteGame(
    int gameId, {
    NhlScheduledGame? game,
  }) async {
    final added = await _store.toggleFavoriteGame(gameId, game: game);
    _favoriteGameIds = _store.getFavoriteGameIds();
    notifyListeners();
    return added;
  }

  bool getGameAlertEnabled(int gameId, GameAlertType type) =>
      _store.getGameAlertEnabled(gameId, type);

  Future<void> setGameAlertEnabled(
    int gameId,
    GameAlertType type, {
    required bool enabled,
  }) async {
    await _store.setGameAlertEnabled(gameId, type, enabled: enabled);
    notifyListeners();
  }
}
