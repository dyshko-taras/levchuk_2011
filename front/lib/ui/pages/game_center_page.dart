import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/providers/game_center_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/widgets/common/game_card.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_events_tab.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_models.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_parsers.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_recap_tab.dart';
import 'package:ice_line_tracker/ui/widgets/game_center/game_center_stats_tab.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

class GameCenterPage extends StatefulWidget {
  const GameCenterPage({super.key});

  @override
  State<GameCenterPage> createState() => _GameCenterPageState();
}

class _GameCenterPageState extends State<GameCenterPage> {
  int? _gameId;
  NhlScheduledGame? _game;

  GameCenterTab _tab = GameCenterTab.plays;
  PlaysFilter _playsFilter = PlaysFilter.goals;
  GoalsSubtab _goalsSubtab = GoalsSubtab.goals;
  StatsSegment _statsSegment = StatsSegment.home;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;
    int? gameId;
    NhlScheduledGame? game;
    if (arg is int) {
      gameId = arg;
    } else if (arg is String) {
      gameId = int.tryParse(arg);
    } else if (arg is NhlScheduledGame) {
      game = arg;
      gameId = arg.id;
    }
    if (gameId == null || _gameId == gameId) return;
    _gameId = gameId;
    _game = game;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<GameCenterProvider>().loadGame(gameId!));
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameId = _gameId;
    if (gameId == null) {
      return const Scaffold(
        body: Center(child: Text(AppStrings.notAvailable)),
      );
    }

    final gameCenter = context.watch<GameCenterProvider>();
    final pbpState = gameCenter.playByPlayState;
    final pbp = asMap(pbpState.valueOrNull);

    final landingState = gameCenter.landingState;
    final landing = asMap(landingState.valueOrNull);

    final boxscoreState = gameCenter.boxscoreState;
    final boxscore = asMap(boxscoreState.valueOrNull);

    final header = parseHeaderFromPlayByPlay(pbp);

    return Scaffold(
      appBar: AppBar(
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
        title: const Text(AppStrings.liveScoresTitle),
        actions: [
          IconButton(
            onPressed: header == null ? null : () => unawaited(_share(header)),
            tooltip: AppStrings.share,
            icon: SvgPicture.asset(
              AppIcons.share,
              colorFilter: const ColorFilter.mode(
                AppColors.textBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.sidePadding,
                AppSpacing.md,
                AppSizes.sidePadding,
                AppSpacing.md,
              ),
              child: _game == null
                  ? Container(
                      height: 164,
                      decoration: cardDecoration(),
                      child: pbpState.isLoading && pbp == null
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : pbpState.hasError && pbp == null
                          ? Center(
                              child: ElevatedButton(
                                onPressed: () =>
                                    unawaited(gameCenter.loadGame(gameId)),
                                child: const Text(AppStrings.refresh),
                              ),
                            )
                          : const SizedBox.shrink(),
                    )
                  : GameCard(
                      game: _game!,
                      enableNavigation: false,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sidePadding,
              ),
              child: AppSegmentedControl<GameCenterTab>(
                items: const [
                  AppSegmentedControlItem(
                    value: GameCenterTab.plays,
                    label: AppStrings.tabPlays,
                  ),
                  AppSegmentedControlItem(
                    value: GameCenterTab.goals,
                    label: AppStrings.tabGoals,
                  ),
                  AppSegmentedControlItem(
                    value: GameCenterTab.penalties,
                    label: AppStrings.tabPenalties,
                  ),
                  AppSegmentedControlItem(
                    value: GameCenterTab.stats,
                    label: AppStrings.tabStats,
                  ),
                  AppSegmentedControlItem(
                    value: GameCenterTab.recap,
                    label: AppStrings.tabRecap,
                  ),
                ],
                value: _tab,
                onChanged: (t) {
                  setState(() => _tab = t);
                  _ensureTabData(gameCenter, t);
                },
              ),
            ),
            Gaps.hLg,
            Expanded(
              child: RefreshIndicator(
                onRefresh: gameCenter.refreshAll,
                child: switch (_tab) {
                  GameCenterTab.plays => GameCenterPlaysTab(
                    header: header,
                    playByPlay: pbp,
                    filter: _playsFilter,
                    onFilterChanged: (v) => setState(() => _playsFilter = v),
                  ),
                  GameCenterTab.goals => GameCenterGoalsTab(
                    header: header,
                    playByPlay: pbp,
                    subtab: _goalsSubtab,
                    onSubtabChanged: (v) => setState(() => _goalsSubtab = v),
                  ),
                  GameCenterTab.penalties => GameCenterPenaltiesTab(
                    header: header,
                    playByPlay: pbp,
                  ),
                  GameCenterTab.stats => GameCenterStatsTab(
                    header: header,
                    playByPlay: pbp,
                    boxscore: boxscore,
                    boxscoreState: boxscoreState,
                    onRetryLoadBoxscore: () {
                      unawaited(
                        gameCenter.ensureBoxscore(forceRefresh: true),
                      );
                    },
                    segment: _statsSegment,
                    onSegmentChanged: (v) => setState(() => _statsSegment = v),
                  ),
                  GameCenterTab.recap => GameCenterRecapTab(
                    header: header,
                    playByPlay: pbp,
                    landing: landing,
                    landingState: landingState,
                    onRetryLoadLanding: () =>
                        unawaited(gameCenter.ensureLanding(forceRefresh: true)),
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _ensureTabData(GameCenterProvider provider, GameCenterTab tab) {
    switch (tab) {
      case GameCenterTab.plays:
      case GameCenterTab.goals:
      case GameCenterTab.penalties:
        unawaited(provider.ensurePlayByPlay());
      case GameCenterTab.stats:
        unawaited(provider.ensurePlayByPlay());
        unawaited(provider.ensureBoxscore());
      case GameCenterTab.recap:
        unawaited(provider.ensurePlayByPlay());
        unawaited(provider.ensureLanding());
    }
  }

  Future<void> _share(GameCenterHeader header) async {
    final text =
        '${header.awayAbbrev} ${header.awayScore}–${header.homeScore} '
        '${header.homeAbbrev}';
    await Clipboard.setData(ClipboardData(text: text));
  }
}
