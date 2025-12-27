import 'package:dio/dio.dart';
import 'package:ice_line_tracker/data/api/api_exception.dart';
import 'package:ice_line_tracker/data/api/nhl_seasons_service.dart';
import 'package:ice_line_tracker/data/api/nhl_standings_service.dart';
import 'package:ice_line_tracker/data/models/nhl_team.dart';

class BootstrapRepository {
  BootstrapRepository({
    required NhlStandingsService standingsService,
    required NhlSeasonsService seasonsService,
  }) : _standingsService = standingsService,
       _seasonsService = seasonsService;

  final NhlStandingsService _standingsService;
  final NhlSeasonsService _seasonsService;

  Future<List<NhlTeam>> getTeams() async {
    try {
      final response = await _standingsService.getStandingsNow();

      final byAbbrev = <String, NhlTeam>{};
      for (final row in response.standings) {
        final abbrev = row.teamAbbrev.defaultName;
        byAbbrev.putIfAbsent(
          abbrev,
          () => NhlTeam(
            abbrev: abbrev,
            name: row.teamName.defaultName,
            logoUrl: row.teamLogo,
          ),
        );
      }

      final teams = byAbbrev.values.toList()
        ..sort((a, b) => a.abbrev.compareTo(b.abbrev));

      return teams;
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }

  Future<List<int>> getSeasons() async {
    try {
      return await _seasonsService.getSeasons();
    } on DioException catch (exception) {
      throw ApiException.fromDioException(exception);
    }
  }
}
