import 'package:ice_line_tracker/data/models/nhl_localized_name.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nhl_standings_response.g.dart';

@JsonSerializable()
class NhlStandingsResponse {
  const NhlStandingsResponse({
    required this.wildCardIndicator,
    required this.standingsDateTimeUtc,
    required this.standings,
  });

  factory NhlStandingsResponse.fromJson(Map<String, Object?> json) =>
      _$NhlStandingsResponseFromJson(json);

  final bool wildCardIndicator;
  final String standingsDateTimeUtc;
  final List<NhlStandingRow> standings;

  Map<String, Object?> toJson() => _$NhlStandingsResponseToJson(this);
}

@JsonSerializable()
class NhlStandingRow {
  const NhlStandingRow({
    required this.date,
    required this.seasonId,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.otLosses,
    required this.points,
    required this.streakCode,
    required this.streakCount,
    required this.teamLogo,
    required this.teamName,
    required this.teamCommonName,
    required this.teamAbbrev,
  });

  factory NhlStandingRow.fromJson(Map<String, Object?> json) =>
      _$NhlStandingRowFromJson(json);

  final String date;
  final int seasonId;

  final int gamesPlayed;
  final int wins;
  final int losses;
  final int otLosses;
  final int points;

  final String streakCode;
  final int streakCount;

  final String teamLogo;

  final NhlLocalizedName teamName;
  final NhlLocalizedName teamCommonName;
  final NhlLocalizedName teamAbbrev;

  Map<String, Object?> toJson() => _$NhlStandingRowToJson(this);
}
