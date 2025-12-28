import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/repositories/game_center_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class GameCenterProvider extends ChangeNotifier {
  GameCenterProvider({
    required GameCenterRepository repository,
  }) : _repository = repository;

  final GameCenterRepository _repository;

  int? _activeGameId;
  int? get activeGameId => _activeGameId;

  AsyncState<Object?> _playByPlayState = const AsyncEmpty();
  AsyncState<Object?> get playByPlayState => _playByPlayState;

  AsyncState<Object?> _landingState = const AsyncEmpty();
  AsyncState<Object?> get landingState => _landingState;

  AsyncState<Object?> _boxscoreState = const AsyncEmpty();
  AsyncState<Object?> get boxscoreState => _boxscoreState;

  Future<void> loadGame(int gameId, {bool forceRefresh = false}) async {
    final changedGame = _activeGameId != gameId;
    _activeGameId = gameId;

    if (changedGame) {
      _playByPlayState = const AsyncEmpty();
      _landingState = const AsyncEmpty();
      _boxscoreState = const AsyncEmpty();
      notifyListeners();
    }

    await ensurePlayByPlay(forceRefresh: forceRefresh);
  }

  Future<void> ensurePlayByPlay({bool forceRefresh = false}) async {
    final gameId = _activeGameId;
    if (gameId == null) return;
    if (!forceRefresh && _playByPlayState is AsyncData<Object?>) return;

    _playByPlayState = const AsyncLoading();
    notifyListeners();

    try {
      final data = await _repository.getPlayByPlay(gameId);
      _playByPlayState = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _playByPlayState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> ensureLanding({bool forceRefresh = false}) async {
    final gameId = _activeGameId;
    if (gameId == null) return;
    if (!forceRefresh && _landingState is AsyncData<Object?>) return;

    _landingState = const AsyncLoading();
    notifyListeners();

    try {
      final data = await _repository.getLanding(gameId);
      _landingState = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _landingState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> ensureBoxscore({bool forceRefresh = false}) async {
    final gameId = _activeGameId;
    if (gameId == null) return;
    if (!forceRefresh && _boxscoreState is AsyncData<Object?>) return;

    _boxscoreState = const AsyncLoading();
    notifyListeners();

    try {
      final data = await _repository.getBoxscore(gameId);
      _boxscoreState = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _boxscoreState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await ensurePlayByPlay(forceRefresh: true);
    if (_landingState is! AsyncEmpty<Object?>) {
      await ensureLanding(forceRefresh: true);
    }
    if (_boxscoreState is! AsyncEmpty<Object?>) {
      await ensureBoxscore(forceRefresh: true);
    }
  }
}
