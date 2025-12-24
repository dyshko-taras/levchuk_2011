```yaml
app:
  name: IceLine Tracker
  package_id: com.example.app
  platforms: [android, ios]

  # File paths (constants & routing)
  routes_file: constants/app_routes.dart
  spacing_tokens: constants/app_spacing.dart
  durations_tokens: constants/app_durations.dart
  assets_constants:
    icons: constants/app_icons.dart
    images: constants/app_images.dart
  strings: app_strings

  # Codegen & validation
  codegen:
    strict: true
    unknown_prop: error
    enum_unknown: error
    forbid_inline_numbers: true

  theme:
    single_theme: true
    typography_source: ui/theme/app_fonts.dart
    colors_source: ui/theme/app_colors.dart
    
screens:
  - page_file: lib/ui/pages/splash_page.dart
    route: /splash
    page_class: SplashPage

  - page_file: lib/ui/pages/welcome_page.dart
    route: /welcome
    page_class: WelcomePage

  - page_file: lib/ui/pages/main_shell_page.dart
    route: /
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /home
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /standings
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /compare
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /favorites
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /predictions
    page_class: MainShellPage
  - page_file: lib/ui/pages/main_shell_page.dart
    route: /settings
    page_class: MainShellPage

  - page_file: lib/ui/pages/game_center_page.dart
    route: /game-center
    page_class: GameCenterPage

  - page_file: lib/ui/pages/team_page.dart
    route: /team
    page_class: TeamPage

  - page_file: lib/ui/pages/player_page.dart
    route: /player
    page_class: PlayerPage
```


```yaml
screen:
  page_file: lib/ui/pages/splash_page.dart
  route: /splash
  page_class: SplashPage
  purpose: "Show brand while initial app initialization runs, then route user to Welcome (first run) or Home."

  strings:
    AppStrings.splashBrandTitle - "IceLine Tracker"
    AppStrings.splashBrandSubtitle - "NHL Stats & Insights"
    AppStrings.splashTagline - "Follow every shift, goal and trend."
```

```yaml
screen:
  page_file: lib/ui/pages/welcome_page.dart
  route: /welcome
  page_class: WelcomePage
  strings:
    AppStrings.welcomeTitle - "Welcome to IceLine Tracker"
    AppStrings.welcomeDescription - "Track real-time games, standings and player stats in one clean view."
    AppStrings.welcomeDefaultDateLabel - "Default Date picker"
    AppStrings.today - "Today"
    AppStrings.yesterday - "Yesterday"
    AppStrings.tomorrow - "Tomorrow"
    AppStrings.welcomePushAlertsLabel - "Push alerts for goals & finals"
    AppStrings.welcomePushAlertsHelper - "You can change this anytime in Settings."
    AppStrings.getStarted - "Get Started"
  icons: []
  images:
    AppImages.welcomeHero
```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /home
  page_class: MainShellPage
  strings:
    AppStrings.liveScoresTitle - "Live Scores"
    AppStrings.liveNow - "Live Now"
    AppStrings.upcoming - "Upcoming"
    AppStrings.final - "Final"
    AppStrings.offlineCachedScores - "Offline — showing cached scores"
    AppStrings.navStandings - "Standings"
    AppStrings.navCompare - "Compare"
    AppStrings.navFavorites - "Favorites"
    AppStrings.navPredictions - "Predictions"
    AppStrings.navHome - "Home"
    AppStrings.openCalendar - "Calendar"
    AppStrings.openSettings - "Settings"
    AppStrings.toggleNotifications - "Notifications"
    AppStrings.toggleFavorite - "Favorite"
  icons:
    - AppIcons.calendar
    - AppIcons.settings
    - AppIcons.heartOutline
    - AppIcons.starOutline
    - AppIcons.navStandings
    - AppIcons.navCompare
    - AppIcons.navFavorites
    - AppIcons.navPredictions
    - AppIcons.navHome
    - AppIcons.offline
  images:
    - AppImages.offlineIllustration
```

```yaml
screen:
  page_file: lib/ui/pages/game_center_page.dart
  route: /game-center
  page_class: GameCenterPage
  strings:
    AppStrings.liveScoresTitle - "Live Scores"
    AppStrings.tabPlays - "Plays"
    AppStrings.tabGoals - "Goals"
    AppStrings.tabPenalties - "Penalties"
    AppStrings.subtabGoals - "Goals"
    AppStrings.subtabShots - "Shots"
    AppStrings.subtabHits - "Hits"
    AppStrings.tabStats - "Stats"
    AppStrings.tabRecap - "Recap"
    AppStrings.segmentHome - "Home"
    AppStrings.segmentGame - "Game"
    AppStrings.segmentAway - "Away"
    AppStrings.scoreByPeriod - "Score by period"
    AppStrings.specialTeams - "Special teams:"
    AppStrings.highlightsSummary - "Highlights summary"
    AppStrings.firstGoal - "First goal"
    AppStrings.gameWinningGoal - "Game-winning goal"
    AppStrings.broadcasters - "Broadcasters"
    AppStrings.share - "Share"
    AppStrings.toggleFavorite - "Favorite"
    AppStrings.toggleNotifications - "Notifications"
  icons:
    - AppIcons.back
    - AppIcons.heartOutline
    - AppIcons.starOutline
  images: []
```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /standings
  page_class: MainShellPage
  strings:
    AppStrings.standingsTitle - "Standings"
    AppStrings.standingsWildCard - "Wild Card"
    AppStrings.standingsLeague - "League"
    AppStrings.standingsDivision - "Division"
    AppStrings.refresh - "Refresh"
    AppStrings.standingsColPos - "Pos"
    AppStrings.standingsColTeam - "Team"
    AppStrings.standingsColGpWlOtl - "GP,W,L,OTL"
    AppStrings.standingsColPts - "PTS"
    AppStrings.standingsColGfGaDiff - "GF,GA,Diff"
    AppStrings.standingsColL10 - "L10"
    AppStrings.standingsColStreak - "Streak"
  icons:
    - AppIcons.refresh
  images: []
```

```yaml
screen:
  page_file: lib/ui/pages/team_page.dart
  route: /team
  page_class: TeamPage
  strings:
    AppStrings.teamTitle - "Team"
    AppStrings.tabRoster - "Roster"
    AppStrings.tabSchedule - "Schedule"
    AppStrings.tabTeamStats - "Team Stats"
    AppStrings.teamFavorite - "Favorite"
    AppStrings.teamRosterColNumber - "#"
    AppStrings.teamRosterColPos - "Pos"
    AppStrings.teamRosterColName - "Name"
    AppStrings.teamRosterColLine - "LW"
    AppStrings.teamScheduleColDate - "Date"
    AppStrings.teamScheduleColOpponent - "Opponent"
    AppStrings.teamScheduleColStatus - "STTT"
    AppStrings.teamStatsLast10 - "Last 10"
    AppStrings.teamStatsPpPk - "PP%/PK%"
    AppStrings.teamStatsAvgSogForAgainst - "Average SOG For/Against"
    AppStrings.teamStatsGfGa - "GF/GA"
    AppStrings.teamStatsWlOtl - "W-L-OTL"
    AppStrings.teamHighlightUpcoming - "Highlight upcoming"
  icons:
    - AppIcons.back
    - AppIcons.starOutline
    - AppIcons.starFilled
  images: []

```

```yaml
screen:
  page_file: lib/ui/pages/player_page.dart
  route: /player
  page_class: PlayerPage
  strings:
    AppStrings.playerTitle - "Player"
    AppStrings.playerShare - "Share"
    AppStrings.playerShootsLabel - "Shoots:"
    AppStrings.playerSeasonStats - "Season stats"
    AppStrings.playerPointsByGame - "Points by game"
    AppStrings.compare - "Compare"
    AppStrings.statsGp - "GP"
    AppStrings.statsG - "G"
    AppStrings.statsA - "A"
    AppStrings.statsP - "P"
    AppStrings.statsPlusMinus - "+/-"
    AppStrings.statsPim - "PIM"
    AppStrings.statsSog - "SOG"
    AppStrings.statsToi - "TOI"
    AppStrings.statsGs - "GS"
    AppStrings.statsW - "W"
    AppStrings.statsL - "L"
    AppStrings.statsOtl - "OTL"
    AppStrings.statsSvPct - "SV%"
    AppStrings.statsGaa - "GAA"
    AppStrings.statsSo - "SO"
  icons:
    - AppIcons.back
    - AppIcons.share
  images: []

```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /favorites
  page_class: MainShellPage
  strings:
    AppStrings.favoritesTitle - "Favorites"
    AppStrings.favoritesTeams - "Teams"
    AppStrings.favoritesGames - "Games"
    AppStrings.removeFromFavoritesQuestion - "Remove from favorites?"
    AppStrings.yes - "Yes"
    AppStrings.no - "No"
    AppStrings.gameStatusLive - "Live"
    AppStrings.gameStatusFinal - "Final"
    AppStrings.gameStatusScheduled - "Scheduled"
    AppStrings.gameStatusPostponed - "Postponed"
    AppStrings.bellGoals - "Bell Goals"
    AppStrings.bellFinal - "Bell Final"
    AppStrings.delete - "Delete"
    AppStrings.share - "Share"
  icons:
    - AppIcons.delete
    - AppIcons.share
  images:
    - AppImages.removeFromFavoritesIllustration

```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /compare
  page_class: MainShellPage
  strings:
    AppStrings.teamCompareTitle - "Team Compare"
    AppStrings.teamA - "Team A"
    AppStrings.teamB - "Team B"
    AppStrings.selectTeamPlaceholder - "Team"
    AppStrings.rangeLast5 - "Last 5"
    AppStrings.rangeLast10 - "Last 10"
    AppStrings.rangeSeason - "Season"
    AppStrings.formLabel - "Form:"
    AppStrings.goalsForAgainstPerGame - "Goals For/Against per game:"
    AppStrings.specialTeams - "Special teams:"
    AppStrings.faceoffAndSogAvg - "Faceoff% and SOG avg:"
    AppStrings.headToHead - "Head-to-head:"
    AppStrings.openNextGame - "Open Next Game"
  icons: []
  images: []
```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /settings
  page_class: MainShellPage
  strings:
    AppStrings.settingsTitle - "Settings"
    AppStrings.dateDefaults - "Date defaults"
    AppStrings.today - "Today"
    AppStrings.yesterday - "Yesterday"
    AppStrings.tomorrow - "Tomorrow"
    AppStrings.notifications - "Notifications"
    AppStrings.goalAlerts - "Goal alerts"
    AppStrings.finalAlerts - "Final alerts"
    AppStrings.preGameReminders - "Pre-game reminders"
    AppStrings.appSection - "App"
    AppStrings.poweredByNhlStatsApiV1 - "Powered by NHL Stats API v1"
    AppStrings.appVersion - "App version"
    AppStrings.openSourceLicenses - "Open source licenses"
  icons:
    - AppIcons.chevronRight
  images: []
```

```yaml
screen:
  page_file: lib/ui/pages/main_shell_page.dart
  route: /predictions
  page_class: MainShellPage
  strings:
    AppStrings.gameInsightLabTitle - "Game Insight Lab"
    AppStrings.refresh - "Refresh"
    AppStrings.today - "Today"
    AppStrings.tomorrow - "Tomorrow"
    AppStrings.custom - "Custom"
    AppStrings.all - "All"
    AppStrings.myFavorites - "My Favorites"
    AppStrings.keyMatchups - "Key Matchups"
    AppStrings.filterByTeam - "Filter by team"
    AppStrings.highConfidence - "High confidence"
    AppStrings.awayAtHome - "AWAY @ HOME"
    AppStrings.projectedWinner - "Projected winner:"
    AppStrings.expectedTotal - "Expected total:"
    AppStrings.form - "Form:"
    AppStrings.ppVsPk - "PP vs PK:"
    AppStrings.winProbability - "Win probability:"
    AppStrings.home - "Home:"
    AppStrings.away - "Away:"
    AppStrings.keyFactors - "Key factors:"
    AppStrings.keyFactorRecentRecord - "Last 10 games record (H/A)"
    AppStrings.keyFactorGoalDifferential - "Goal differential trend"
    AppStrings.keyFactorSpecialTeams - "Special teams difference (PP/PK)"
    AppStrings.keyFactorHeadToHead - "Head-to-head in last X meetings"
    AppStrings.predictionsDisclaimer - "This is an analytics-based projection, not betting advice."
    AppStrings.openGameCenter - "Open Game Center"
    AppStrings.watchThisGame - "Watch this game"
  icons:
    - AppIcons.refresh
    - AppIcons.chevronRight
    - AppIcons.dropdownChevron
  images: []
```