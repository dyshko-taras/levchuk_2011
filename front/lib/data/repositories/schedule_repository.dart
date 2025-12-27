import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_schedule_service.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';

class ScheduleRepository {
  ScheduleRepository({required NhlScheduleService scheduleService})
    : _scheduleService = scheduleService;

  final NhlScheduleService _scheduleService;

  Future<NhlScheduleResponse> getScheduleNow() async {
    try {
      return await _scheduleService.getScheduleNow();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<NhlScheduleResponse> getScheduleByDate(String yyyyMmDd) async {
    try {
      return await _scheduleService.getScheduleByDate(yyyyMmDd);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
