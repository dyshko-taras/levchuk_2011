import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_standings_service.g.dart';

@RestApi()
abstract class NhlStandingsService {
  factory NhlStandingsService(Dio dio, {String baseUrl}) = _NhlStandingsService;

  @GET('/standings/now')
  Future<NhlStandingsResponse> getStandingsNow();

  @GET('/standings/{date}')
  Future<NhlStandingsResponse> getStandingsByDate(
    @Path('date') String date,
  );
}
