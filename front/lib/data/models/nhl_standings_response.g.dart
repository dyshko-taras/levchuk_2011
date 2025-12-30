// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhl_standings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NhlStandingsResponse _$NhlStandingsResponseFromJson(
  Map<String, dynamic> json,
) => NhlStandingsResponse(
  wildCardIndicator: json['wildCardIndicator'] as bool,
  standingsDateTimeUtc: json['standingsDateTimeUtc'] as String,
  standings: (json['standings'] as List<dynamic>)
      .map((e) => NhlStandingRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NhlStandingsResponseToJson(
  NhlStandingsResponse instance,
) => <String, dynamic>{
  'wildCardIndicator': instance.wildCardIndicator,
  'standingsDateTimeUtc': instance.standingsDateTimeUtc,
  'standings': instance.standings,
};

NhlStandingRow _$NhlStandingRowFromJson(Map<String, dynamic> json) =>
    NhlStandingRow(
      date: json['date'] as String,
      seasonId: (json['seasonId'] as num).toInt(),
      conferenceName: json['conferenceName'] as String,
      divisionName: json['divisionName'] as String,
      wildcardSequence: (json['wildcardSequence'] as num).toInt(),
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      wins: (json['wins'] as num).toInt(),
      losses: (json['losses'] as num).toInt(),
      otLosses: (json['otLosses'] as num).toInt(),
      points: (json['points'] as num).toInt(),
      goalFor: (json['goalFor'] as num).toInt(),
      goalAgainst: (json['goalAgainst'] as num).toInt(),
      goalDifferential: (json['goalDifferential'] as num).toInt(),
      l10Wins: (json['l10Wins'] as num).toInt(),
      l10Losses: (json['l10Losses'] as num).toInt(),
      l10OtLosses: (json['l10OtLosses'] as num).toInt(),
      regulationPlusOtWins: (json['regulationPlusOtWins'] as num).toInt(),
      streakCode: json['streakCode'] as String,
      streakCount: (json['streakCount'] as num).toInt(),
      teamLogo: json['teamLogo'] as String,
      teamName: NhlLocalizedName.fromJson(
        json['teamName'] as Map<String, dynamic>,
      ),
      teamCommonName: NhlLocalizedName.fromJson(
        json['teamCommonName'] as Map<String, dynamic>,
      ),
      teamAbbrev: NhlLocalizedName.fromJson(
        json['teamAbbrev'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$NhlStandingRowToJson(NhlStandingRow instance) =>
    <String, dynamic>{
      'date': instance.date,
      'seasonId': instance.seasonId,
      'conferenceName': instance.conferenceName,
      'divisionName': instance.divisionName,
      'wildcardSequence': instance.wildcardSequence,
      'gamesPlayed': instance.gamesPlayed,
      'wins': instance.wins,
      'losses': instance.losses,
      'otLosses': instance.otLosses,
      'points': instance.points,
      'goalFor': instance.goalFor,
      'goalAgainst': instance.goalAgainst,
      'goalDifferential': instance.goalDifferential,
      'l10Wins': instance.l10Wins,
      'l10Losses': instance.l10Losses,
      'l10OtLosses': instance.l10OtLosses,
      'regulationPlusOtWins': instance.regulationPlusOtWins,
      'streakCode': instance.streakCode,
      'streakCount': instance.streakCount,
      'teamLogo': instance.teamLogo,
      'teamName': instance.teamName,
      'teamCommonName': instance.teamCommonName,
      'teamAbbrev': instance.teamAbbrev,
    };
