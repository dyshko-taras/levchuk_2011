import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_team_repository.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class TeamMeta {
  const TeamMeta({
    required this.teamAbbrev,
    required this.name,
    required this.logoUrl,
    required this.divisionName,
    required this.conferenceName,
    required this.arenaName,
    required this.standingRow,
  });

  final String teamAbbrev;
  final String name;
  final String logoUrl;
  final String divisionName;
  final String conferenceName;
  final String arenaName;
  final NhlStandingRow standingRow;
}

class TeamProvider extends ChangeNotifier {
  TeamProvider({
    required CachedTeamRepository repository,
    required CachedStandingsRepository standings,
  }) : _repository = repository,
       _standings = standings;

  final CachedTeamRepository _repository;
  final CachedStandingsRepository _standings;

  String? _teamAbbrev;
  String? get teamAbbrev => _teamAbbrev;

  AsyncState<TeamMeta> _metaState = const AsyncEmpty();
  AsyncState<TeamMeta> get metaState => _metaState;

  AsyncState<Object?> _rosterState = const AsyncEmpty();
  AsyncState<Object?> get rosterState => _rosterState;

  AsyncState<Object?> _scheduleState = const AsyncEmpty();
  AsyncState<Object?> get scheduleState => _scheduleState;

  AsyncState<Object?> _clubStatsState = const AsyncEmpty();
  AsyncState<Object?> get clubStatsState => _clubStatsState;

  Future<void> loadCurrent(String teamAbbrev) async {
    _teamAbbrev = teamAbbrev;
    notifyListeners();
    await Future.wait([
      loadMeta(teamAbbrev),
      loadRosterCurrent(teamAbbrev),
      loadScheduleSeasonNow(teamAbbrev),
      loadClubStatsNow(teamAbbrev),
    ]);
  }

  Future<void> loadMeta(String teamAbbrev) async {
    _metaState = const AsyncLoading();
    notifyListeners();

    try {
      final standings = await _standings.getStandingsNow();
      final row = standings.standings.firstWhere(
        (r) => r.teamAbbrev.defaultName == teamAbbrev,
      );

      _metaState = AsyncData(
        TeamMeta(
          teamAbbrev: teamAbbrev,
          name: row.teamCommonName.defaultName,
          logoUrl: row.teamLogo,
          divisionName: row.divisionName,
          conferenceName: row.conferenceName,
          arenaName: '—',
          standingRow: row,
        ),
      );
      notifyListeners();
    } on Object catch (e, st) {
      _metaState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
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

  Future<void> loadScheduleSeasonNow(String teamAbbrev) async {
    _scheduleState = const AsyncLoading();
    notifyListeners();

    try {
      final schedule = await _repository.getClubScheduleSeasonNow(teamAbbrev);
      _scheduleState = AsyncData(schedule);
      notifyListeners();
    } on Object catch (e, st) {
      _scheduleState = AsyncError(e, stackTrace: st);
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
