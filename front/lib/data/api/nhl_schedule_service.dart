import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:retrofit/retrofit.dart';

part 'nhl_schedule_service.g.dart';

@RestApi()
abstract class NhlScheduleService {
  factory NhlScheduleService(Dio dio, {String baseUrl}) = _NhlScheduleService;

  @GET('/schedule/now')
  Future<NhlScheduleResponse> getScheduleNow();

  @GET('/schedule/{date}')
  Future<NhlScheduleResponse> getScheduleByDate(
    @Path('date') String date,
  );
}
