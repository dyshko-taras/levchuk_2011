import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_standings_service.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';

class StandingsRepository {
  StandingsRepository({required NhlStandingsService standingsService})
      : _standingsService = standingsService;

  final NhlStandingsService _standingsService;

  Future<NhlStandingsResponse> getStandingsNow() async {
    try {
      return await _standingsService.getStandingsNow();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<NhlStandingsResponse> getStandingsByDate(String yyyyMmDd) async {
    try {
      return await _standingsService.getStandingsByDate(yyyyMmDd);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
