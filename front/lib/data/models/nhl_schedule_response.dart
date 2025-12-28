import 'package:ice_line_tracker/data/models/nhl_localized_name.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nhl_schedule_response.g.dart';

@JsonSerializable()
class NhlScheduleResponse {
  const NhlScheduleResponse({
    required this.nextStartDate,
    required this.previousStartDate,
    required this.gameWeek,
    this.numberOfGames,
  });

  factory NhlScheduleResponse.fromJson(Map<String, Object?> json) =>
      _$NhlScheduleResponseFromJson(json);

  final String nextStartDate;
  final String previousStartDate;
  final List<NhlGameDay> gameWeek;
  final int? numberOfGames;

  Map<String, Object?> toJson() => _$NhlScheduleResponseToJson(this);
}

@JsonSerializable()
class NhlGameDay {
  const NhlGameDay({
    required this.date,
    required this.numberOfGames,
    required this.games,
    this.dayAbbrev,
  });

  factory NhlGameDay.fromJson(Map<String, Object?> json) =>
      _$NhlGameDayFromJson(json);

  final String date;
  @JsonKey(defaultValue: '')
  final String? dayAbbrev;
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
    this.venue,
    this.neutralSite,
    this.venueUTCOffset,
    this.venueTimezone,
    this.tvBroadcasts,
    this.periodDescriptor,
    this.gameOutcome,
    this.gameCenterLink,
  });

  factory NhlScheduledGame.fromJson(Map<String, Object?> json) =>
      _$NhlScheduledGameFromJson(json);

  final int id;
  final int season;
  final int gameType;
  final String startTimeUTC;
  final String gameState;
  final String gameScheduleState;

  final NhlScheduleVenue? venue;
  final bool? neutralSite;
  final String? venueUTCOffset;
  final String? venueTimezone;

  final List<NhlTvBroadcast>? tvBroadcasts;
  final NhlPeriodDescriptor? periodDescriptor;
  final NhlGameOutcome? gameOutcome;

  final String? gameCenterLink;

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
    this.placeNameWithPreposition,
    this.darkLogo,
  });

  factory NhlScheduleTeam.fromJson(Map<String, Object?> json) =>
      _$NhlScheduleTeamFromJson(json);

  final int id;
  final String abbrev;
  final NhlLocalizedName commonName;
  final NhlLocalizedName placeName;
  final NhlLocalizedName? placeNameWithPreposition;
  final String logo;
  final String? darkLogo;
  final int? score;

  Map<String, Object?> toJson() => _$NhlScheduleTeamToJson(this);
}

@JsonSerializable()
class NhlScheduleVenue {
  const NhlScheduleVenue({required this.defaultName});

  factory NhlScheduleVenue.fromJson(Map<String, Object?> json) =>
      _$NhlScheduleVenueFromJson(json);

  @JsonKey(name: 'default')
  final String defaultName;

  Map<String, Object?> toJson() => _$NhlScheduleVenueToJson(this);
}

@JsonSerializable()
class NhlTvBroadcast {
  const NhlTvBroadcast({
    required this.id,
    required this.market,
    required this.countryCode,
    required this.network,
    required this.sequenceNumber,
  });

  factory NhlTvBroadcast.fromJson(Map<String, Object?> json) =>
      _$NhlTvBroadcastFromJson(json);

  final int id;
  final String market;
  final String countryCode;
  final String network;
  final int sequenceNumber;

  Map<String, Object?> toJson() => _$NhlTvBroadcastToJson(this);
}

@JsonSerializable()
class NhlPeriodDescriptor {
  const NhlPeriodDescriptor({
    required this.number,
    required this.periodType,
    required this.maxRegulationPeriods,
  });

  factory NhlPeriodDescriptor.fromJson(Map<String, Object?> json) =>
      _$NhlPeriodDescriptorFromJson(json);

  final int number;
  final String periodType;
  final int maxRegulationPeriods;

  Map<String, Object?> toJson() => _$NhlPeriodDescriptorToJson(this);
}

@JsonSerializable()
class NhlGameOutcome {
  const NhlGameOutcome({required this.lastPeriodType});

  factory NhlGameOutcome.fromJson(Map<String, Object?> json) =>
      _$NhlGameOutcomeFromJson(json);

  final String lastPeriodType;

  Map<String, Object?> toJson() => _$NhlGameOutcomeToJson(this);
}
