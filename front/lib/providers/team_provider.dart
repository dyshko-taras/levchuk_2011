import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/repositories/team_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class TeamProvider extends ChangeNotifier {
  TeamProvider({required TeamRepository repository}) : _repository = repository;

  final TeamRepository _repository;

  String? _teamAbbrev;
  String? get teamAbbrev => _teamAbbrev;

  AsyncState<Object?> _rosterState = const AsyncEmpty();
  AsyncState<Object?> get rosterState => _rosterState;

  AsyncState<Object?> _clubStatsState = const AsyncEmpty();
  AsyncState<Object?> get clubStatsState => _clubStatsState;

  Future<void> loadCurrent(String teamAbbrev) async {
    _teamAbbrev = teamAbbrev;
    notifyListeners();
    await Future.wait([
      loadRosterCurrent(teamAbbrev),
      loadClubStatsNow(teamAbbrev),
    ]);
  }

  Future<void> loadRosterCurrent(String teamAbbrev) async {
    _rosterState = const AsyncLoading();
    notifyListeners();

    try {
      final roster = await _repository.getRosterCurrent(teamAbbrev);
      _rosterState = AsyncData(roster);
      notifyListeners();
    } on Object catch (e, st) {
      _rosterState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> loadClubStatsNow(String teamAbbrev) async {
    _clubStatsState = const AsyncLoading();
    notifyListeners();

    try {
      final stats = await _repository.getClubStatsNow(teamAbbrev);
      _clubStatsState = AsyncData(stats);
      notifyListeners();
    } on Object catch (e, st) {
      _clubStatsState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }
}
