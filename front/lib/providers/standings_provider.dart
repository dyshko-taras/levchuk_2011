import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

enum StandingsScope {
  wildCard,
  league,
  division,
}

class StandingsProvider extends ChangeNotifier {
  StandingsProvider({
    required CachedStandingsRepository standings,
  }) : _standings = standings;

  final CachedStandingsRepository _standings;

  StandingsScope _scope = StandingsScope.wildCard;
  StandingsScope get scope => _scope;

  AsyncState<NhlStandingsResponse> _state = const AsyncEmpty();
  AsyncState<NhlStandingsResponse> get state => _state;

  void setScope(StandingsScope scope) {
    if (_scope == scope) return;
    _scope = scope;
    notifyListeners();
  }

  Future<void> loadNow({bool forceRefresh = false}) async {
    _state = const AsyncLoading();
    notifyListeners();

    try {
      final data = await _standings.getStandingsNow(forceRefresh: forceRefresh);
      _state = AsyncData(data);
      notifyListeners();
    } on Object catch (e, st) {
      _state = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> refresh() => loadNow(forceRefresh: true);
}
