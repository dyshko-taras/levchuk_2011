import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_player_service.dart';

class PlayerRepository {
  PlayerRepository({required NhlPlayerService service}) : _service = service;

  final NhlPlayerService _service;

  Future<Object?> getPlayerLanding(int playerId) async {
    try {
      return await _service.getPlayerLanding(playerId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getPlayerGameLogNow(int playerId) async {
    try {
      return await _service.getPlayerGameLogNow(playerId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getPlayerGameLogBySeason({
    required int playerId,
    required int seasonId,
    required int gameTypeId,
  }) async {
    try {
      return await _service.getPlayerGameLogBySeason(
        playerId,
        seasonId,
        gameTypeId,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
