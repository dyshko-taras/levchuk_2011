import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/team_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}


class _TeamPageState extends State<TeamPage> {
  String? _teamAbbrev;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;
    final teamAbbrev = switch (arg) {
      String() => arg,
      _ => null,
    };
    if (teamAbbrev == null || teamAbbrev == _teamAbbrev) return;
    _teamAbbrev = teamAbbrev;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<TeamProvider>().loadCurrent(teamAbbrev));
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamAbbrev = _teamAbbrev;
    if (teamAbbrev == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.notAvailable)),
      );
    }

    final provider = context.watch<TeamProvider>();
    final rosterState = provider.rosterState;
    final statsState = provider.clubStatsState;

    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.teamTitle}: $teamAbbrev'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: SvgPicture.asset(
            AppIcons.back,
            colorFilter: const ColorFilter.mode(
              AppColors.textBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.sidePadding,
          AppSpacing.md,
          AppSizes.sidePadding,
          AppSpacing.x2l,
        ),
        children: [
          _StateCard(
            title: 'Roster',
            state: rosterState,
            onRetry: () => unawaited(provider.loadRosterCurrent(teamAbbrev)),
          ),
          Gaps.hXl,
          _StateCard(
            title: 'Club stats',
            state: statsState,
            onRetry: () => unawaited(provider.loadClubStatsNow(teamAbbrev)),
          ),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.state,
    required this.onRetry,
  });

  final String title;
  final AsyncState<Object?> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final value = state.valueOrNull;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33000000), width: 0.66),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1.32),
            blurRadius: 1.32,
          ),
        ],
      ),
      padding: Insets.allLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Gaps.hMd,
          if (state.isLoading && value == null)
            const Center(child: CircularProgressIndicator())
          else if (state.hasError && value == null)
            Row(
              children: [
                const Expanded(child: Text(AppStrings.splashInitFailed)),
                TextButton(
                  onPressed: onRetry,
                  child: const Text(AppStrings.refresh),
                ),
              ],
            )
          else
            Text(
              value == null ? AppStrings.notAvailable : 'Loaded',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }
}
