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

class GameCenterPlaysTab extends StatelessWidget {
  const GameCenterPlaysTab({
    required this.header,
    required this.playByPlay,
    required this.filter,
    required this.onFilterChanged,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;
  final PlaysFilter filter;
  final ValueChanged<PlaysFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final plays = playsFromPlayByPlay(playByPlay);
    final roster = rosterFromPlayByPlay(playByPlay);
    final filtered = plays.where((p) => matchesPlaysFilter(p, filter)).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sidePadding,
        AppSpacing.md,
        AppSizes.sidePadding,
        AppSpacing.x2l,
      ),
      children: [
        AppSegmentedControl<PlaysFilter>(
          items: const [
            AppSegmentedControlItem(
              value: PlaysFilter.goals,
              label: AppStrings.subtabGoals,
            ),
            AppSegmentedControlItem(
              value: PlaysFilter.shots,
              label: AppStrings.subtabShots,
            ),
            AppSegmentedControlItem(
              value: PlaysFilter.hits,
              label: AppStrings.subtabHits,
            ),
            AppSegmentedControlItem(
              value: PlaysFilter.penalties,
              label: AppStrings.tabPenalties,
            ),
            AppSegmentedControlItem(
              value: PlaysFilter.faceoffs,
              label: AppStrings.faceoffs,
            ),
          ],
          value: filter,
          onChanged: onFilterChanged,
        ),
        Gaps.hXl,
        if (filtered.isEmpty)
          const Center(
            child: Padding(
              padding: Insets.vXl,
              child: Text(AppStrings.noEvents),
            ),
          )
        else
          ...filtered.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _PlayCard(
                header: header,
                play: p,
                roster: roster,
              ),
            ),
          ),
      ],
    );
  }
}

class GameCenterGoalsTab extends StatelessWidget {
  const GameCenterGoalsTab({
    required this.header,
    required this.playByPlay,
    required this.subtab,
    required this.onSubtabChanged,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;
  final GoalsSubtab subtab;
  final ValueChanged<GoalsSubtab> onSubtabChanged;

  @override
  Widget build(BuildContext context) {
    final plays = playsFromPlayByPlay(playByPlay);
    final roster = rosterFromPlayByPlay(playByPlay);

    final filtered = switch (subtab) {
      GoalsSubtab.goals => plays.where((p) => typeKey(p) == 'goal').toList(),
      GoalsSubtab.shots => plays.where(isShot).toList(),
      GoalsSubtab.hits => plays.where((p) => typeKey(p) == 'hit').toList(),
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
        AppSegmentedControl<GoalsSubtab>(
          items: const [
            AppSegmentedControlItem(
              value: GoalsSubtab.goals,
              label: AppStrings.subtabGoals,
            ),
            AppSegmentedControlItem(
              value: GoalsSubtab.shots,
              label: AppStrings.subtabShots,
            ),
            AppSegmentedControlItem(
              value: GoalsSubtab.hits,
              label: AppStrings.subtabHits,
            ),
          ],
          value: subtab,
          onChanged: onSubtabChanged,
        ),
        Gaps.hXl,
        if (filtered.isEmpty)
          const Center(
            child: Padding(
              padding: Insets.vXl,
              child: Text(AppStrings.noEvents),
            ),
          )
        else
          ...filtered.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: subtab == GoalsSubtab.goals
                  ? _GoalCard(header: header, play: p, roster: roster)
                  : _PlayCard(header: header, play: p, roster: roster),
            ),
          ),
      ],
    );
  }
}

class GameCenterPenaltiesTab extends StatelessWidget {
  const GameCenterPenaltiesTab({
    required this.header,
    required this.playByPlay,
    super.key,
  });

  final GameCenterHeader? header;
  final Map<String, Object?>? playByPlay;

  @override
  Widget build(BuildContext context) {
    final plays = playsFromPlayByPlay(
      playByPlay,
    ).where((p) => typeKey(p) == 'penalty').toList();
    final roster = rosterFromPlayByPlay(playByPlay);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sidePadding,
        AppSpacing.md,
        AppSizes.sidePadding,
        AppSpacing.x2l,
      ),
      children: [
        if (plays.isEmpty)
          const Center(
            child: Padding(
              padding: Insets.vXl,
              child: Text(AppStrings.noEvents),
            ),
          )
        else
          ...plays.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _PenaltyCard(header: header, play: p, roster: roster),
            ),
          ),
      ],
    );
  }
}

class _PlayCard extends StatelessWidget {
  const _PlayCard({
    required this.header,
    required this.play,
    required this.roster,
  });

  final GameCenterHeader? header;
  final Map<String, Object?> play;
  final Map<int, RosterPlayer> roster;

  @override
  Widget build(BuildContext context) {
    final time = playTimeLabel(play);
    final score = playScoreLabel(header, play);
    final title = playTitle(play);
    final subtitle = playSubtitle(play, roster);

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(time, style: AppFonts.captionSemibold),
              const Spacer(),
              if (score != null)
                Text(
                  score,
                  style: AppFonts.bodySemibold.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
            ],
          ),
          Gaps.hSm,
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          if (subtitle != null) ...[
            Gaps.hXs,
            Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.header,
    required this.play,
    required this.roster,
  });

  final GameCenterHeader? header;
  final Map<String, Object?> play;
  final Map<int, RosterPlayer> roster;

  @override
  Widget build(BuildContext context) {
    final details = asMap(play['details']);
    final time = playTimeLabel(play);
    final score = playScoreLabel(header, play) ?? '';
    final strength = goalStrength(details);

    final scorerId = asInt(details?['scoringPlayerId']);
    final assist1Id = asInt(details?['assist1PlayerId']);
    final assist2Id = asInt(details?['assist2PlayerId']);

    final scorer = scorerId == null ? null : roster[scorerId]?.name;
    final a1 = assist1Id == null ? null : roster[assist1Id]?.name;
    final a2 = assist2Id == null ? null : roster[assist2Id]?.name;

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _StrengthBadge(label: strength),
          Gaps.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scorer ?? AppStrings.notAvailable,
                  style: AppFonts.bodySemibold.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                if (a1 != null) Text('$a1 (A1)', style: AppFonts.bodyRegular),
                if (a2 != null) Text('$a2 (A2)', style: AppFonts.bodyRegular),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: AppFonts.captionSemibold),
              Gaps.hXs,
              Text(
                score,
                style: AppFonts.bodySemibold.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StrengthBadge extends StatelessWidget {
  const _StrengthBadge({required this.label});

  final String label;

  static const double _size = 32;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: const BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: AppRadius.md,
      ),
      child: Center(
        child: Text(
          label,
          style: AppFonts.captionSemibold.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _PenaltyCard extends StatelessWidget {
  const _PenaltyCard({
    required this.header,
    required this.play,
    required this.roster,
  });

  final GameCenterHeader? header;
  final Map<String, Object?> play;
  final Map<int, RosterPlayer> roster;

  @override
  Widget build(BuildContext context) {
    final details = asMap(play['details']);
    final time = playTimeLabel(play);

    final descKey = asString(details?['descKey']);
    final label = descKey == null
        ? AppStrings.tabPenalties
        : titleCase(descKey);

    final minutes = asInt(details?['duration']);
    final minutesLabel = minutes == null
        ? AppStrings.notAvailable
        : '$minutes min';

    final playerId = asInt(details?['committedByPlayerId']);
    final player = playerId == null ? null : roster[playerId]?.name;

    final teamId = asInt(details?['eventOwnerTeamId']);
    final teamAbbrev =
        header?.abbrevForTeamId(teamId) ?? AppStrings.notAvailable;

    return Container(
      decoration: cardDecoration(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.bodySemibold.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                Gaps.hXs,
                Text(teamAbbrev, style: AppFonts.bodyRegular),
                if (player != null) Text(player, style: AppFonts.bodyRegular),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: AppFonts.captionSemibold),
              Gaps.hXs,
              Text(
                minutesLabel,
                style: AppFonts.bodySemibold.copyWith(
                  color: AppColors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
