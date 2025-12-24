import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_club_stats_service.g.dart';

@RestApi()
abstract class NhlClubStatsService {
  factory NhlClubStatsService(Dio dio, {String baseUrl}) = _NhlClubStatsService;

  @GET('/club-stats/{teamAbbrev}/now')
  Future<dynamic> getClubStatsNow(
    @Path('teamAbbrev') String teamAbbrev,
  );

  @GET('/club-stats/{teamAbbrev}/{seasonId}/{gameTypeId}')
  Future<dynamic> getClubStatsBySeason(
    @Path('teamAbbrev') String teamAbbrev,
    @Path('seasonId') int seasonId,
    @Path('gameTypeId') int gameTypeId,
  );
}
