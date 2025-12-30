import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_models.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_parsers.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class GameCenterStatsTab extends StatelessWidget {
  const GameCenterStatsTab({
    required this.header,
    required this.playByPlay,
    required this.boxscore,
    required this.boxscoreState,
    required this.onRetryLoadBoxscore,
    required this.segment,
    required this.onSegmentChanged,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;
  final Map<String, Object?>? boxscore;
  final AsyncState<Object?> boxscoreState;
  final VoidCallback onRetryLoadBoxscore;
  final StatsSegment segment;
  final ValueChanged<StatsSegment> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    final stats = parseStatsFromBoxscore(
      boxscore,
      header: header,
    );

    final showBoxscoreUnavailable =
        stats == null && (boxscoreState.isLoading || boxscoreState.hasError);

    final teamStats = stats?.teamStatsFor(segment) ?? _fallbackTeamStats();
    final skaters = stats?.skatersFor(segment) ?? _fallbackSkaters();
    final goalies = stats?.goaliesFor(segment);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sidePadding,
        AppSpacing.md,
        AppSizes.sidePadding,
        AppSpacing.x2l,
      ),
      children: [
        AppSegmentedControl<StatsSegment>(
          items: const [
            AppSegmentedControlItem(
              value: StatsSegment.home,
              label: AppStrings.segmentHome,
            ),
            AppSegmentedControlItem(
              value: StatsSegment.game,
              label: AppStrings.segmentGame,
            ),
            AppSegmentedControlItem(
              value: StatsSegment.away,
              label: AppStrings.segmentAway,
            ),
          ],
          value: segment,
          onChanged: onSegmentChanged,
        ),
        Gaps.hXl,
        if (showBoxscoreUnavailable)
          Container(
            decoration: cardDecoration(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: boxscoreState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const Text(AppStrings.splashInitFailed),
                      Gaps.hMd,
                      ElevatedButton(
                        onPressed: onRetryLoadBoxscore,
                        child: const Text(AppStrings.refresh),
                      ),
                    ],
                  ),
          ),
        _TeamStatsTable(teamStats: teamStats),
        Gaps.hXl,
        _PlayerTable(
          title: AppStrings.statsSkaters,
          columns: const [
            AppStrings.player,
            AppStrings.statsToi,
            AppStrings.statsG,
            AppStrings.statsA,
            AppStrings.statsPlusMinus,
          ],
          rows:
              skaters
                  ?.map(
                    (r) => [r.name, r.toi, r.goals, r.assists, r.plusMinus],
                  )
                  .toList() ??
              const [
                [
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                ],
              ],
        ),
        Gaps.hXl,
        _PlayerTable(
          title: AppStrings.statsGoalies,
          columns: const [
            AppStrings.player,
            AppStrings.statsToi,
            AppStrings.statsSvPct,
            AppStrings.statSa,
            AppStrings.statGa,
          ],
          rows:
              goalies
                  ?.map((r) => [r.name, r.toi, r.svPct, r.sa, r.ga])
                  .toList() ??
              const [
                [
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                  AppStrings.notAvailable,
                ],
              ],
        ),
      ],
    );
  }

  GameCenterTeamStats? _fallbackTeamStats() {
    final h = header;
    if (h == null) return null;

    final sog = switch (segment) {
      StatsSegment.home => '${h.homeSog}',
      StatsSegment.away => '${h.awaySog}',
      StatsSegment.game => '${h.homeSog} – ${h.awaySog}',
    };

    return GameCenterTeamStats(
      sog: sog,
      foPct: AppStrings.notAvailable,
      ppPct: AppStrings.notAvailable,
      pkPct: AppStrings.notAvailable,
      hits: AppStrings.notAvailable,
      blocks: AppStrings.notAvailable,
      giveaways: AppStrings.notAvailable,
      takeaways: AppStrings.notAvailable,
    );
  }

  List<GameCenterSkaterRow>? _fallbackSkaters() {
    final h = header;
    if (h == null) return null;

    final roster = rosterFromPlayByPlay(playByPlay);
    final plays = playsFromPlayByPlay(playByPlay);
    final counts = derivedGoalAssistCounts(plays);

    final players =
        roster.values.where((p) {
          if (segment == StatsSegment.game) return true;
          final teamId = segment == StatsSegment.home
              ? h.homeTeamId
              : h.awayTeamId;
          return p.teamId == teamId;
        }).toList()..sort((a, b) {
          final ap =
              (counts.goalsByPlayer[a.playerId] ?? 0) +
              (counts.assistsByPlayer[a.playerId] ?? 0);
          final bp =
              (counts.goalsByPlayer[b.playerId] ?? 0) +
              (counts.assistsByPlayer[b.playerId] ?? 0);
          if (bp != ap) return bp.compareTo(ap);
          return a.name.compareTo(b.name);
        });

    final rows = players.map((p) {
      final label = segment == StatsSegment.game
          ? '${h.abbrevForTeamId(p.teamId)} ${p.name}'
          : p.name;
      return GameCenterSkaterRow(
        name: label,
        toi: AppStrings.notAvailable,
        goals: '${counts.goalsByPlayer[p.playerId] ?? 0}',
        assists: '${counts.assistsByPlayer[p.playerId] ?? 0}',
        plusMinus: AppStrings.notAvailable,
      );
    }).toList();

    return rows;
  }
}

class _TeamStatsTable extends StatelessWidget {
  const _TeamStatsTable({
    required this.teamStats,
  });

  final GameCenterTeamStats? teamStats;

  static const _border = BorderSide(
    color: AppColors.borderGray,
  );

  @override
  Widget build(BuildContext context) {
    String v(String? raw) =>
        (raw == null || raw == AppStrings.notAvailable) ? '-' : raw;

    final ts = teamStats;

    TableRow row(String l1, String v1, String l2, String v2) {
      Widget cellLabel(String t) => Padding(
        padding: Insets.allSm,
        child: Text(t, style: AppFonts.bodyRegular),
      );
      Widget cellValue(String t) => Padding(
        padding: Insets.allSm,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            t,
            style: AppFonts.bodySemibold,
            textAlign: TextAlign.right,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

      return TableRow(
        children: [
          cellLabel(l1),
          cellValue(v1),
          cellLabel(l2),
          cellValue(v2),
        ],
      );
    }

    return Container(
      decoration: cardDecoration(),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: Table(
          border: const TableBorder(
            horizontalInside: _border,
            verticalInside: _border,
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(),
          },
          children: [
            row(
              AppStrings.statSog,
              v(ts?.sog),
              AppStrings.statHits,
              v(ts?.hits),
            ),
            row(
              AppStrings.statFoPct,
              v(ts?.foPct),
              AppStrings.statBlocks,
              v(ts?.blocks),
            ),
            row(
              AppStrings.statPpPct,
              v(ts?.ppPct),
              AppStrings.statGiveaways,
              v(ts?.giveaways),
            ),
            row(
              AppStrings.statPkPct,
              v(ts?.pkPct),
              AppStrings.statTakeaways,
              v(ts?.takeaways),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerTable extends StatelessWidget {
  const _PlayerTable({
    required this.title,
    required this.columns,
    required this.rows,
  });

  final String title;
  final List<String> columns;
  final List<List<String>> rows;

  static const double _headingRowHeight = 40;
  static const double _dataRowHeight = 44;
  static const double _tableExtraHeight = 2;
  static const double _playerColumnWidth = 220;
  static const double _metricColumnWidth = 64;

  @override
  Widget build(BuildContext context) {
    final height =
        _headingRowHeight + (_dataRowHeight * rows.length) + _tableExtraHeight;

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
          ),
          Gaps.hMd,
          LayoutBuilder(
            builder: (context, constraints) {
              final tableWidth = _tableWidthFor(
                columnCount: columns.length,
              );

              return ClipRRect(
                borderRadius: AppRadius.md,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: tableWidth,
                      height: height,
                      child: DataTable2(
                        minWidth: tableWidth,
                      headingRowColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      dataRowColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      dividerThickness: 1,
                      border: const TableBorder(
                        horizontalInside: BorderSide(
                          color: AppColors.borderGray,
                        ),
                      ),
                      headingRowHeight: _headingRowHeight,
                      dataRowHeight: _dataRowHeight,
                      columnSpacing: AppSpacing.lg,
                      horizontalMargin: AppSpacing.md,
                      headingTextStyle: AppFonts.captionSemibold.copyWith(
                        color: AppColors.textBlack,
                      ),
                      columns: [
                        DataColumn2(
                          label: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(columns[0]),
                          ),
                          fixedWidth: _playerColumnWidth,
                        ),
                        for (final c in columns.skip(1))
                          DataColumn2(
                            label: Center(child: Text(c)),
                            numeric: true,
                            fixedWidth: _metricColumnWidth,
                          ),
                      ],
                      rows: rows
                          .map(
                            (r) => DataRow2(
                              cells: [
                                DataCell(
                                  Text(
                                    r[0],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                for (final v in r.skip(1))
                                  DataCell(Center(child: Text(v))),
                              ],
                            ),
                          )
                          .toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  double _tableWidthFor({required int columnCount}) {
    final metricsCount = (columnCount - 1).clamp(0, 10);

    final desired =
        _playerColumnWidth +
        (metricsCount * _metricColumnWidth) +
        (metricsCount * AppSpacing.lg) +
        (AppSpacing.md * 2);

    return desired;
  }
}
