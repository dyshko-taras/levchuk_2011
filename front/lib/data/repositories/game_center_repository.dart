import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_gamecenter_service.dart';

class GameCenterRepository {
  GameCenterRepository({required NhlGameCenterService service})
    : _service = service;

  final NhlGameCenterService _service;

  Future<Object?> getPlayByPlay(int gameId) async {
    try {
      return await _service.getPlayByPlay(gameId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getLanding(int gameId) async {
    try {
      return await _service.getLanding(gameId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getBoxscore(int gameId) async {
    try {
      return await _service.getBoxscore(gameId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
