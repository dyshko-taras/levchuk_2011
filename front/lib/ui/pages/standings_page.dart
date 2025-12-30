import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/models/nhl_standings_response.dart';
import 'package:ice_line_tracker/providers/standings_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

class StandingsPage extends StatefulWidget {
  const StandingsPage({super.key});

  @override
  State<StandingsPage> createState() => _StandingsPageState();
}

class _StandingsPageState extends State<StandingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<StandingsProvider>();
      if (provider.state is AsyncEmpty<NhlStandingsResponse>) {
        unawaited(provider.loadNow());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final standings = context.watch<StandingsProvider>();
    final scope = standings.scope;
    final state = standings.state;
    final data = state.valueOrNull;

    final groups =
        data == null ? const <_StandingsGroup>[] : _groupsFor(data, scope);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.sidePadding,
        AppSpacing.md,
        AppSizes.sidePadding,
        AppSpacing.x2l,
      ),
      child: Column(
        children: [
          AppSegmentedControl<StandingsScope>(
            items: const [
              AppSegmentedControlItem(
                value: StandingsScope.wildCard,
                label: AppStrings.standingsWildCard,
              ),
              AppSegmentedControlItem(
                value: StandingsScope.league,
                label: AppStrings.standingsLeague,
              ),
              AppSegmentedControlItem(
                value: StandingsScope.division,
                label: AppStrings.standingsDivision,
              ),
            ],
            value: scope,
            onChanged: standings.setScope,
          ),
          Gaps.hXl,
          Expanded(
            child: _StandingsCard(
              scope: scope,
              state: state,
              groups: groups,
              onRefresh: standings.refresh,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsCard extends StatelessWidget {
  const _StandingsCard({
    required this.scope,
    required this.state,
    required this.groups,
    required this.onRefresh,
  });

  final StandingsScope scope;
  final AsyncState<NhlStandingsResponse> state;
  final List<_StandingsGroup> groups;
  final Future<void> Function() onRefresh;

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
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isLoading && groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError && groups.isEmpty) {
      return Center(
        child: Padding(
          padding: Insets.allXl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(AppStrings.splashInitFailed),
              Gaps.hLg,
              ElevatedButton(
                onPressed: () => unawaited(onRefresh()),
                child: const Text(AppStrings.refresh),
              ),
            ],
          ),
        ),
      );
    }
    if (groups.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    return _StandingsTable(
      scope: scope,
      groups: groups,
      onRefresh: onRefresh,
    );
  }
}

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({
    required this.scope,
    required this.groups,
    required this.onRefresh,
  });

  final StandingsScope scope;
  final List<_StandingsGroup> groups;
  final Future<void> Function() onRefresh;

  static const double _posWidth = 56;
  static const double _teamWidth = 220;
  static const double _gpwlWidth = 120;
  static const double _ptsWidth = 64;
  static const double _gfgaDiffWidth = 136;
  static const double _l10Width = 88;
  static const double _streakWidth = 88;

  static const double _tableRowHeight = 44;
  static const double _headerRowHeight = 42;
  static const double _sectionHeaderHeight = 40;

  double get _tableWidth =>
      _posWidth +
      _teamWidth +
      _gpwlWidth +
      _ptsWidth +
      _gfgaDiffWidth +
      _l10Width +
      _streakWidth +
      (AppSpacing.md * 2);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _tableWidth,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeaderDelegate(
                  height: _headerRowHeight,
                  child: _HeaderRow(
                    height: _headerRowHeight,
                    scope: scope,
                  ),
                ),
              ),
              for (final group in groups) ...[
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedHeaderDelegate(
                    height: _sectionHeaderHeight,
                    child: _SectionHeader(
                      height: _sectionHeaderHeight,
                      title: group.title,
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: group.rows.length,
                  itemBuilder: (context, index) {
                    final row = group.rows[index];
                    return _StandingRow(
                      scope: scope,
                      height: _tableRowHeight,
                      pos: index + 1,
                      row: row,
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.height,
    required this.scope,
  });

  final double height;
  final StandingsScope scope;

  static const double _posWidth = _StandingsTable._posWidth;
  static const double _teamWidth = _StandingsTable._teamWidth;
  static const double _gpwlWidth = _StandingsTable._gpwlWidth;
  static const double _ptsWidth = _StandingsTable._ptsWidth;
  static const double _gfgaDiffWidth = _StandingsTable._gfgaDiffWidth;
  static const double _l10Width = _StandingsTable._l10Width;
  static const double _streakWidth = _StandingsTable._streakWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              _cell(AppStrings.standingsColPos, width: _posWidth),
              _cell(AppStrings.standingsColTeam, width: _teamWidth),
              _cell(AppStrings.standingsColGpWlOtl, width: _gpwlWidth),
              _cell(AppStrings.standingsColPts, width: _ptsWidth),
              _cell(AppStrings.standingsColGfGaDiff, width: _gfgaDiffWidth),
              _cell(AppStrings.standingsColL10, width: _l10Width),
              _cell(AppStrings.standingsColStreak, width: _streakWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppFonts.captionSemibold.copyWith(color: AppColors.textBlack),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.height,
    required this.title,
  });

  final double height;
  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surfaceGray,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGray),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: AppFonts.bodySemibold.copyWith(color: AppColors.textBlack),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.scope,
    required this.height,
    required this.pos,
    required this.row,
  });

  final StandingsScope scope;
  final double height;
  final int pos;
  final NhlStandingRow row;

  static const double _posWidth = _StandingsTable._posWidth;
  static const double _teamWidth = _StandingsTable._teamWidth;
  static const double _gpwlWidth = _StandingsTable._gpwlWidth;
  static const double _ptsWidth = _StandingsTable._ptsWidth;
  static const double _gfgaDiffWidth = _StandingsTable._gfgaDiffWidth;
  static const double _l10Width = _StandingsTable._l10Width;
  static const double _streakWidth = _StandingsTable._streakWidth;

  static const double _logoSize = 22;

  bool get _isWildCardHighlighted =>
      scope == StandingsScope.wildCard &&
      (row.wildcardSequence == 1 || row.wildcardSequence == 2);

  @override
  Widget build(BuildContext context) {
    final gpwl =
        '${row.gamesPlayed},${row.wins},${row.losses},${row.otLosses}';
    final gfgaDiff =
        '${row.goalFor},${row.goalAgainst},${row.goalDifferential}';
    final l10 = '${row.l10Wins}-${row.l10Losses}-${row.l10OtLosses}';
    final streak = '${row.streakCode}${row.streakCount}';

    return Material(
      color: _isWildCardHighlighted
          ? AppColors.primaryRed.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () {
          unawaited(
            Navigator.of(context).pushNamed(
              AppRoutes.team,
              arguments: row.teamAbbrev.defaultName,
            ),
          );
        },
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _textCell('$pos', width: _posWidth),
                SizedBox(
                  width: _teamWidth,
                  child: Row(
                    children: [
                      SvgPicture.network(
                        row.teamLogo,
                        width: _logoSize,
                        height: _logoSize,
                      ),
                      Gaps.wSm,
                      Expanded(
                        child: Text(
                          row.teamCommonName.defaultName,
                          style: AppFonts.bodyRegular,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                _textCell(gpwl, width: _gpwlWidth),
                _textCell('${row.points}', width: _ptsWidth),
                _textCell(gfgaDiff, width: _gfgaDiffWidth),
                _textCell(l10, width: _l10Width),
                _textCell(streak, width: _streakWidth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textCell(
    String text, {
    required double width,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: AppFonts.bodyRegular,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

class _StandingsGroup {
  const _StandingsGroup({
    required this.title,
    required this.rows,
  });

  final String title;
  final List<NhlStandingRow> rows;
}

List<_StandingsGroup> _groupsFor(
  NhlStandingsResponse data,
  StandingsScope scope,
) {
  final rows = data.standings;

  int cmpInt(int a, int b) => a.compareTo(b);
  int cmpIntDesc(int a, int b) => b.compareTo(a);

  int wildcardSort(NhlStandingRow a, NhlStandingRow b) {
    final wc = cmpInt(a.wildcardSequence, b.wildcardSequence);
    if (wc != 0) return wc;
    final pts = cmpIntDesc(a.points, b.points);
    if (pts != 0) return pts;
    return cmpIntDesc(a.regulationPlusOtWins, b.regulationPlusOtWins);
  }

  int leagueSort(NhlStandingRow a, NhlStandingRow b) {
    final pts = cmpIntDesc(a.points, b.points);
    if (pts != 0) return pts;
    final r = cmpIntDesc(a.regulationPlusOtWins, b.regulationPlusOtWins);
    if (r != 0) return r;
    return cmpIntDesc(a.goalDifferential, b.goalDifferential);
  }

  int divisionSort(NhlStandingRow a, NhlStandingRow b) {
    final pts = cmpIntDesc(a.points, b.points);
    if (pts != 0) return pts;
    return cmpIntDesc(a.regulationPlusOtWins, b.regulationPlusOtWins);
  }

  Map<String, List<NhlStandingRow>> groupByKey(
    String Function(NhlStandingRow) keyOf,
  ) {
    final map = <String, List<NhlStandingRow>>{};
    for (final r in rows) {
      final k = keyOf(r);
      (map[k] ??= <NhlStandingRow>[]).add(r);
    }
    return map;
  }

  final groups = <_StandingsGroup>[];

  if (scope == StandingsScope.division) {
    final byDivision = groupByKey((r) => r.divisionName);
    final keys = byDivision.keys.toList()..sort();
    for (final k in keys) {
      final list = byDivision[k]!..sort(divisionSort);
      final conference = list.isEmpty ? '' : list.first.conferenceName;
      groups.add(_StandingsGroup(title: '$k / $conference', rows: list));
    }
    return groups;
  }

  final byConference = groupByKey((r) => r.conferenceName);
  final confKeys = byConference.keys.toList()..sort();
  for (final k in confKeys) {
    final list = byConference[k]!
      ..sort(scope == StandingsScope.wildCard ? wildcardSort : leagueSort);
    groups.add(_StandingsGroup(title: k, rows: list));
  }
  return groups;
}
