import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

enum PredictionsDateFilter {
  today,
  tomorrow,
  custom,
}

enum PredictionsScopeFilter {
  all,
  myFavorites,
  keyMatchups,
}

class PredictionsFilters {
  const PredictionsFilters({
    required this.date,
    required this.scope,
    this.teamAbbrev,
    this.customDateYyyyMmDd,
  });

  final PredictionsDateFilter date;
  final PredictionsScopeFilter scope;
  final String? teamAbbrev;
  final String? customDateYyyyMmDd;
}

class PredictionsProvider extends ChangeNotifier {
  PredictionsDateFilter _date = PredictionsDateFilter.today;
  PredictionsDateFilter get date => _date;

  PredictionsScopeFilter _scope = PredictionsScopeFilter.all;
  PredictionsScopeFilter get scope => _scope;

  String? _teamAbbrev;
  String? get teamAbbrev => _teamAbbrev;

  String? _customDateYyyyMmDd;
  String? get customDateYyyyMmDd => _customDateYyyyMmDd;

  AsyncState<PredictionsFilters> _state = const AsyncEmpty();
  AsyncState<PredictionsFilters> get state => _state;

  void setDateFilter(PredictionsDateFilter value) {
    if (_date == value) return;
    _date = value;
    _emitFilters();
  }

  void setScopeFilter(PredictionsScopeFilter value) {
    if (_scope == value) return;
    _scope = value;
    _emitFilters();
  }

  void setTeamAbbrev(String? value) {
    if (_teamAbbrev == value) return;
    _teamAbbrev = value;
    _emitFilters();
  }

  void setCustomDateYyyyMmDd(String? value) {
    if (_customDateYyyyMmDd == value) return;
    _customDateYyyyMmDd = value;
    _emitFilters();
  }

  void _emitFilters() {
    _state = AsyncData(
      PredictionsFilters(
        date: _date,
        scope: _scope,
        teamAbbrev: _teamAbbrev,
        customDateYyyyMmDd: _customDateYyyyMmDd,
      ),
    );
    notifyListeners();
  }
}
