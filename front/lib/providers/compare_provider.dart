import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

enum CompareRange {
  last5,
  last10,
  season,
}

class CompareSelection {
  const CompareSelection({
    required this.teamA,
    required this.teamB,
    required this.range,
  });

  final String? teamA;
  final String? teamB;
  final CompareRange range;
}

class CompareProvider extends ChangeNotifier {
  String? _teamA;
  String? get teamA => _teamA;

  String? _teamB;
  String? get teamB => _teamB;

  CompareRange _range = CompareRange.last10;
  CompareRange get range => _range;

  AsyncState<CompareSelection> _state = const AsyncEmpty();
  AsyncState<CompareSelection> get state => _state;

  void setTeamA(String? teamAbbrev) {
    if (_teamA == teamAbbrev) return;
    _teamA = teamAbbrev;
    _emitSelection();
  }

  void setTeamB(String? teamAbbrev) {
    if (_teamB == teamAbbrev) return;
    _teamB = teamAbbrev;
    _emitSelection();
  }

  void setRange(CompareRange range) {
    if (_range == range) return;
    _range = range;
    _emitSelection();
  }

  void _emitSelection() {
    _state = AsyncData(
      CompareSelection(
        teamA: _teamA,
        teamB: _teamB,
        range: _range,
      ),
    );
    notifyListeners();
  }
}
