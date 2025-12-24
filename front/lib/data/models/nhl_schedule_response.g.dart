// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhl_schedule_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NhlScheduleResponse _$NhlScheduleResponseFromJson(Map<String, dynamic> json) =>
    NhlScheduleResponse(
      nextStartDate: json['nextStartDate'] as String,
      previousStartDate: json['previousStartDate'] as String,
      gameWeek: (json['gameWeek'] as List<dynamic>)
          .map((e) => NhlGameDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NhlScheduleResponseToJson(
  NhlScheduleResponse instance,
) => <String, dynamic>{
  'nextStartDate': instance.nextStartDate,
  'previousStartDate': instance.previousStartDate,
  'gameWeek': instance.gameWeek,
};

NhlGameDay _$NhlGameDayFromJson(Map<String, dynamic> json) => NhlGameDay(
  date: json['date'] as String,
  numberOfGames: (json['numberOfGames'] as num).toInt(),
  games: (json['games'] as List<dynamic>)
      .map((e) => NhlScheduledGame.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$NhlGameDayToJson(NhlGameDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'numberOfGames': instance.numberOfGames,
      'games': instance.games,
    };

NhlScheduledGame _$NhlScheduledGameFromJson(
  Map<String, dynamic> json,
) => NhlScheduledGame(
  id: (json['id'] as num).toInt(),
  season: (json['season'] as num).toInt(),
  gameType: (json['gameType'] as num).toInt(),
  startTimeUTC: json['startTimeUTC'] as String,
  gameState: json['gameState'] as String,
  gameScheduleState: json['gameScheduleState'] as String,
  awayTeam: NhlScheduleTeam.fromJson(json['awayTeam'] as Map<String, dynamic>),
  homeTeam: NhlScheduleTeam.fromJson(json['homeTeam'] as Map<String, dynamic>),
);

Map<String, dynamic> _$NhlScheduledGameToJson(NhlScheduledGame instance) =>
    <String, dynamic>{
      'id': instance.id,
      'season': instance.season,
      'gameType': instance.gameType,
      'startTimeUTC': instance.startTimeUTC,
      'gameState': instance.gameState,
      'gameScheduleState': instance.gameScheduleState,
      'awayTeam': instance.awayTeam,
      'homeTeam': instance.homeTeam,
    };

NhlScheduleTeam _$NhlScheduleTeamFromJson(Map<String, dynamic> json) =>
    NhlScheduleTeam(
      id: (json['id'] as num).toInt(),
      abbrev: json['abbrev'] as String,
      commonName: NhlLocalizedName.fromJson(
        json['commonName'] as Map<String, dynamic>,
      ),
      placeName: NhlLocalizedName.fromJson(
        json['placeName'] as Map<String, dynamic>,
      ),
      logo: json['logo'] as String,
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NhlScheduleTeamToJson(NhlScheduleTeam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'abbrev': instance.abbrev,
      'commonName': instance.commonName,
      'placeName': instance.placeName,
      'logo': instance.logo,
      'score': instance.score,
    };
