import 'dart:async';

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

class GameCenterRecapTab extends StatelessWidget {
  const GameCenterRecapTab({
    required this.header,
    required this.playByPlay,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;

  @override
  Widget build(BuildContext context) {
    final goals = playsFromPlayByPlay(
      playByPlay,
    ).where((p) => typeKey(p) == 'goal').toList();
    final byPeriod = scoreByPeriodFromGoals(header, goals);

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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RecapRow(
                label: AppStrings.specialTeams,
                value: AppStrings.notAvailable,
              ),
              Gaps.hMd,
              _RecapRow(
                label: AppStrings.highlightsSummary,
                value: AppStrings.notAvailable,
              ),
              Gaps.hMd,
              _RecapRow(
                label: AppStrings.firstGoal,
                value: AppStrings.notAvailable,
              ),
              Gaps.hMd,
              _RecapRow(
                label: AppStrings.gameWinningGoal,
                value: AppStrings.notAvailable,
              ),
              Gaps.hMd,
              _RecapRow(
                label: AppStrings.broadcasters,
                value: AppStrings.notAvailable,
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
  const _RecapRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
          ),
        ),
        Text(value, style: AppFonts.bodyRegular),
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

    return Table(
      border: TableBorder.all(color: AppColors.borderGray),
      columnWidths: const {
        0: FixedColumnWidth(72),
      },
      children: [
        TableRow(
          children: [
            const SizedBox(),
            for (final k in keys)
              Padding(
                padding: Insets.allSm,
                child: Text(
                  k,
                  style: AppFonts.captionSemibold.copyWith(
                    color: AppColors.textBlack,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        _teamRow(awayAbbrev, keys, (p) => byPeriod[p]?.away),
        _teamRow(homeAbbrev, keys, (p) => byPeriod[p]?.home),
      ],
    );
  }

  TableRow _teamRow(
    String team,
    List<String> keys,
    int? Function(String) valueOf,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: Insets.allSm,
          child: Text(team, style: AppFonts.bodyRegular),
        ),
        for (final k in keys)
          Padding(
            padding: Insets.allSm,
            child: Text(
              '${valueOf(k) ?? 0}',
              style: AppFonts.bodyRegular,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
