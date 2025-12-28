import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_models.dart';

GameCenterHeader? parseHeaderFromPlayByPlay(Map<String, Object?>? pbp) {
  if (pbp == null) return null;
  final home = asMap(pbp['homeTeam']);
  final away = asMap(pbp['awayTeam']);
  if (home == null || away == null) return null;

  final homeTeamId = asInt(home['id']);
  final awayTeamId = asInt(away['id']);
  if (homeTeamId == null || awayTeamId == null) return null;

  final homeAbbrev = asString(home['abbrev']) ?? AppStrings.notAvailable;
  final awayAbbrev = asString(away['abbrev']) ?? AppStrings.notAvailable;
  final homeLogo = asString(home['logo']) ?? '';
  final awayLogo = asString(away['logo']) ?? '';

  final homeScore = asInt(home['score']) ?? 0;
  final awayScore = asInt(away['score']) ?? 0;
  final homeSog = asInt(home['sog']) ?? 0;
  final awaySog = asInt(away['sog']) ?? 0;

  final clock = asMap(pbp['clock']);
  final timeRemaining =
      asString(clock?['timeRemaining']) ?? AppStrings.notAvailable;
  final inIntermission = clock?['inIntermission'] == true;

  final periodDescriptor = asMap(pbp['periodDescriptor']);
  final periodNumber = asInt(periodDescriptor?['number']);
  final periodType = asString(periodDescriptor?['periodType']);
  final periodLabel =
      periodLabelFrom(periodNumber, periodType) ?? AppStrings.notAvailable;

  final periodAndClock = '$periodLabel • $timeRemaining';
  final sogLabel = '${AppStrings.sog} $homeSog – $awaySog';

  final gameState = (asString(pbp['gameState']) ?? '').toUpperCase();
  final gameStateLabel = switch (gameState) {
    'FINAL' || 'OFF' => AppStrings.final_,
    'FUT' || 'PRE' => AppStrings.gameStatusScheduled,
    _ => AppStrings.gameStatusLive,
  };

  final hintLabel = inIntermission ? AppStrings.intermission : null;

  return GameCenterHeader(
    homeTeamId: homeTeamId,
    awayTeamId: awayTeamId,
    homeAbbrev: homeAbbrev,
    awayAbbrev: awayAbbrev,
    homeLogoUrl: homeLogo,
    awayLogoUrl: awayLogo,
    homeScore: homeScore,
    awayScore: awayScore,
    homeSog: homeSog,
    awaySog: awaySog,
    periodAndClock: periodAndClock,
    sogLabel: sogLabel,
    gameStateLabel: gameStateLabel,
    hintLabel: hintLabel,
  );
}

List<Map<String, Object?>> playsFromPlayByPlay(Map<String, Object?>? pbp) {
  final plays = asList(pbp?['plays']);
  return plays.map(asMap).whereType<Map<String, Object?>>().toList();
}

Map<int, RosterPlayer> rosterFromPlayByPlay(Map<String, Object?>? pbp) {
  final spots = asList(pbp?['rosterSpots']);
  final map = <int, RosterPlayer>{};
  for (final s in spots) {
    final m = asMap(s);
    if (m == null) continue;
    final playerId = asInt(m['playerId']);
    final teamId = asInt(m['teamId']);
    final first = asString(asMap(m['firstName'])?['default']);
    final last = asString(asMap(m['lastName'])?['default']);
    if (playerId == null || teamId == null) continue;
    final name = [
      first,
      last,
    ].whereType<String>().where((e) => e.isNotEmpty).join(' ');
    map[playerId] = RosterPlayer(
      playerId: playerId,
      teamId: teamId,
      name: name.isEmpty ? AppStrings.notAvailable : name,
    );
  }
  return map;
}

String typeKey(Map<String, Object?> play) =>
    (asString(play['typeDescKey']) ?? '').toLowerCase();

bool isShot(Map<String, Object?> play) {
  final t = typeKey(play);
  return t == 'shot-on-goal' ||
      t == 'missed-shot' ||
      t == 'blocked-shot' ||
      t == 'shot';
}

bool matchesPlaysFilter(Map<String, Object?> play, PlaysFilter filter) {
  return switch (filter) {
    PlaysFilter.goals => typeKey(play) == 'goal',
    PlaysFilter.shots => isShot(play),
    PlaysFilter.hits => typeKey(play) == 'hit',
    PlaysFilter.penalties => typeKey(play) == 'penalty',
    PlaysFilter.faceoffs => typeKey(play) == 'faceoff',
  };
}

String playTimeLabel(Map<String, Object?> play) {
  final pd = asMap(play['periodDescriptor']);
  final number = asInt(pd?['number']);
  final type = asString(pd?['periodType']);
  final period = periodLabelFrom(number, type) ?? AppStrings.notAvailable;
  final time = asString(play['timeInPeriod']) ?? AppStrings.notAvailable;
  return '$period • $time';
}

String? playScoreLabel(GameCenterHeader? header, Map<String, Object?> play) {
  final details = asMap(play['details']);
  final away = asInt(details?['awayScore']);
  final home = asInt(details?['homeScore']);
  if (away == null || home == null) return null;

  final leader = switch (away.compareTo(home)) {
    > 0 => header?.awayAbbrev,
    < 0 => header?.homeAbbrev,
    _ => null,
  };
  final base = '$away–$home';
  return leader == null ? base : '$base $leader';
}

String playTitle(Map<String, Object?> play) {
  final type = typeKey(play);
  if (type.isEmpty) return AppStrings.notAvailable;
  return titleCase(type.replaceAll('-', ' '));
}

String? playSubtitle(Map<String, Object?> play, Map<int, RosterPlayer> roster) {
  final type = typeKey(play);
  final details = asMap(play['details']);
  if (details == null) return null;

  if (type == 'goal') {
    final scorerId = asInt(details['scoringPlayerId']);
    final scorer = scorerId == null ? null : roster[scorerId]?.name;
    return scorer;
  }
  if (type == 'penalty') {
    final descKey = asString(details['descKey']);
    return descKey == null ? null : titleCase(descKey);
  }
  return null;
}

String goalStrength(Map<String, Object?>? details) {
  final descKey = (asString(details?['descKey']) ?? '').toLowerCase();
  if (descKey.contains('pp')) return 'PP';
  if (descKey.contains('sh')) return 'SH';
  return 'EV';
}

String? periodLabelFrom(int? number, String? type) {
  final upperType = type?.toUpperCase();
  if (upperType == 'OT') return 'OT';
  if (upperType == 'SO') return 'SO';

  return switch (number) {
    1 => '1st',
    2 => '2nd',
    3 => '3rd',
    null => null,
    _ => '${number}th',
  };
}

String titleCase(String raw) {
  final words = raw.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words
      .map((w) => w.substring(0, 1).toUpperCase() + w.substring(1))
      .join(' ');
}

({
  Map<int, int> goalsByPlayer,
  Map<int, int> assistsByPlayer,
})
derivedGoalAssistCounts(List<Map<String, Object?>> plays) {
  final goals = <int, int>{};
  final assists = <int, int>{};

  for (final p in plays) {
    if (typeKey(p) != 'goal') continue;
    final details = asMap(p['details']);
    if (details == null) continue;
    final scorerId = asInt(details['scoringPlayerId']);
    if (scorerId != null) {
      goals[scorerId] = (goals[scorerId] ?? 0) + 1;
    }
    final a1 = asInt(details['assist1PlayerId']);
    if (a1 != null) {
      assists[a1] = (assists[a1] ?? 0) + 1;
    }
    final a2 = asInt(details['assist2PlayerId']);
    if (a2 != null) {
      assists[a2] = (assists[a2] ?? 0) + 1;
    }
  }

  return (goalsByPlayer: goals, assistsByPlayer: assists);
}

Map<String, ({int away, int home})> scoreByPeriodFromGoals(
  GameCenterHeader? header,
  List<Map<String, Object?>> goals,
) {
  final map = <String, ({int away, int home})>{
    '1': (away: 0, home: 0),
    '2': (away: 0, home: 0),
    '3': (away: 0, home: 0),
    'OT': (away: 0, home: 0),
    'SO': (away: 0, home: 0),
  };
  if (header == null) return map;

  for (final g in goals) {
    final pd = asMap(g['periodDescriptor']);
    final number = asInt(pd?['number']);
    final type = asString(pd?['periodType']);
    final key = switch ((type ?? '').toUpperCase()) {
      'OT' => 'OT',
      'SO' => 'SO',
      _ => number == null ? null : '$number',
    };
    if (key == null || !map.containsKey(key)) continue;

    final details = asMap(g['details']);
    final teamId = asInt(details?['eventOwnerTeamId']);
    if (teamId == null) continue;

    final current = map[key]!;
    if (teamId == header.awayTeamId) {
      map[key] = (away: current.away + 1, home: current.home);
    } else if (teamId == header.homeTeamId) {
      map[key] = (away: current.away, home: current.home + 1);
    }
  }

  return map;
}
