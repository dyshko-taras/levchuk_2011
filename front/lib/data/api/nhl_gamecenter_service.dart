import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_gamecenter_service.g.dart';

@RestApi()
abstract class NhlGameCenterService {
  factory NhlGameCenterService(Dio dio, {String baseUrl}) =
      _NhlGameCenterService;

  @GET('/gamecenter/{gameId}/play-by-play')
  Future<dynamic> getPlayByPlay(
    @Path('gameId') int gameId,
  );

  @GET('/gamecenter/{gameId}/landing')
  Future<dynamic> getLanding(
    @Path('gameId') int gameId,
  );

  @GET('/gamecenter/{gameId}/boxscore')
  Future<dynamic> getBoxscore(
    @Path('gameId') int gameId,
  );
}
