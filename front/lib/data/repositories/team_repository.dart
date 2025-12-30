import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_club_schedule_service.dart';
import 'package:ice_line_tracker/data/api/nhl_club_stats_service.dart';
import 'package:ice_line_tracker/data/api/nhl_roster_service.dart';

class TeamRepository {
  TeamRepository({
    required NhlRosterService rosterService,
    required NhlClubStatsService clubStatsService,
    required NhlClubScheduleService clubScheduleService,
  }) : _rosterService = rosterService,
       _clubStatsService = clubStatsService,
       _clubScheduleService = clubScheduleService;

  final NhlRosterService _rosterService;
  final NhlClubStatsService _clubStatsService;
  final NhlClubScheduleService _clubScheduleService;

  Future<Object?> getRosterCurrent(String teamAbbrev) async {
    try {
      return await _rosterService.getRosterCurrent(teamAbbrev);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getRosterBySeason({
    required String teamAbbrev,
    required int seasonId,
  }) async {
    try {
      return await _rosterService.getRosterBySeason(teamAbbrev, seasonId);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getClubStatsNow(String teamAbbrev) async {
    try {
      return await _clubStatsService.getClubStatsNow(teamAbbrev);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getClubStatsBySeason({
    required String teamAbbrev,
    required int seasonId,
    required int gameTypeId,
  }) async {
    try {
      return await _clubStatsService.getClubStatsBySeason(
        teamAbbrev,
        seasonId,
        gameTypeId,
      );
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<Object?> getClubScheduleSeasonNow(String teamAbbrev) async {
    try {
      return await _clubScheduleService.getClubScheduleSeasonNow(teamAbbrev);
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
