import 'dart:convert';

import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameAlertType {
  final_,
}

class FavoritesStore {
  FavoritesStore(this._prefs);

  final SharedPreferences _prefs;

  static const _kFavoriteTeams = 'favorites_teams';
  static const _kFavoriteGames = 'favorites_games';

  static String _gameAlertKey(int gameId, GameAlertType type) =>
      'favorite_game_${gameId}_alert_${type.name}';

  static String _gameDataKey(int gameId) => 'favorite_game_${gameId}_data_v1';

  Set<String> getFavoriteTeamAbbrevs() =>
      (_prefs.getStringList(_kFavoriteTeams) ?? const <String>[]).toSet();

  Future<void> setFavoriteTeamAbbrevs(Set<String> abbrevs) =>
      _prefs.setStringList(_kFavoriteTeams, abbrevs.toList()..sort());

  Future<bool> toggleFavoriteTeam(String teamAbbrev) async {
    final current = getFavoriteTeamAbbrevs();
    final added = current.add(teamAbbrev);
    if (!added) {
      current.remove(teamAbbrev);
    }
    await setFavoriteTeamAbbrevs(current);
    return added;
  }

  Set<int> getFavoriteGameIds() =>
      (_prefs.getStringList(_kFavoriteGames) ?? const <String>[])
          .map(int.tryParse)
          .whereType<int>()
          .toSet();

  Future<void> setFavoriteGameIds(Set<int> gameIds) => _prefs.setStringList(
    _kFavoriteGames,
    gameIds.map((e) => e.toString()).toList()..sort(),
  );

  NhlScheduledGame? getFavoriteGame(int gameId) {
    final json = _prefs.getString(_gameDataKey(gameId));
    if (json == null || json.isEmpty) return null;
    try {
      return NhlScheduledGame.fromJson(
        Map<String, Object?>.from(jsonDecode(json) as Map),
      );
    } on Object {
      return null;
    }
  }

  Future<void> setFavoriteGame(int gameId, NhlScheduledGame game) async {
    await _prefs.setString(_gameDataKey(gameId), jsonEncode(game.toJson()));
  }

  Future<bool> toggleFavoriteGame(
    int gameId, {
    NhlScheduledGame? game,
  }) async {
    final current = getFavoriteGameIds();
    final added = current.add(gameId);
    if (!added) {
      current.remove(gameId);
      await _prefs.remove(_gameAlertKey(gameId, GameAlertType.final_));
      await _prefs.remove(_legacyGoalsAlertKey(gameId));
      await _prefs.remove(_gameDataKey(gameId));
    } else if (game != null) {
      await setFavoriteGame(gameId, game);
    }
    await setFavoriteGameIds(current);
    return added;
  }

  bool getGameAlertEnabled(int gameId, GameAlertType type) =>
      _prefs.getBool(_gameAlertKey(gameId, type)) ?? false;

  Future<void> setGameAlertEnabled(
    int gameId,
    GameAlertType type, {
    required bool enabled,
  }) => _prefs.setBool(_gameAlertKey(gameId, type), enabled);
}

String _legacyGoalsAlertKey(int gameId) =>
    'favorite_game_${gameId}_alert_goals';
