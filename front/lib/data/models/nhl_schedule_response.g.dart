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
      numberOfGames: (json['numberOfGames'] as num?)?.toInt(),
    );

Map<String, dynamic> _$NhlScheduleResponseToJson(
  NhlScheduleResponse instance,
) => <String, dynamic>{
  'nextStartDate': instance.nextStartDate,
  'previousStartDate': instance.previousStartDate,
  'gameWeek': instance.gameWeek,
  'numberOfGames': instance.numberOfGames,
};

NhlGameDay _$NhlGameDayFromJson(Map<String, dynamic> json) => NhlGameDay(
  date: json['date'] as String,
  numberOfGames: (json['numberOfGames'] as num).toInt(),
  games: (json['games'] as List<dynamic>)
      .map((e) => NhlScheduledGame.fromJson(e as Map<String, dynamic>))
      .toList(),
  dayAbbrev: json['dayAbbrev'] as String? ?? '',
);

Map<String, dynamic> _$NhlGameDayToJson(NhlGameDay instance) =>
    <String, dynamic>{
      'date': instance.date,
      'dayAbbrev': instance.dayAbbrev,
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
  venue: json['venue'] == null
      ? null
      : NhlScheduleVenue.fromJson(json['venue'] as Map<String, dynamic>),
  neutralSite: json['neutralSite'] as bool?,
  venueUTCOffset: json['venueUTCOffset'] as String?,
  venueTimezone: json['venueTimezone'] as String?,
  tvBroadcasts: (json['tvBroadcasts'] as List<dynamic>?)
      ?.map((e) => NhlTvBroadcast.fromJson(e as Map<String, dynamic>))
      .toList(),
  periodDescriptor: json['periodDescriptor'] == null
      ? null
      : NhlPeriodDescriptor.fromJson(
          json['periodDescriptor'] as Map<String, dynamic>,
        ),
  gameOutcome: json['gameOutcome'] == null
      ? null
      : NhlGameOutcome.fromJson(json['gameOutcome'] as Map<String, dynamic>),
  gameCenterLink: json['gameCenterLink'] as String?,
);

Map<String, dynamic> _$NhlScheduledGameToJson(NhlScheduledGame instance) =>
    <String, dynamic>{
      'id': instance.id,
      'season': instance.season,
      'gameType': instance.gameType,
      'startTimeUTC': instance.startTimeUTC,
      'gameState': instance.gameState,
      'gameScheduleState': instance.gameScheduleState,
      'venue': instance.venue,
      'neutralSite': instance.neutralSite,
      'venueUTCOffset': instance.venueUTCOffset,
      'venueTimezone': instance.venueTimezone,
      'tvBroadcasts': instance.tvBroadcasts,
      'periodDescriptor': instance.periodDescriptor,
      'gameOutcome': instance.gameOutcome,
      'gameCenterLink': instance.gameCenterLink,
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
      placeNameWithPreposition: json['placeNameWithPreposition'] == null
          ? null
          : NhlLocalizedName.fromJson(
              json['placeNameWithPreposition'] as Map<String, dynamic>,
            ),
      darkLogo: json['darkLogo'] as String?,
    );

Map<String, dynamic> _$NhlScheduleTeamToJson(NhlScheduleTeam instance) =>
    <String, dynamic>{
      'id': instance.id,
      'abbrev': instance.abbrev,
      'commonName': instance.commonName,
      'placeName': instance.placeName,
      'placeNameWithPreposition': instance.placeNameWithPreposition,
      'logo': instance.logo,
      'darkLogo': instance.darkLogo,
      'score': instance.score,
    };

NhlScheduleVenue _$NhlScheduleVenueFromJson(Map<String, dynamic> json) =>
    NhlScheduleVenue(defaultName: json['default'] as String);

Map<String, dynamic> _$NhlScheduleVenueToJson(NhlScheduleVenue instance) =>
    <String, dynamic>{'default': instance.defaultName};

NhlTvBroadcast _$NhlTvBroadcastFromJson(Map<String, dynamic> json) =>
    NhlTvBroadcast(
      id: (json['id'] as num).toInt(),
      market: json['market'] as String,
      countryCode: json['countryCode'] as String,
      network: json['network'] as String,
      sequenceNumber: (json['sequenceNumber'] as num).toInt(),
    );

Map<String, dynamic> _$NhlTvBroadcastToJson(NhlTvBroadcast instance) =>
    <String, dynamic>{
      'id': instance.id,
      'market': instance.market,
      'countryCode': instance.countryCode,
      'network': instance.network,
      'sequenceNumber': instance.sequenceNumber,
    };

NhlPeriodDescriptor _$NhlPeriodDescriptorFromJson(Map<String, dynamic> json) =>
    NhlPeriodDescriptor(
      number: (json['number'] as num).toInt(),
      periodType: json['periodType'] as String,
      maxRegulationPeriods: (json['maxRegulationPeriods'] as num).toInt(),
    );

Map<String, dynamic> _$NhlPeriodDescriptorToJson(
  NhlPeriodDescriptor instance,
) => <String, dynamic>{
  'number': instance.number,
  'periodType': instance.periodType,
  'maxRegulationPeriods': instance.maxRegulationPeriods,
};

NhlGameOutcome _$NhlGameOutcomeFromJson(Map<String, dynamic> json) =>
    NhlGameOutcome(lastPeriodType: json['lastPeriodType'] as String);

Map<String, dynamic> _$NhlGameOutcomeToJson(NhlGameOutcome instance) =>
    <String, dynamic>{'lastPeriodType': instance.lastPeriodType};
