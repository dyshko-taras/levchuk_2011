import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/buttons/primary_button.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_models.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_parsers.dart';
import 'package:ice_line_tracker/utils/async_state.dart';

class GameCenterRecapTab extends StatelessWidget {
  const GameCenterRecapTab({
    required this.header,
    required this.playByPlay,
    required this.landing,
    required this.landingState,
    required this.onRetryLoadLanding,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;
  final Map<String, Object?>? landing;
  final AsyncState<Object?> landingState;
  final VoidCallback onRetryLoadLanding;

  @override
  Widget build(BuildContext context) {
    final goals = playsFromPlayByPlay(
      playByPlay,
    ).where((p) => typeKey(p) == 'goal').toList();
    final byPeriod = scoreByPeriodFromGoals(header, goals);

    final roster = rosterFromPlayByPlay(playByPlay);
    final recap = recapSummaryFrom(
      header: header,
      playByPlay: playByPlay,
      landing: landing,
      roster: roster,
    );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sidePadding,
        AppSpacing.md,
        AppSizes.sidePadding,
        AppSpacing.x2l,
      ),
      children: [
        Text(
          AppStrings.scoreByPeriod,
          style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
        ),
        Gaps.hMd,
        Container(
          decoration: cardDecoration(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: _ScoreByPeriodTable(
            awayAbbrev: header?.awayAbbrev ?? AppStrings.notAvailable,
            homeAbbrev: header?.homeAbbrev ?? AppStrings.notAvailable,
            byPeriod: byPeriod,
          ),
        ),
        Gaps.hXl,
        Container(
          decoration: cardDecoration(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (landingState.isLoading && landing == null)
                const Center(child: CircularProgressIndicator())
              else if (landingState.hasError && landing == null)
                Column(
                  children: [
                    const Text(AppStrings.splashInitFailed),
                    Gaps.hMd,
                    ElevatedButton(
                      onPressed: onRetryLoadLanding,
                      child: const Text(AppStrings.refresh),
                    ),
                  ],
                ),
              _RecapRow(
                label: AppStrings.specialTeams,
                value: recap.specialTeams,
                stackValue: true,
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.borderGray),
              _RecapRow(
                label: AppStrings.highlightsSummary,
                value: recap.highlights,
                stackValue: true,
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.borderGray),
              _RecapRow(
                label: AppStrings.firstGoal,
                value: recap.firstGoal,
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.borderGray),
              _RecapRow(
                label: AppStrings.gameWinningGoal,
                value: recap.gameWinningGoal,
              ),
              const Divider(height: AppSpacing.xl, color: AppColors.borderGray),
              _RecapRow(
                label: AppStrings.broadcasters,
                value: recap.broadcasters,
                stackValue: true,
              ),
            ],
          ),
        ),
        Gaps.h2Xl,
        PrimaryButton(
          label: AppStrings.share,
          onPressed: header == null ? null : () => unawaited(_share(header!)),
        ),
      ],
    );
  }

  Future<void> _share(GameCenterHeader header) async {
    final text =
        '${header.awayAbbrev} ${header.awayScore}–${header.homeScore} '
        '${header.homeAbbrev}';
    await Clipboard.setData(ClipboardData(text: text));
  }
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.label,
    required this.value,
    this.stackValue = false,
  });

  final String label;
  final String value;
  final bool stackValue;

  static const int _stackThreshold = 24;

  @override
  Widget build(BuildContext context) {
    final normalized = value == AppStrings.notAvailable ? '-' : value;
    final shouldStack = stackValue || normalized.length > _stackThreshold;

    if (shouldStack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
          ),
          Gaps.hXs,
          Text(normalized, style: AppFonts.bodyRegular),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
          ),
        ),
        Text(normalized, style: AppFonts.bodyRegular),
      ],
    );
  }
}

class _ScoreByPeriodTable extends StatelessWidget {
  const _ScoreByPeriodTable({
    required this.awayAbbrev,
    required this.homeAbbrev,
    required this.byPeriod,
  });

  final String awayAbbrev;
  final String homeAbbrev;
  final Map<String, ({int away, int home})> byPeriod;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', 'OT', 'SO'];

    const headingRowHeight = 34.0;
    const dataRowHeight = 38.0;
    const extraHeight = 2.0;
    const rowsCount = 2;
    const tableHeight =
        headingRowHeight + (dataRowHeight * rowsCount) + extraHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        const teamColumnWidth = 96.0;
        const periodColumnWidth = 48.0;
        final tableWidth =
            teamColumnWidth +
            (keys.length * periodColumnWidth) +
            (keys.length * AppSpacing.sm) +
            (AppSpacing.sm * 2);

        return SizedBox(
          height: tableHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: tableWidth,
                child: DataTable2(
                  minWidth: tableWidth,
                  columnSpacing: AppSpacing.sm,
                  horizontalMargin: AppSpacing.sm,
                  headingRowHeight: headingRowHeight,
                  dataRowHeight: dataRowHeight,
                  border: TableBorder.all(color: AppColors.borderGray),
                  headingTextStyle: AppFonts.captionSemibold.copyWith(
                    color: AppColors.textBlack,
                  ),
                  columns: [
                    const DataColumn2(
                      label: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(AppStrings.teamTitle),
                      ),
                      fixedWidth: teamColumnWidth,
                    ),
                    for (final k in keys)
                      DataColumn2(
                        label: Center(child: Text(k)),
                        numeric: true,
                        fixedWidth: periodColumnWidth,
                      ),
                  ],
                  rows: [
                    _teamRow(awayAbbrev, keys, (p) => byPeriod[p]?.away),
                    _teamRow(homeAbbrev, keys, (p) => byPeriod[p]?.home),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow2 _teamRow(
    String team,
    List<String> keys,
    int? Function(String) valueOf,
  ) {
    return DataRow2(
      cells: [
        DataCell(Text(team, style: AppFonts.bodyRegular)),
        for (final k in keys)
          DataCell(
            Center(
              child: Text(
                '${valueOf(k) ?? 0}',
                style: AppFonts.bodyRegular,
              ),
            ),
          ),
      ],
    );
  }
}
