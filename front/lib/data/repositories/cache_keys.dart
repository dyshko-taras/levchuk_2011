class CacheKeys {
  const CacheKeys._();

  static const String seasons = 'cache_seasons_v1';
  static const String teams = 'cache_teams_v1';

  static const String standingsNow = 'cache_standings_now_v1';
  static String standingsByDate(String yyyyMmDd) => 'cache_standings_$yyyyMmDd';

  static const String scheduleNow = 'cache_schedule_now_v1';
  static String scheduleByDate(String yyyyMmDd) => 'cache_schedule_$yyyyMmDd';

  static String rosterCurrent(String teamAbbrev) =>
      'cache_roster_${teamAbbrev}_current_v1';

  static String clubScheduleSeasonNow(String teamAbbrev) =>
      'cache_club_schedule_${teamAbbrev}_season_now_v1';

  static String clubStatsNow(String teamAbbrev) =>
      'cache_club_stats_${teamAbbrev}_now_v1';
}
