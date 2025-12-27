import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/repositories/player_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class PlayerProvider extends ChangeNotifier {
  PlayerProvider({required PlayerRepository repository})
    : _repository = repository;

  final PlayerRepository _repository;

  int? _playerId;
  int? get playerId => _playerId;

  AsyncState<Object?> _landingState = const AsyncEmpty();
  AsyncState<Object?> get landingState => _landingState;

  AsyncState<Object?> _gameLogState = const AsyncEmpty();
  AsyncState<Object?> get gameLogState => _gameLogState;

  Future<void> loadNow(int playerId) async {
    _playerId = playerId;
    notifyListeners();
    await Future.wait([
      loadLanding(playerId),
      loadGameLogNow(playerId),
    ]);
  }

  Future<void> loadLanding(int playerId) async {
    _landingState = const AsyncLoading();
    notifyListeners();
    try {
      final data = await _repository.getPlayerLanding(playerId);
      _landingState = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _landingState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> loadGameLogNow(int playerId) async {
    _gameLogState = const AsyncLoading();
    notifyListeners();
    try {
      final data = await _repository.getPlayerGameLogNow(playerId);
      _gameLogState = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _gameLogState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }
}
