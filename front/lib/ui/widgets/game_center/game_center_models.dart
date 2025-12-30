import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';

enum GameCenterTab { plays, goals, penalties, stats, recap }

enum PlaysFilter { goals, shots, hits, penalties, faceoffs }

enum GoalsSubtab { goals, shots, hits }

enum StatsSegment { home, game, away }

class GameCenterHeader {
  const GameCenterHeader({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeAbbrev,
    required this.awayAbbrev,
    required this.homeLogoUrl,
    required this.awayLogoUrl,
    required this.homeScore,
    required this.awayScore,
    required this.homeSog,
    required this.awaySog,
    required this.periodAndClock,
    required this.sogLabel,
    required this.gameStateLabel,
    required this.hintLabel,
  });

  final int homeTeamId;
  final int awayTeamId;
  final String homeAbbrev;
  final String awayAbbrev;
  final String homeLogoUrl;
  final String awayLogoUrl;
  final int homeScore;
  final int awayScore;
  final int homeSog;
  final int awaySog;
  final String periodAndClock;
  final String sogLabel;
  final String gameStateLabel;
  final String? hintLabel;

  String abbrevForTeamId(int? teamId) {
    if (teamId == null) return AppStrings.notAvailable;
    if (teamId == homeTeamId) return homeAbbrev;
    if (teamId == awayTeamId) return awayAbbrev;
    return AppStrings.notAvailable;
  }
}

class RosterPlayer {
  const RosterPlayer({
    required this.playerId,
    required this.teamId,
    required this.name,
  });

  final int playerId;
  final int teamId;
  final String name;
}

class GameCenterTeamStats {
  const GameCenterTeamStats({
    required this.sog,
    required this.foPct,
    required this.ppPct,
    required this.pkPct,
    required this.hits,
    required this.blocks,
    required this.giveaways,
    required this.takeaways,
  });

  final String sog;
  final String foPct;
  final String ppPct;
  final String pkPct;
  final String hits;
  final String blocks;
  final String giveaways;
  final String takeaways;
}

class GameCenterSkaterRow {
  const GameCenterSkaterRow({
    required this.name,
    required this.toi,
    required this.goals,
    required this.assists,
    required this.plusMinus,
  });

  final String name;
  final String toi;
  final String goals;
  final String assists;
  final String plusMinus;
}

class GameCenterGoalieRow {
  const GameCenterGoalieRow({
    required this.name,
    required this.toi,
    required this.svPct,
    required this.sa,
    required this.ga,
  });

  final String name;
  final String toi;
  final String svPct;
  final String sa;
  final String ga;
}

class GameCenterStatsData {
  const GameCenterStatsData({
    required this.homeTeamStats,
    required this.awayTeamStats,
    required this.homeSkaters,
    required this.awaySkaters,
    required this.homeGoalies,
    required this.awayGoalies,
    required this.homeAbbrev,
    required this.awayAbbrev,
  });

  final GameCenterTeamStats homeTeamStats;
  final GameCenterTeamStats awayTeamStats;
  final List<GameCenterSkaterRow> homeSkaters;
  final List<GameCenterSkaterRow> awaySkaters;
  final List<GameCenterGoalieRow> homeGoalies;
  final List<GameCenterGoalieRow> awayGoalies;
  final String homeAbbrev;
  final String awayAbbrev;

  GameCenterTeamStats teamStatsFor(StatsSegment segment) => switch (segment) {
    StatsSegment.home => homeTeamStats,
    StatsSegment.away => awayTeamStats,
    StatsSegment.game => GameCenterTeamStats(
      sog: '${homeTeamStats.sog}\u00A0–\u00A0${awayTeamStats.sog}',
      foPct: '${homeTeamStats.foPct}\u00A0–\u00A0${awayTeamStats.foPct}',
      ppPct: '${homeTeamStats.ppPct}\u00A0–\u00A0${awayTeamStats.ppPct}',
      pkPct: '${homeTeamStats.pkPct}\u00A0–\u00A0${awayTeamStats.pkPct}',
      hits: '${homeTeamStats.hits}\u00A0–\u00A0${awayTeamStats.hits}',
      blocks: '${homeTeamStats.blocks}\u00A0–\u00A0${awayTeamStats.blocks}',
      giveaways:
          '${homeTeamStats.giveaways}\u00A0–\u00A0${awayTeamStats.giveaways}',
      takeaways:
          '${homeTeamStats.takeaways}\u00A0–\u00A0${awayTeamStats.takeaways}',
    ),
  };

  List<GameCenterSkaterRow> skatersFor(StatsSegment segment) =>
      switch (segment) {
        StatsSegment.home => homeSkaters,
        StatsSegment.away => awaySkaters,
        StatsSegment.game => [
          ...homeSkaters.map(
            (r) => GameCenterSkaterRow(
              name: '$homeAbbrev ${r.name}',
              toi: r.toi,
              goals: r.goals,
              assists: r.assists,
              plusMinus: r.plusMinus,
            ),
          ),
          ...awaySkaters.map(
            (r) => GameCenterSkaterRow(
              name: '$awayAbbrev ${r.name}',
              toi: r.toi,
              goals: r.goals,
              assists: r.assists,
              plusMinus: r.plusMinus,
            ),
          ),
        ],
      };

  List<GameCenterGoalieRow> goaliesFor(StatsSegment segment) =>
      switch (segment) {
        StatsSegment.home => homeGoalies,
        StatsSegment.away => awayGoalies,
        StatsSegment.game => [
          ...homeGoalies.map(
            (r) => GameCenterGoalieRow(
              name: '$homeAbbrev ${r.name}',
              toi: r.toi,
              svPct: r.svPct,
              sa: r.sa,
              ga: r.ga,
            ),
          ),
          ...awayGoalies.map(
            (r) => GameCenterGoalieRow(
              name: '$awayAbbrev ${r.name}',
              toi: r.toi,
              svPct: r.svPct,
              sa: r.sa,
              ga: r.ga,
            ),
          ),
        ],
      };
}

class GameCenterRecapSummary {
  const GameCenterRecapSummary({
    required this.specialTeams,
    required this.highlights,
    required this.firstGoal,
    required this.gameWinningGoal,
    required this.broadcasters,
  });

  final String specialTeams;
  final String highlights;
  final String firstGoal;
  final String gameWinningGoal;
  final String broadcasters;
}

Map<String, Object?>? asMap(Object? v) =>
    v is Map ? v.cast<String, Object?>() : null;

List<Object?> asList(Object? v) => v is List ? v.cast<Object?>() : const [];

int? asInt(Object? v) => v is int ? v : int.tryParse('$v');

String? asString(Object? v) => v is String ? v : v?.toString();

BoxDecoration cardDecoration() => BoxDecoration(
  color: AppColors.surfaceGray,
  borderRadius: AppRadius.md,
  border: Border.all(color: const Color(0x33000000), width: 0.66),
  boxShadow: const [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 1.32),
      blurRadius: 1.32,
    ),
  ],
);
