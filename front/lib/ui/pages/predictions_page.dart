import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/predictions_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';
import 'package:ice_line_tracker/ui/widgets/buttons/primary_button.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<PredictionsProvider>().loadNow());
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PredictionsProvider>();
    final state = provider.predictionsState;

    return Column(
      children: [
        Padding(
          padding: Insets.allLg,
          child: Column(
            children: [
              AppSegmentedControl<PredictionsDateFilter>(
                value: provider.date,
                onChanged: (v) => unawaited(_onDateChanged(context, v)),
                items: const [
                  AppSegmentedControlItem(
                    value: PredictionsDateFilter.today,
                    label: AppStrings.today,
                  ),
                  AppSegmentedControlItem(
                    value: PredictionsDateFilter.tomorrow,
                    label: AppStrings.tomorrow,
                  ),
                  AppSegmentedControlItem(
                    value: PredictionsDateFilter.custom,
                    label: AppStrings.custom,
                  ),
                ],
              ),
              Gaps.hMd,
              AppSegmentedControl<PredictionsScopeFilter>(
                value: provider.scope,
                onChanged: provider.setScopeFilter,
                items: const [
                  AppSegmentedControlItem(
                    value: PredictionsScopeFilter.all,
                    label: AppStrings.all,
                  ),
                  AppSegmentedControlItem(
                    value: PredictionsScopeFilter.myFavorites,
                    label: AppStrings.myFavorites,
                  ),
                  AppSegmentedControlItem(
                    value: PredictionsScopeFilter.keyMatchups,
                    label: AppStrings.keyMatchups,
                  ),
                ],
              ),
              Gaps.hMd,
              _TeamFilterDropdown(
                value: provider.teamAbbrev,
                onChanged: provider.setTeamAbbrev,
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (state) {
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            AsyncError() => Center(
              child: ElevatedButton(
                onPressed: () => unawaited(provider.refresh()),
                child: const Text(AppStrings.refresh),
              ),
            ),
            AsyncData(:final value) => _PredictionsList(predictions: value),
            _ => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }

  Future<void> _onDateChanged(
    BuildContext context,
    PredictionsDateFilter v,
  ) async {
    final provider = context.read<PredictionsProvider>();
    if (v != PredictionsDateFilter.custom) {
      provider.setDateFilter(v);
      return;
    }

    final initial =
        DateTime.tryParse(provider.customDateYyyyMmDd ?? '') ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 1),
    );
    if (picked == null || !context.mounted) return;

    provider
      ..setCustomDateYyyyMmDd(_toYyyyMmDd(picked))
      ..setDateFilter(PredictionsDateFilter.custom);
  }
}

class _TeamFilterDropdown extends StatelessWidget {
  const _TeamFilterDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);

  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    final standings = context.read<PredictionsProvider>().standingsCache;
    final teams =
        standings?.standings.map((r) => r.teamAbbrev.defaultName).toList()
          ?..sort();

    return Container(
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
              child: Text(AppStrings.filterByTeam),
            ),
            if (teams != null)
              ...teams.map(
                (t) => DropdownMenuItem<String?>(
                  value: t,
                  child: Text(t),
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PredictionsList extends StatelessWidget {
  const _PredictionsList({required this.predictions});

  final List<PredictionVm> predictions;

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    return ListView.separated(
      padding: Insets.allLg,
      itemCount: predictions.length,
      separatorBuilder: (context, index) => Gaps.hMd,
      itemBuilder: (context, index) {
        final p = predictions[index];
        return _PredictionCard(prediction: p);
      },
    );
  }
}

class _PredictionCard extends StatelessWidget {
  const _PredictionCard({required this.prediction});

  final PredictionVm prediction;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  @override
  Widget build(BuildContext context) {
    final g = prediction.game;
    final title = '${g.awayTeam.abbrev} @ ${g.homeTeam.abbrev}';
    final winLabel =
        '${AppStrings.projectedWinner} ${prediction.projectedWinnerAbbrev} '
        '(${prediction.projectedWinnerPct}%)';
    final totalLabel =
        '${AppStrings.expectedTotal} '
        '${prediction.expectedTotalGoals.toStringAsFixed(1)} goals';

    final confidenceLabel = switch (prediction.confidence) {
      PredictionConfidence.high => AppStrings.highConfidence,
      PredictionConfidence.moderate => AppStrings.moderateConfidence,
      PredictionConfidence.low => AppStrings.lowConfidence,
    };

    final confidenceColor = switch (prediction.confidence) {
      PredictionConfidence.high => AppColors.primaryRed,
      PredictionConfidence.moderate => AppColors.postponedOrange,
      PredictionConfidence.low => AppColors.borderGray,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => unawaited(_openDetails(context, prediction)),
        borderRadius: AppRadius.md,
        child: Container(
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
          padding: Insets.allLg,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prediction.dateLabel, style: AppFonts.caption),
                    Gaps.hXs,
                    Row(
                      children: [
                        _ConfidenceChip(
                          label: confidenceLabel,
                          color: confidenceColor,
                        ),
                        Gaps.wSm,
                        Expanded(
                          child: Text(
                            title,
                            style: AppFonts.bodySemibold.copyWith(
                              color: AppColors.textBlack,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Gaps.hSm,
                    Text(
                      winLabel,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text(
                      totalLabel,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Gaps.hSm,
                    Text(
                      '${AppStrings.form} ${prediction.formLast5Label}',
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      prediction.ppVsPkLabel,
                      style: Theme.of(context).textTheme.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Gaps.wMd,
              Column(
                children: [
                  CircularPercentIndicator(
                    radius: 32,
                    lineWidth: 6,
                    percent: (prediction.projectedWinnerPct / 100.0).clamp(
                      0.0,
                      1.0,
                    ),
                    center: Text(
                      '${prediction.projectedWinnerPct}%',
                      style: AppFonts.bodySemibold.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),
                    progressColor: AppColors.liveCyan,
                    backgroundColor: AppColors.borderGray,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  Gaps.hSm,
                  SvgPicture.asset(
                    AppIcons.chevronRight,
                    width: AppSizes.iconSm,
                    height: AppSizes.iconSm,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, PredictionVm vm) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceGray,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      builder: (context) => _PredictionDetails(prediction: vm),
    );
  }
}

class _PredictionDetails extends StatelessWidget {
  const _PredictionDetails({required this.prediction});

  final PredictionVm prediction;

  @override
  Widget build(BuildContext context) {
    final g = prediction.game;
    final title = '${g.awayTeam.abbrev} @ ${g.homeTeam.abbrev}';

    return SafeArea(
      child: SingleChildScrollView(
        padding: Insets.allLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: AppFonts.heading2),
            Gaps.hMd,
            Text(
              '${AppStrings.winProbability}\n'
              'Home: ${prediction.homeWinPct}%   '
              'Away: ${prediction.awayWinPct}%',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Gaps.hMd,
            const Text(AppStrings.keyFactors, style: AppFonts.bodySemibold),
            Gaps.hSm,
            const _Bullet(text: AppStrings.keyFactorRecentRecord),
            const _Bullet(text: AppStrings.keyFactorGoalDifferential),
            const _Bullet(text: AppStrings.keyFactorSpecialTeams),
            const _Bullet(text: AppStrings.keyFactorHeadToHead),
            Gaps.hMd,
            Text(
              AppStrings.predictionsDisclaimer,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Gaps.hLg,
            PrimaryButton(
              label: AppStrings.openGameCenter,
              onPressed: () {
                Navigator.of(context).pop();
                unawaited(
                  Navigator.of(context).pushNamed(
                    AppRoutes.gameCenter,
                    arguments: g,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: AppFonts.captionSemibold.copyWith(color: AppColors.textBlack),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _OutlinedPrimaryButton extends StatelessWidget {
  const _OutlinedPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.primaryButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryRed, width: 1.2),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.md),
          foregroundColor: AppColors.primaryRed,
          textStyle: AppFonts.bodySemibold.copyWith(
            color: AppColors.primaryRed,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

String _toYyyyMmDd(DateTime date) {
  final yyyy = date.year.toString().padLeft(4, '0');
  final mm = date.month.toString().padLeft(2, '0');
  final dd = date.day.toString().padLeft(2, '0');
  return '$yyyy-$mm-$dd';
}
