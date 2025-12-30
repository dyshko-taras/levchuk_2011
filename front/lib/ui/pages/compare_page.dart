import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/data/repositories/cached_standings_repository.dart';
import 'package:ice_line_tracker/data/repositories/cached_team_repository.dart';
import 'package:ice_line_tracker/providers/compare_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';
import 'package:ice_line_tracker/ui/widgets/buttons/primary_button.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:provider/provider.dart';

class ComparePage extends StatefulWidget {
  const ComparePage({super.key});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  Future<NhlStandingsResponse>? _standingsFuture;

  final Map<String, Future<_TeamCompareVm>> _teamDataFutures = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _standingsFuture ??= context
        .read<CachedStandingsRepository>()
        .getStandingsNow();
  }

  Future<_TeamCompareVm> _loadTeam(String abbrev) {
    final existing = _teamDataFutures[abbrev];
    if (existing != null) return existing;

    final repo = context.read<CachedTeamRepository>();
    final future = () async {
      final schedule = await repo.getClubScheduleSeasonNow(abbrev);
      final clubStats = await repo.getClubStatsNow(abbrev);
      return _TeamCompareVm(
        teamAbbrev: abbrev,
        games: _parseTeamGames(schedule, teamAbbrev: abbrev),
        ppPct: _findPct(
          clubStats,
          const ['ppPct', 'powerPlayPct', 'ppPctg'],
        ),
        pkPct: _findPct(
          clubStats,
          const ['pkPct', 'penaltyKillPct', 'pkPctg'],
        ),
        foPct: _findPct(
          clubStats,
          const ['foPct', 'faceoffPct', 'faceoffWinningPctg'],
        ),
      );
    }();

    _teamDataFutures[abbrev] = future;
    return future;
  }

  @override
  Widget build(BuildContext context) {
    final compare = context.watch<CompareProvider>();

    final teamA = compare.teamA;
    final teamB = compare.teamB;
    final range = compare.range;

    return FutureBuilder<NhlStandingsResponse>(
      future: _standingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final standings = snapshot.data;
        if (standings == null) {
          return const Center(child: Text(AppStrings.splashInitFailed));
        }

        final teams =
            standings.standings
                .map(
                  (r) => _TeamOption(
                    abbrev: r.teamAbbrev.defaultName,
                    name: r.teamCommonName.defaultName,
                  ),
                )
                .toList()
              ..sort((a, b) => a.abbrev.compareTo(b.abbrev));

        final rowByAbbrev = <String, NhlStandingRow>{};
        for (final row in standings.standings) {
          rowByAbbrev[row.teamAbbrev.defaultName] = row;
        }

        final aFuture = teamA == null ? null : _loadTeam(teamA);
        final bFuture = teamB == null ? null : _loadTeam(teamB);
        final standingsRowA = teamA == null ? null : rowByAbbrev[teamA];
        final standingsRowB = teamB == null ? null : rowByAbbrev[teamB];

        return ListView(
          padding: Insets.allLg,
          children: [
            Row(
              children: [
                Expanded(
                  child: _TeamDropdown(
                    title: AppStrings.teamA,
                    teams: teams,
                    value: teamA,
                    onChanged: compare.setTeamA,
                  ),
                ),
                Gaps.wMd,
                Expanded(
                  child: _TeamDropdown(
                    title: AppStrings.teamB,
                    teams: teams,
                    value: teamB,
                    onChanged: compare.setTeamB,
                  ),
                ),
              ],
            ),
            Gaps.hLg,
            AppSegmentedControl<CompareRange>(
              value: range,
              onChanged: compare.setRange,
              items: const [
                AppSegmentedControlItem(
                  value: CompareRange.last5,
                  label: AppStrings.rangeLast5,
                ),
                AppSegmentedControlItem(
                  value: CompareRange.last10,
                  label: AppStrings.rangeLast10,
                ),
                AppSegmentedControlItem(
                  value: CompareRange.season,
                  label: AppStrings.rangeSeason,
                ),
              ],
            ),
            Gaps.hLg,
            const Text(AppStrings.formLabel, style: AppFonts.heading2),
            Gaps.hSm,
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    child: _FormLine(
                      label: 'Team A',
                      teamAbbrev: teamA,
                      teamDataFuture: aFuture,
                      range: range,
                      standingsRow: standingsRowA,
                    ),
                  ),
                ),
                Gaps.wMd,
                Expanded(
                  child: _InfoCard(
                    child: _FormLine(
                      label: 'Team B',
                      teamAbbrev: teamB,
                      teamDataFuture: bFuture,
                      range: range,
                      standingsRow: standingsRowB,
                    ),
                  ),
                ),
              ],
            ),
            Gaps.hLg,
            const Text(
              AppStrings.goalsForAgainstPerGame,
              style: AppFonts.heading2,
            ),
            Gaps.hSm,
            _InfoCard(
              child: SizedBox(
                height: 210,
                child: _GoalsChart(
                  teamA: teamA,
                  teamB: teamB,
                  range: range,
                  teamAFuture: aFuture,
                  teamBFuture: bFuture,
                ),
              ),
            ),
            Gaps.hLg,
            const Text(AppStrings.specialTeams, style: AppFonts.heading2),
            Gaps.hSm,
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    child: _PctLine(
                      title: teamB == null ? 'Team B: PP%' : '$teamB: PP%',
                      teamFuture: bFuture,
                      pick: (v) => v.ppPct,
                    ),
                  ),
                ),
                Gaps.wMd,
                Expanded(
                  child: _InfoCard(
                    child: _PctLine(
                      title: teamA == null ? 'Team A: PK%' : '$teamA: PK%',
                      teamFuture: aFuture,
                      pick: (v) => v.pkPct,
                    ),
                  ),
                ),
              ],
            ),
            Gaps.hLg,
            const Text(
              AppStrings.faceoffAndSogAvg,
              style: AppFonts.heading2,
            ),
            Gaps.hSm,
            _InfoCard(
              child: _FaceoffLine(
                teamA: teamA,
                teamB: teamB,
                teamAFuture: aFuture,
                teamBFuture: bFuture,
              ),
            ),
            Gaps.hLg,
            const Text(AppStrings.headToHead, style: AppFonts.heading2),
            Gaps.hSm,
            _InfoCard(
              child: _HeadToHeadLine(
                teamA: teamA,
                teamB: teamB,
                teamAFuture: aFuture,
              ),
            ),
            Gaps.h2Xl,
            PrimaryButton(
              label: AppStrings.openNextGame,
              onPressed: teamA == null || teamB == null
                  ? null
                  : () => unawaited(
                      _openNextGame(
                        context,
                        teamA: teamA,
                        teamB: teamB,
                        teamAFuture: aFuture,
                      ),
                    ),
            ),
            Gaps.h2Xl,
            Gaps.h2Xl,
          ],
        );
      },
    );
  }
}

class _TeamOption {
  const _TeamOption({required this.abbrev, required this.name});

  final String abbrev;
  final String name;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});

  final Widget child;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: AppRadius.md,
        border: Border.all(color: _borderColor, width: _borderWidth),
        boxShadow: const [
          BoxShadow(
            color: _shadowColor,
            offset: Offset(0, _shadowOffsetY),
            blurRadius: _shadowBlurRadius,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: AppRadius.md, child: child),
    );
  }
}

class _TeamDropdown extends StatelessWidget {
  const _TeamDropdown({
    required this.title,
    required this.teams,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final List<_TeamOption> teams;
  final String? value;
  final ValueChanged<String?> onChanged;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);

  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFonts.bodySemibold),
        Gaps.hSm,
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: AppGradients.segmentedControl,
            borderRadius: AppRadius.md,
            border: Border.all(color: _borderColor, width: _borderWidth),
            boxShadow: const [
              BoxShadow(
                color: _shadowColor,
                offset: Offset(0, _shadowOffsetY),
                blurRadius: _shadowBlurRadius,
              ),
            ],
          ),
          padding: Insets.hMd,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: value,
              icon: SvgPicture.asset(
                AppIcons.dropdownChevron,
                colorFilter: const ColorFilter.mode(
                  AppColors.textBlack,
                  BlendMode.srcIn,
                ),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  child: Text(AppStrings.selectTeamPlaceholder),
                ),
                ...teams.map(
                  (t) => DropdownMenuItem<String?>(
                    value: t.abbrev,
                    child: Text(t.name, style: theme.textTheme.bodyMedium),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormLine extends StatelessWidget {
  const _FormLine({
    required this.label,
    required this.teamAbbrev,
    required this.teamDataFuture,
    required this.range,
    required this.standingsRow,
  });

  final String label;
  final String? teamAbbrev;
  final Future<_TeamCompareVm>? teamDataFuture;
  final CompareRange range;
  final NhlStandingRow? standingsRow;

  @override
  Widget build(BuildContext context) {
    if (teamAbbrev == null) {
      return Padding(
        padding: Insets.allLg,
        child: Text('$label: ${AppStrings.notAvailable}'),
      );
    }

    final future = teamDataFuture;
    if (future == null) {
      return const Padding(
        padding: Insets.allLg,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<_TeamCompareVm>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final record = _recordText(
          range: range,
          standingsRow: standingsRow,
          data: data,
        );

        return Padding(
          padding: Insets.allLg,
          child: Text('$label: $record'),
        );
      },
    );
  }
}

class _PctLine extends StatelessWidget {
  const _PctLine({
    required this.title,
    required this.teamFuture,
    required this.pick,
  });

  final String title;
  final Future<_TeamCompareVm>? teamFuture;
  final String? Function(_TeamCompareVm) pick;

  @override
  Widget build(BuildContext context) {
    final future = teamFuture;
    if (future == null) {
      return Padding(
        padding: Insets.allLg,
        child: Text('$title ${AppStrings.notAvailable}'),
      );
    }

    return FutureBuilder<_TeamCompareVm>(
      future: future,
      builder: (context, snapshot) {
        final v = snapshot.data == null ? null : pick(snapshot.data!);
        final label = v ?? AppStrings.notAvailable;
        return Padding(padding: Insets.allLg, child: Text('$title $label'));
      },
    );
  }
}

class _FaceoffLine extends StatelessWidget {
  const _FaceoffLine({
    required this.teamA,
    required this.teamB,
    required this.teamAFuture,
    required this.teamBFuture,
  });

  final String? teamA;
  final String? teamB;
  final Future<_TeamCompareVm>? teamAFuture;
  final Future<_TeamCompareVm>? teamBFuture;

  @override
  Widget build(BuildContext context) {
    final aFuture = teamAFuture;
    final bFuture = teamBFuture;

    if (aFuture == null && bFuture == null) {
      return const Padding(
        padding: Insets.allLg,
        child: Text('FO% ${AppStrings.notAvailable}'),
      );
    }

    final future = () async {
      final a = aFuture == null ? null : await aFuture;
      final b = bFuture == null ? null : await bFuture;
      return [a, b];
    }();

    return FutureBuilder<List<_TeamCompareVm?>>(
      future: future,
      builder: (context, snapshot) {
        final a = snapshot.data?.firstOrNull;
        final b = snapshot.data?.lastOrNull;
        final aLabel = a?.foPct ?? AppStrings.notAvailable;
        final bLabel = b?.foPct ?? AppStrings.notAvailable;
        final aTitle = teamA ?? 'Team A';
        final bTitle = teamB ?? 'Team B';
        return Padding(
          padding: Insets.allLg,
          child: Text('FO% $aTitle: $aLabel  $bTitle: $bLabel'),
        );
      },
    );
  }
}

class _HeadToHeadLine extends StatelessWidget {
  const _HeadToHeadLine({
    required this.teamA,
    required this.teamB,
    required this.teamAFuture,
  });

  final String? teamA;
  final String? teamB;
  final Future<_TeamCompareVm>? teamAFuture;

  @override
  Widget build(BuildContext context) {
    final a = teamA;
    final b = teamB;
    if (a == null || b == null) {
      return const Padding(
        padding: Insets.allLg,
        child: Text(AppStrings.notAvailable),
      );
    }

    final future = teamAFuture;
    if (future == null) {
      return const Padding(
        padding: Insets.allLg,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<_TeamCompareVm>(
      future: future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Padding(
            padding: Insets.allLg,
            child: Text(AppStrings.notAvailable),
          );
        }

        final vs = data.games
            .where((g) => g.opponentAbbrev == b)
            .where((g) => g.isFinal)
            .toList();

        var wins = 0;
        var losses = 0;
        for (final g in vs) {
          if (g.goalsFor == null || g.goalsAgainst == null) continue;
          if (g.goalsFor! > g.goalsAgainst!) {
            wins++;
          } else {
            losses++;
          }
        }

        final label = '$wins–$losses $a';
        return Padding(padding: Insets.allLg, child: Text(label));
      },
    );
  }
}

class _GoalsChart extends StatelessWidget {
  const _GoalsChart({
    required this.teamA,
    required this.teamB,
    required this.range,
    required this.teamAFuture,
    required this.teamBFuture,
  });

  final String? teamA;
  final String? teamB;
  final CompareRange range;
  final Future<_TeamCompareVm>? teamAFuture;
  final Future<_TeamCompareVm>? teamBFuture;

  @override
  Widget build(BuildContext context) {
    final aFuture = teamAFuture;
    final bFuture = teamBFuture;
    if (aFuture == null && bFuture == null) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    final futures = <Future<_TeamCompareVm>?>[
      aFuture,
      bFuture,
    ].whereType<Future<_TeamCompareVm>>().toList(growable: false);

    return FutureBuilder<List<_TeamCompareVm>>(
      future: Future.wait(futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? const <_TeamCompareVm>[];
        final a = aFuture == null ? null : data.firstOrNull;
        final b = bFuture == null ? null : data.lastOrNull;

        final n = switch (range) {
          CompareRange.last5 => 5,
          CompareRange.last10 => 10,
          CompareRange.season => 30,
        };

        final aSeries = _goalsForSeries(a, n);
        final bSeries = _goalsForSeries(b, n);

        if (aSeries.isEmpty && bSeries.isEmpty) {
          return const Center(child: Text(AppStrings.notAvailable));
        }

        final maxY = <double>[
          ...aSeries.map((e) => e.y),
          ...bSeries.map((e) => e.y),
        ].fold<double>(0, (m, v) => v > m ? v : m);

        return Padding(
          padding: Insets.allMd,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY == 0 ? 6 : (maxY + 1),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineBarsData: [
                if (aSeries.isNotEmpty)
                  LineChartBarData(
                    spots: aSeries,
                    isCurved: true,
                    color: AppColors.primaryRed,
                    barWidth: 2.2,
                    dotData: const FlDotData(show: false),
                  ),
                if (bSeries.isNotEmpty)
                  LineChartBarData(
                    spots: bSeries,
                    isCurved: true,
                    color: AppColors.scheduledGreen,
                    barWidth: 2.2,
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _openNextGame(
  BuildContext context, {
  required String teamA,
  required String teamB,
  required Future<_TeamCompareVm>? teamAFuture,
}) async {
  final aFuture = teamAFuture;
  if (aFuture == null) return;

  final a = await aFuture;
  final now = DateTime.now().toUtc();

  final next =
      a.games
          .where((g) => g.opponentAbbrev == teamB)
          .where((g) => g.dateUtc.isAfter(now))
          .where((g) => !g.isFinal)
          .toList()
        ..sort((x, y) => x.dateUtc.compareTo(y.dateUtc));

  if (next.isEmpty) return;
  final game = next.first.game;
  if (!context.mounted) return;

  unawaited(
    Navigator.pushNamed(
      context,
      AppRoutes.gameCenter,
      arguments: game ?? next.first.gameId,
    ),
  );
}

String _recordText({
  required CompareRange range,
  required NhlStandingRow? standingsRow,
  required _TeamCompareVm? data,
}) {
  if (range == CompareRange.season && standingsRow != null) {
    final w = standingsRow.wins;
    final l = standingsRow.losses;
    final otl = standingsRow.otLosses;
    return '$w-$l-$otl';
  }
  if (data == null) return AppStrings.notAvailable;

  final n = switch (range) {
    CompareRange.last5 => 5,
    CompareRange.last10 => 10,
    CompareRange.season => 10,
  };

  final games = data.games.where((g) => g.isFinal).toList()
    ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));

  var wins = 0;
  var losses = 0;
  var otLosses = 0;
  for (final g in games.take(n)) {
    if (g.goalsFor == null || g.goalsAgainst == null) continue;
    if (g.goalsFor! > g.goalsAgainst!) {
      wins++;
    } else if (g.lastPeriodType != null && g.lastPeriodType != 'REG') {
      otLosses++;
    } else {
      losses++;
    }
  }

  return '$wins-$losses-$otLosses';
}

List<FlSpot> _goalsForSeries(_TeamCompareVm? vm, int n) {
  if (vm == null) return const [];
  final games = vm.games.where((g) => g.isFinal && g.goalsFor != null).toList()
    ..sort((a, b) => b.dateUtc.compareTo(a.dateUtc));

  final slice = games.take(n).toList()
    ..sort((a, b) => a.dateUtc.compareTo(b.dateUtc));
  final spots = <FlSpot>[];
  for (var i = 0; i < slice.length; i++) {
    spots.add(FlSpot(i.toDouble(), slice[i].goalsFor!.toDouble()));
  }
  return spots;
}

class _TeamCompareVm {
  const _TeamCompareVm({
    required this.teamAbbrev,
    required this.games,
    required this.ppPct,
    required this.pkPct,
    required this.foPct,
  });

  final String teamAbbrev;
  final List<_TeamGameVm> games;
  final String? ppPct;
  final String? pkPct;
  final String? foPct;
}

class _TeamGameVm {
  const _TeamGameVm({
    required this.gameId,
    required this.dateUtc,
    required this.opponentAbbrev,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.isFinal,
    required this.lastPeriodType,
    required this.game,
  });

  final int gameId;
  final DateTime dateUtc;
  final String opponentAbbrev;
  final int? goalsFor;
  final int? goalsAgainst;
  final bool isFinal;
  final String? lastPeriodType;
  final NhlScheduledGame? game;
}

List<_TeamGameVm> _parseTeamGames(
  Object? raw, {
  required String teamAbbrev,
}) {
  if (raw is! Map) return const [];
  final games = raw['games'];
  if (games is! List) return const [];

  final result = <_TeamGameVm>[];
  for (final item in games) {
    if (item is! Map) continue;
    final m = item.cast<String, Object?>();
    final id = m['id'];
    if (id is! num) continue;

    final dateUtc = _dateForGame(m);
    if (dateUtc == null) continue;

    final home = m['homeTeam'];
    final away = m['awayTeam'];
    if (home is! Map || away is! Map) continue;

    final homeAbbrev = home['abbrev'];
    final awayAbbrev = away['abbrev'];
    if (homeAbbrev is! String || awayAbbrev is! String) continue;

    final isHome = homeAbbrev == teamAbbrev;
    final opponent = isHome ? awayAbbrev : homeAbbrev;

    final homeScore = home['score'];
    final awayScore = away['score'];
    final isFinal = homeScore is num && awayScore is num;

    final gf = isFinal
        ? (isHome ? homeScore.toInt() : awayScore.toInt())
        : null;
    final ga = isFinal
        ? (isHome ? awayScore.toInt() : homeScore.toInt())
        : null;

    final lastPeriodType = _lastPeriodType(m);

    NhlScheduledGame? scheduled;
    try {
      scheduled = NhlScheduledGame.fromJson(Map<String, Object?>.from(m));
    } on Object {
      scheduled = null;
    }

    result.add(
      _TeamGameVm(
        gameId: id.toInt(),
        dateUtc: dateUtc,
        opponentAbbrev: opponent,
        goalsFor: gf,
        goalsAgainst: ga,
        isFinal: isFinal,
        lastPeriodType: lastPeriodType,
        game: scheduled,
      ),
    );
  }

  return result;
}

DateTime? _dateForGame(Map<String, Object?> game) {
  final startUtc = game['startTimeUTC'];
  final dt = DateTime.tryParse(startUtc is String ? startUtc : '')?.toUtc();
  if (dt != null) return dt;

  final gameDate = game['gameDate'];
  if (gameDate is! String || gameDate.length < 10) return null;
  final parts = gameDate.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  return DateTime.utc(year, month, day);
}

String? _lastPeriodType(Map<String, Object?> game) {
  final outcome = game['gameOutcome'];
  if (outcome is Map) {
    final lastPeriod = outcome['lastPeriodType'];
    if (lastPeriod is String && lastPeriod.isNotEmpty) return lastPeriod;
  }
  return null;
}

String? _findPct(Object? raw, List<String> keys) {
  if (raw is! Map) return null;
  final value = _findValueByKeys(raw, keys, maxDepth: 4);
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toString();
  return null;
}

Object? _findValueByKeys(
  Map<Object?, Object?> raw,
  List<String> keys, {
  required int maxDepth,
}) {
  if (maxDepth < 0) return null;
  for (final k in keys) {
    if (raw.containsKey(k)) return raw[k];
  }
  for (final v in raw.values) {
    if (v is Map) {
      final found = _findValueByKeys(
        Map<Object?, Object?>.from(v),
        keys,
        maxDepth: maxDepth - 1,
      );
      if (found != null) return found;
    }
  }
  return null;
}

extension _FirstOrNullX<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
