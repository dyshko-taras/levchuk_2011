import 'package:ice_line_tracker/data/models/nhl_localized_name.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nhl_schedule_response.g.dart';

@JsonSerializable()
class NhlScheduleResponse {
  const NhlScheduleResponse({
    required this.nextStartDate,
    required this.previousStartDate,
    required this.gameWeek,
  });

  factory NhlScheduleResponse.fromJson(Map<String, Object?> json) =>
      _$NhlScheduleResponseFromJson(json);

  final String nextStartDate;
  final String previousStartDate;
  final List<NhlGameDay> gameWeek;

  Map<String, Object?> toJson() => _$NhlScheduleResponseToJson(this);
}

@JsonSerializable()
class NhlGameDay {
  const NhlGameDay({
    required this.date,
    required this.numberOfGames,
    required this.games,
  });

  factory NhlGameDay.fromJson(Map<String, Object?> json) =>
      _$NhlGameDayFromJson(json);

  final String date;
  final int numberOfGames;
  final List<NhlScheduledGame> games;

  Map<String, Object?> toJson() => _$NhlGameDayToJson(this);
}

@JsonSerializable()
class NhlScheduledGame {
  const NhlScheduledGame({
    required this.id,
    required this.season,
    required this.gameType,
    required this.startTimeUTC,
    required this.gameState,
    required this.gameScheduleState,
    required this.awayTeam,
    required this.homeTeam,
  });

  factory NhlScheduledGame.fromJson(Map<String, Object?> json) =>
      _$NhlScheduledGameFromJson(json);

  final int id;
  final int season;
  final int gameType;
  final String startTimeUTC;
  final String gameState;
  final String gameScheduleState;

  final NhlScheduleTeam awayTeam;
  final NhlScheduleTeam homeTeam;

  Map<String, Object?> toJson() => _$NhlScheduledGameToJson(this);
}

@JsonSerializable()
class NhlScheduleTeam {
  const NhlScheduleTeam({
    required this.id,
    required this.abbrev,
    required this.commonName,
    required this.placeName,
    required this.logo,
    this.score,
  });

  factory NhlScheduleTeam.fromJson(Map<String, Object?> json) =>
      _$NhlScheduleTeamFromJson(json);

  final int id;
  final String abbrev;
  final NhlLocalizedName commonName;
  final NhlLocalizedName placeName;
  final String logo;
  final int? score;

  Map<String, Object?> toJson() => _$NhlScheduleTeamToJson(this);
}
