import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_models.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_parsers.dart';

class GameCenterStatsTab extends StatelessWidget {
  const GameCenterStatsTab({
    required this.header,
    required this.playByPlay,
    required this.segment,
    required this.onSegmentChanged,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;
  final StatsSegment segment;
  final ValueChanged<StatsSegment> onSegmentChanged;

  @override
  Widget build(BuildContext context) {
    final roster = rosterFromPlayByPlay(playByPlay);
    final plays = playsFromPlayByPlay(playByPlay);
    final counts = derivedGoalAssistCounts(plays);

    final players =
        roster.values.where((p) {
          if (segment == StatsSegment.game) return true;
          final teamId = segment == StatsSegment.home
              ? header?.homeTeamId
              : header?.awayTeamId;
          return teamId != null && p.teamId == teamId;
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

    final topPlayers = players.take(12).toList();

    final sogLabel = switch (segment) {
      StatsSegment.home =>
        header == null ? AppStrings.notAvailable : '${header!.homeSog}',
      StatsSegment.away =>
        header == null ? AppStrings.notAvailable : '${header!.awaySog}',
      StatsSegment.game =>
        header == null
            ? AppStrings.notAvailable
            : '${header!.homeSog} – ${header!.awaySog}',
    };

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
        Container(
          decoration: cardDecoration(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: _KeyValueColumn(
                  items: [
                    (AppStrings.statSog, sogLabel),
                    (AppStrings.statFoPct, AppStrings.notAvailable),
                    (AppStrings.statPpPct, AppStrings.notAvailable),
                    (AppStrings.statPkPct, AppStrings.notAvailable),
                  ],
                ),
              ),
              const Expanded(
                child: _KeyValueColumn(
                  items: [
                    (AppStrings.statHits, AppStrings.notAvailable),
                    (AppStrings.statBlocks, AppStrings.notAvailable),
                    (AppStrings.statGiveaways, AppStrings.notAvailable),
                    (AppStrings.statTakeaways, AppStrings.notAvailable),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          rows: topPlayers
              .map(
                (p) => [
                  p.name,
                  AppStrings.notAvailable,
                  '${counts.goalsByPlayer[p.playerId] ?? 0}',
                  '${counts.assistsByPlayer[p.playerId] ?? 0}',
                  AppStrings.notAvailable,
                ],
              )
              .toList(),
        ),
        Gaps.hXl,
        const _PlayerTable(
          title: AppStrings.statsGoalies,
          columns: [
            AppStrings.player,
            AppStrings.statsToi,
            AppStrings.statsSvPct,
            AppStrings.statSa,
            AppStrings.statGa,
          ],
          rows: [
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
}

class _KeyValueColumn extends StatelessWidget {
  const _KeyValueColumn({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (kv) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(child: Text(kv.$1, style: AppFonts.bodyRegular)),
                  Text(kv.$2, style: AppFonts.bodySemibold),
                ],
              ),
            ),
          )
          .toList(),
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

  @override
  Widget build(BuildContext context) {
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns
                  .map(
                    (c) => DataColumn(
                      label: Text(
                        c,
                        style: AppFonts.captionSemibold.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: rows
                  .map(
                    (r) => DataRow(
                      cells: r.map((v) => DataCell(Text(v))).toList(),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
