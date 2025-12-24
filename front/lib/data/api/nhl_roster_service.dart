import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_roster_service.g.dart';

@RestApi()
abstract class NhlRosterService {
  factory NhlRosterService(Dio dio, {String baseUrl}) = _NhlRosterService;

  @GET('/roster/{teamAbbrev}/current')
  Future<dynamic> getRosterCurrent(
    @Path('teamAbbrev') String teamAbbrev,
  );

  @GET('/roster/{teamAbbrev}/{seasonId}')
  Future<dynamic> getRosterBySeason(
    @Path('teamAbbrev') String teamAbbrev,
    @Path('seasonId') int seasonId,
  );
}
