import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_player_service.g.dart';

@RestApi()
abstract class NhlPlayerService {
  factory NhlPlayerService(Dio dio, {String baseUrl}) = _NhlPlayerService;

  @GET('/player/{playerId}/landing')
  Future<dynamic> getPlayerLanding(
    @Path('playerId') int playerId,
  );

  @GET('/player/{playerId}/game-log/now')
  Future<dynamic> getPlayerGameLogNow(
    @Path('playerId') int playerId,
  );

  @GET('/player/{playerId}/game-log/{seasonId}/{gameTypeId}')
  Future<dynamic> getPlayerGameLogBySeason(
    @Path('playerId') int playerId,
    @Path('seasonId') int seasonId,
    @Path('gameTypeId') int gameTypeId,
  );
}
