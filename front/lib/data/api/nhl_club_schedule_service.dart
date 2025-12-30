import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_club_schedule_service.g.dart';

@RestApi()
abstract class NhlClubScheduleService {
  factory NhlClubScheduleService(Dio dio, {String baseUrl}) =
      _NhlClubScheduleService;

  @GET('/club-schedule-season/{teamAbbrev}/now')
  Future<dynamic> getClubScheduleSeasonNow(
    @Path('teamAbbrev') String teamAbbrev,
  );
}


