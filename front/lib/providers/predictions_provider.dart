import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/local/favorites_store.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_schedule_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_team_repository.dart';
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

enum PredictionConfidence {
  high,
  moderate,
  low,
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

class PredictionVm {
  const PredictionVm({
    required this.game,
    required this.dateLabel,
    required this.matchupRating,
    required this.projectedWinnerAbbrev,
    required this.projectedWinnerPct,
    required this.homeWinPct,
    required this.awayWinPct,
    required this.expectedTotalGoals,
    required this.confidence,
    required this.formLast5Label,
    required this.ppVsPkLabel,
  });

  final NhlScheduledGame game;
  final String dateLabel;
  final double matchupRating;
  final String projectedWinnerAbbrev;
  final int projectedWinnerPct;
  final int homeWinPct;
  final int awayWinPct;
  final double expectedTotalGoals;
  final PredictionConfidence confidence;
  final String formLast5Label;
  final String ppVsPkLabel;
}

class PredictionsProvider extends ChangeNotifier {
  PredictionsProvider({
    required CachedScheduleRepository schedule,
    required CachedStandingsRepository standings,
    required CachedTeamRepository teams,
    required FavoritesStore favoritesStore,
  }) : _schedule = schedule,
       _standings = standings,
       _teams = teams,
       _favoritesStore = favoritesStore;

  final CachedScheduleRepository _schedule;
  final CachedStandingsRepository _standings;
  final CachedTeamRepository _teams;
  final FavoritesStore _favoritesStore;

  PredictionsDateFilter _date = PredictionsDateFilter.today;
  PredictionsDateFilter get date => _date;

  PredictionsScopeFilter _scope = PredictionsScopeFilter.all;
  PredictionsScopeFilter get scope => _scope;

  String? _teamAbbrev;
  String? get teamAbbrev => _teamAbbrev;

  String? _customDateYyyyMmDd;
  String? get customDateYyyyMmDd => _customDateYyyyMmDd;

  AsyncState<PredictionsFilters> _filtersState = const AsyncEmpty();
  AsyncState<PredictionsFilters> get filtersState => _filtersState;

  AsyncState<List<PredictionVm>> _predictionsState = const AsyncEmpty();
  AsyncState<List<PredictionVm>> get predictionsState => _predictionsState;

  final Map<String, Future<_TeamInputs>> _teamInputsFutures = {};
  NhlStandingsResponse? _standingsCache;
  NhlStandingsResponse? get standingsCache => _standingsCache;

  Future<void> loadNow({bool forceRefresh = false}) async {
    final filters = PredictionsFilters(
      date: _date,
      scope: _scope,
      teamAbbrev: _teamAbbrev,
      customDateYyyyMmDd: _customDateYyyyMmDd,
    );
    _filtersState = AsyncData(filters);
    _predictionsState = const AsyncLoading();
    notifyListeners();

    try {
      final yyyyMmDd = _targetDate(filters);
      final standings = await _standings.getStandingsNow(
        forceRefresh: forceRefresh,
      );
      _standingsCache = standings;
      final schedule = await _schedule.getScheduleByDate(
        yyyyMmDd,
        forceRefresh: forceRefresh,
      );

      final games = _extractGamesForDate(schedule, yyyyMmDd: yyyyMmDd);
      final predictions = await _buildPredictions(
        games,
        standings: standings,
        filters: filters,
      );

      _predictionsState = AsyncData(predictions);
      notifyListeners();
    } on Object catch (e, st) {
      _predictionsState = AsyncError(e, stackTrace: st);
      notifyListeners();
    }
  }

  Future<void> refresh() => loadNow(forceRefresh: true);

  void setDateFilter(PredictionsDateFilter value) {
    if (_date == value) return;
    _date = value;
    unawaited(loadNow());
  }

  void setScopeFilter(PredictionsScopeFilter value) {
    if (_scope == value) return;
    _scope = value;
    unawaited(loadNow());
  }

  void setTeamAbbrev(String? value) {
    if (_teamAbbrev == value) return;
    _teamAbbrev = value;
    unawaited(loadNow());
  }

  void setCustomDateYyyyMmDd(String? value) {
    if (_customDateYyyyMmDd == value) return;
    _customDateYyyyMmDd = value;
    unawaited(loadNow());
  }

  String _targetDate(PredictionsFilters filters) {
    final now = DateTime.now();
    var date = now;
    if (filters.date == PredictionsDateFilter.tomorrow) {
      date = now.add(const Duration(days: 1));
    }
    if (filters.date == PredictionsDateFilter.custom) {
      final custom = filters.customDateYyyyMmDd;
      final parsed = custom == null ? null : DateTime.tryParse(custom);
      if (parsed != null) date = parsed;
    }
    return _toYyyyMmDd(date);
  }

  List<NhlScheduledGame> _extractGamesForDate(
    NhlScheduleResponse schedule, {
    required String yyyyMmDd,
  }) {
    final day = schedule.gameWeek.firstWhere(
      (d) => d.date == yyyyMmDd,
      orElse: () => schedule.gameWeek.isEmpty
          ? const NhlGameDay(date: '', numberOfGames: 0, games: [])
          : schedule.gameWeek.first,
    );
    return day.games;
  }

  Future<List<PredictionVm>> _buildPredictions(
    List<NhlScheduledGame> games, {
    required NhlStandingsResponse standings,
    required PredictionsFilters filters,
  }) async {
    final standingsByAbbrev = <String, NhlStandingRow>{};
    for (final row in standings.standings) {
      standingsByAbbrev[row.teamAbbrev.defaultName] = row;
    }

    final uniqueTeams = <String>{
      for (final g in games) g.homeTeam.abbrev,
      for (final g in games) g.awayTeam.abbrev,
    };
    await Future.wait(uniqueTeams.map(_teamInputs));

    final favoriteTeams = _favoritesStore.getFavoriteTeamAbbrevs();
    final favoriteGames = _favoritesStore.getFavoriteGameIds();

    final list = <PredictionVm>[];
    final seenGameIds = <int>{};
    for (final g in games) {
      if (!seenGameIds.add(g.id)) continue;
      if (filters.teamAbbrev != null &&
          g.homeTeam.abbrev != filters.teamAbbrev &&
          g.awayTeam.abbrev != filters.teamAbbrev) {
        continue;
      }

      if (filters.scope == PredictionsScopeFilter.myFavorites) {
        final isFav =
            favoriteGames.contains(g.id) ||
            favoriteTeams.contains(g.homeTeam.abbrev) ||
            favoriteTeams.contains(g.awayTeam.abbrev);
        if (!isFav) continue;
      }

      final homeRow = standingsByAbbrev[g.homeTeam.abbrev];
      final awayRow = standingsByAbbrev[g.awayTeam.abbrev];

      final homeInputs = await _teamInputs(g.homeTeam.abbrev);
      final awayInputs = await _teamInputs(g.awayTeam.abbrev);

      final predicted = _predictForGame(
        game: g,
        homeStanding: homeRow,
        awayStanding: awayRow,
        home: homeInputs,
        away: awayInputs,
      );

      list.add(predicted);
    }

    if (filters.scope == PredictionsScopeFilter.keyMatchups) {
      final byRating = [...list]
        ..sort((a, b) => b.matchupRating.compareTo(a.matchupRating));

      final takeCount = min(10, max(1, (byRating.length * 0.3).ceil()));
      final ids = byRating.take(takeCount).map((p) => p.game.id).toSet();
      list.removeWhere((p) => !ids.contains(p.game.id));
    }

    list.sort((a, b) => a.game.startTimeUTC.compareTo(b.game.startTimeUTC));
    return list;
  }

  Future<_TeamInputs> _teamInputs(String abbrev) {
    final existing = _teamInputsFutures[abbrev];
    if (existing != null) return existing;

    final future = () async {
      final clubStats = await _teams.getClubStatsNow(abbrev);
      final schedule = await _teams.getClubScheduleSeasonNow(abbrev);
      return _TeamInputs(
        abbrev: abbrev,
        last5: _last5Record(schedule, teamAbbrev: abbrev),
        ppPct: _findPct(clubStats, const ['ppPct', 'powerPlayPct', 'ppPctg']),
        pkPct: _findPct(clubStats, const ['pkPct', 'penaltyKillPct', 'pkPctg']),
      );
    }();

    _teamInputsFutures[abbrev] = future;
    return future;
  }

  PredictionVm _predictForGame({
    required NhlScheduledGame game,
    required NhlStandingRow? homeStanding,
    required NhlStandingRow? awayStanding,
    required _TeamInputs home,
    required _TeamInputs away,
  }) {
    final homeBase = _baseRating(homeStanding);
    final awayBase = _baseRating(awayStanding);

    final homeForm = _formRating(homeStanding, home.last5);
    final awayForm = _formRating(awayStanding, away.last5);

    final homeGoalDiff = _goalDiffRating(homeStanding);
    final awayGoalDiff = _goalDiffRating(awayStanding);

    final homeSpecial = _specialTeamsRating(home.ppPct, home.pkPct);
    final awaySpecial = _specialTeamsRating(away.ppPct, away.pkPct);

    const homeAdvantage = 0.07;

    final matchupRating =
        homeBase +
        homeForm +
        homeGoalDiff +
        homeSpecial +
        awayBase +
        awayForm +
        awayGoalDiff +
        awaySpecial;

    final homeScore =
        homeBase + homeForm + homeGoalDiff + homeSpecial + homeAdvantage;
    final awayScore = awayBase + awayForm + awayGoalDiff + awaySpecial;

    final (homeWin, awayWin) = _softmax(homeScore, awayScore);
    final homePct = (homeWin * 100).round().clamp(0, 100);
    final awayPct = 100 - homePct;

    final winnerAbbrev = homePct >= awayPct
        ? game.homeTeam.abbrev
        : game.awayTeam.abbrev;
    final winnerPct = max(homePct, awayPct);

    final confidence = _confidenceForDiff((homeScore - awayScore).abs());

    final expected = _expectedTotalGoals(homeStanding, awayStanding);

    final dateLabel = _dateLabelFromStart(game.startTimeUTC);

    final homeFormLabel = _recordLabel(home.last5);
    final awayFormLabel = _recordLabel(away.last5);

    final ppVsPk = _ppVsPkLabel(away.ppPct, home.pkPct);

    return PredictionVm(
      game: game,
      dateLabel: dateLabel ?? AppStrings.notAvailable,
      matchupRating: matchupRating,
      projectedWinnerAbbrev: winnerAbbrev,
      projectedWinnerPct: winnerPct,
      homeWinPct: homePct,
      awayWinPct: awayPct,
      expectedTotalGoals: expected,
      confidence: confidence,
      formLast5Label: '$awayFormLabel vs $homeFormLabel (last 5)',
      ppVsPkLabel: ppVsPk,
    );
  }
}

class _Record {
  const _Record({required this.w, required this.l, required this.otl});

  final int w;
  final int l;
  final int otl;
}

class _TeamInputs {
  const _TeamInputs({
    required this.abbrev,
    required this.last5,
    required this.ppPct,
    required this.pkPct,
  });

  final String abbrev;
  final _Record last5;
  final String? ppPct;
  final String? pkPct;
}

_Record _last5Record(Object? scheduleRaw, {required String teamAbbrev}) {
  if (scheduleRaw is! Map) return const _Record(w: 0, l: 0, otl: 0);
  final games = scheduleRaw['games'];
  if (games is! List) return const _Record(w: 0, l: 0, otl: 0);

  final finals = <Map<String, Object?>>[];
  for (final g in games) {
    if (g is! Map) continue;
    final m = g.cast<String, Object?>();
    final home = m['homeTeam'];
    final away = m['awayTeam'];
    if (home is! Map || away is! Map) continue;
    final homeScore = home['score'];
    final awayScore = away['score'];
    if (homeScore is! num || awayScore is! num) continue;
    finals.add(m);
  }

  finals.sort((a, b) {
    final at = a['startTimeUTC'];
    final bt = b['startTimeUTC'];
    if (at is String && bt is String) return bt.compareTo(at);
    return 0;
  });

  var w = 0;
  var l = 0;
  var otl = 0;

  for (final g in finals.take(5)) {
    final home = g['homeTeam'];
    final away = g['awayTeam'];
    if (home is! Map || away is! Map) continue;
    final homeAbbrev = home['abbrev'];
    final awayAbbrev = away['abbrev'];
    if (homeAbbrev is! String || awayAbbrev is! String) continue;
    final isHome = homeAbbrev == teamAbbrev;

    final homeScore = home['score'];
    final awayScore = away['score'];
    if (homeScore is! num || awayScore is! num) continue;
    final gf = isHome ? homeScore : awayScore;
    final ga = isHome ? awayScore : homeScore;

    if (gf > ga) {
      w++;
    } else {
      final lastPeriodType = _lastPeriodType(g.cast<String, Object?>());
      if (lastPeriodType != null && lastPeriodType != 'REG') {
        otl++;
      } else {
        l++;
      }
    }
  }

  return _Record(w: w, l: l, otl: otl);
}

double _baseRating(NhlStandingRow? row) {
  if (row == null || row.gamesPlayed == 0) return 0;
  final pointsPct = row.points / (row.gamesPlayed * 2);
  return (pointsPct - 0.5) * 1.2;
}

double _formRating(NhlStandingRow? row, _Record last5) {
  if (row == null) {
    final pct = (last5.w / 5) - 0.5;
    return pct * 0.8;
  }
  final l10Pct = (row.l10Wins / 10) - 0.5;
  final last5Pct = (last5.w / 5) - 0.5;
  return ((l10Pct * 0.6) + (last5Pct * 0.4)) * 0.8;
}

double _goalDiffRating(NhlStandingRow? row) {
  if (row == null || row.gamesPlayed == 0) return 0;
  final perGame = row.goalDifferential / row.gamesPlayed;
  return (perGame / 2).clamp(-0.6, 0.6);
}

double _specialTeamsRating(String? ppPct, String? pkPct) {
  final pp = _parsePct(ppPct);
  final pk = _parsePct(pkPct);
  if (pp == null || pk == null) return 0;
  const leagueAvg = 100;
  final delta = (pp + pk) - leagueAvg;
  return (delta / 100) * 0.35;
}

(double, double) _softmax(double home, double away) {
  const scale = 2.2;
  final eh = exp(home * scale);
  final ea = exp(away * scale);
  final sum = eh + ea;
  if (sum == 0) return (0.5, 0.5);
  return (eh / sum, ea / sum);
}

PredictionConfidence _confidenceForDiff(double diff) {
  if (diff >= 0.22) return PredictionConfidence.high;
  if (diff >= 0.12) return PredictionConfidence.moderate;
  return PredictionConfidence.low;
}

double _expectedTotalGoals(NhlStandingRow? home, NhlStandingRow? away) {
  if (home == null ||
      away == null ||
      home.gamesPlayed == 0 ||
      away.gamesPlayed == 0) {
    return 6;
  }
  final homeGf = home.goalFor / home.gamesPlayed;
  final homeGa = home.goalAgainst / home.gamesPlayed;
  final awayGf = away.goalFor / away.gamesPlayed;
  final awayGa = away.goalAgainst / away.gamesPlayed;

  final raw = (homeGf + homeGa + awayGf + awayGa) / 2;
  return raw.clamp(3, 9);
}

String? _dateLabelFromStart(String utcIso) {
  final dt = DateTime.tryParse(utcIso)?.toLocal();
  if (dt == null) return null;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final idx = dt.month - 1;
  if (idx < 0 || idx >= months.length) return null;
  return '${months[idx]} ${dt.day}';
}

String _recordLabel(_Record r) => '${r.w}–${r.l}';

String _ppVsPkLabel(String? awayPp, String? homePk) {
  final pp = _normalizePctLabel(awayPp);
  final pk = _normalizePctLabel(homePk);
  if (pp == null || pk == null) return '${AppStrings.ppVsPk} —';
  return '${AppStrings.ppVsPk} $pp PP vs $pk PK';
}

String _toYyyyMmDd(DateTime date) {
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}

String? _normalizePctLabel(String? raw) {
  if (raw == null) return null;
  final n = _parsePct(raw);
  if (n == null) return null;
  return '${n.round()}%';
}

double? _parsePct(String? raw) {
  if (raw == null) return null;
  final s = raw.trim();
  if (s.isEmpty) return null;
  final cleaned = s.replaceAll('%', '');
  final v = double.tryParse(cleaned);
  return v;
}

String? _findPct(Object? raw, List<String> keys) {
  if (raw is! Map) return null;
  final v = _findValueByKeys(
    Map<Object?, Object?>.from(raw),
    keys,
    maxDepth: 4,
  );
  if (v == null) return null;
  if (v is String) return v;
  if (v is num) return v.toString();
  return null;
}

Object? _findValueByKeys(
  Map<Object?, Object?> raw,
  List<String> keys, {
  required int maxDepth,
}) {
  if (maxDepth < 0) return null;
  for (final k in keys) {
    if (raw.containsKey(k)) return raw[k];
  }
  for (final v in raw.values) {
    if (v is Map) {
      final found = _findValueByKeys(
        Map<Object?, Object?>.from(v),
        keys,
        maxDepth: maxDepth - 1,
      );
      if (found != null) return found;
    }
  }
  return null;
}

String? _lastPeriodType(Map<String, Object?> game) {
  final outcome = game['gameOutcome'];
  if (outcome is Map) {
    final lastPeriod = outcome['lastPeriodType'];
    if (lastPeriod is String && lastPeriod.isNotEmpty) return lastPeriod;
  }
  return null;
}
