import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/repositories/game_center_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class GameCenterData {
  const GameCenterData({
    required this.playByPlay,
    required this.landing,
    required this.boxscore,
  });

  final Object? playByPlay;
  final Object? landing;
  final Object? boxscore;
}

class GameCenterProvider extends ChangeNotifier {
  GameCenterProvider({
    required GameCenterRepository repository,
  }) : _repository = repository;

  final GameCenterRepository _repository;

  int? _activeGameId;
  int? get activeGameId => _activeGameId;

  AsyncState<GameCenterData> _state = const AsyncEmpty();
  AsyncState<GameCenterData> get state => _state;

  Future<void> loadGame(int gameId, {bool forceRefresh = false}) async {
    _activeGameId = gameId;
    _state = const AsyncLoading();
    notifyListeners();

    try {
      final results = await Future.wait<Object?>([
        _repository.getPlayByPlay(gameId),
        _repository.getLanding(gameId),
        _repository.getBoxscore(gameId),
      ]);
      _state = AsyncData(
        GameCenterData(
          playByPlay: results[0],
          landing: results[1],
          boxscore: results[2],
        ),
      );
      notifyListeners();
    } on Object catch (e, st) {
      _state = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final id = _activeGameId;
    if (id == null) return;
    return loadGame(id, forceRefresh: true);
  }
}
