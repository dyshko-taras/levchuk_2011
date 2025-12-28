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
