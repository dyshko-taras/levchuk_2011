import 'dart:async';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/favorites_provider.dart';
import 'package:ice_line_tracker/providers/team_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/buttons/primary_button.dart';
import 'package:ice_line_tracker/ui/widgets/fields/app_segmented_control.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

enum _TeamTab { roster, schedule, stats }

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});

  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  String? _teamAbbrev;
  _TeamTab _tab = _TeamTab.roster;

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
      return const Scaffold(body: Center(child: Text(AppStrings.notAvailable)));
    }

    final provider = context.watch<TeamProvider>();
    final favorites = context.watch<FavoritesProvider>();

    final meta = provider.metaState.valueOrNull;
    final title = meta?.name ?? AppStrings.teamTitle;
    final isFavorite = favorites.isFavoriteTeam(teamAbbrev);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.sidePadding,
          AppSpacing.md,
          AppSizes.sidePadding,
          AppSpacing.x2l,
        ),
        child: Column(
          children: [
            _TeamHeaderCard(
              metaState: provider.metaState,
              scheduleState: provider.scheduleState,
              isFavorite: isFavorite,
              onToggleFavorite: () =>
                  unawaited(favorites.toggleFavoriteTeam(teamAbbrev)),
            ),
            Gaps.hXl,
            AppSegmentedControl<_TeamTab>(
              items: const [
                AppSegmentedControlItem(
                  value: _TeamTab.roster,
                  label: AppStrings.tabRoster,
                ),
                AppSegmentedControlItem(
                  value: _TeamTab.schedule,
                  label: AppStrings.tabSchedule,
                ),
                AppSegmentedControlItem(
                  value: _TeamTab.stats,
                  label: AppStrings.tabTeamStats,
                ),
              ],
              value: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
            Gaps.hXl,
            Expanded(
              child: switch (_tab) {
                _TeamTab.roster => _RosterTab(
                  state: provider.rosterState,
                  onRetry: () {
                    unawaited(provider.loadRosterCurrent(teamAbbrev));
                  },
                ),
                _TeamTab.schedule => _ScheduleTab(
                  teamAbbrev: teamAbbrev,
                  state: provider.scheduleState,
                  onRetry: () =>
                      unawaited(provider.loadScheduleSeasonNow(teamAbbrev)),
                ),
                _TeamTab.stats => _TeamStatsTab(
                  metaState: provider.metaState,
                  onHighlightUpcoming: () {
                    setState(() => _tab = _TeamTab.schedule);
                  },
                ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamHeaderCard extends StatelessWidget {
  const _TeamHeaderCard({
    required this.metaState,
    required this.scheduleState,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final AsyncState<TeamMeta> metaState;
  final AsyncState<Object?> scheduleState;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  static const double _logoSize = 64;

  @override
  Widget build(BuildContext context) {
    final meta = metaState.valueOrNull;
    final arena =
        _arenaFromSchedule(scheduleState.valueOrNull, meta?.teamAbbrev);

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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (metaState.isLoading && meta == null)
            const SizedBox(
              width: _logoSize,
              height: _logoSize,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (meta == null)
            const SizedBox(
              width: _logoSize,
              height: _logoSize,
              child: Center(child: Text(AppStrings.notAvailable)),
            )
          else
            SvgPicture.network(
              meta.logoUrl,
              width: _logoSize,
              height: _logoSize,
            ),
          Gaps.wMd,
          Expanded(
            child: meta == null
                ? const SizedBox.shrink()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.name,
                        style: AppFonts.bodySemibold.copyWith(
                          color: AppColors.textBlack,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${meta.divisionName} / ${meta.conferenceName}',
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        arena,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          _SquareIconButton(
            iconPath: isFavorite ? AppIcons.starFilled : AppIcons.starOutline,
            onPressed: onToggleFavorite,
          ),
        ],
      ),
    );
  }

  static String _arenaFromSchedule(Object? schedule, String? teamAbbrev) {
    if (schedule is! Map || teamAbbrev == null) return AppStrings.notAvailable;
    final games = schedule['games'];
    if (games is! List) return AppStrings.notAvailable;

    for (final g in games) {
      if (g is! Map) continue;
      final home = g['homeTeam'];
      if (home is! Map) continue;
      final abbrev = home['abbrev'];
      if (abbrev == teamAbbrev) {
        final venue = g['venue'];
        if (venue is Map) {
          final v = venue['default'];
          if (v is String && v.isNotEmpty) return v;
        }
      }
    }

    return AppStrings.notAvailable;
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.iconPath,
    required this.onPressed,
  });

  final String iconPath;
  final VoidCallback onPressed;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: AppColors.borderGray,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: SvgPicture.asset(
              iconPath,
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              colorFilter: const ColorFilter.mode(
                AppColors.textBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RosterTab extends StatelessWidget {
  const _RosterTab({
    required this.state,
    required this.onRetry,
  });

  final AsyncState<Object?> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final roster = _parseRoster(state.valueOrNull);
    if (state.isLoading && roster.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError && roster.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: onRetry,
          child: const Text(AppStrings.refresh),
        ),
      );
    }

    if (roster.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    return _TableCard(
      child: _RosterTable(rows: roster),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.teamAbbrev,
    required this.state,
    required this.onRetry,
  });

  final String teamAbbrev;
  final AsyncState<Object?> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final schedule = _parseSchedule(
      state.valueOrNull,
      teamAbbrev: teamAbbrev,
    );

    if (state.isLoading && schedule.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError && schedule.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: onRetry,
          child: const Text(AppStrings.refresh),
        ),
      );
    }

    if (schedule.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    return _TableCard(
      child: _ScheduleTable(rows: schedule),
    );
  }
}

class _TeamStatsTab extends StatelessWidget {
  const _TeamStatsTab({
    required this.metaState,
    required this.onHighlightUpcoming,
  });

  final AsyncState<TeamMeta> metaState;
  final VoidCallback onHighlightUpcoming;

  @override
  Widget build(BuildContext context) {
    final meta = metaState.valueOrNull;
    if (metaState.isLoading && meta == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (metaState.hasError && meta == null) {
      return const Center(child: Text(AppStrings.splashInitFailed));
    }
    if (meta == null) return const Center(child: Text(AppStrings.notAvailable));

    final row = meta.standingRow;
    final last10 = '${row.l10Wins}-${row.l10Losses}-${row.l10OtLosses}';
    final gfga = '${row.goalFor}-${row.goalAgainst}';
    final record = '${row.wins}-${row.losses}-${row.otLosses}';

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              _TableCard(
                child: _TeamStatsTable(
                  last10: last10,
                  gfga: gfga,
                  record: record,
                ),
              ),
            ],
          ),
        ),
        PrimaryButton(
          label: AppStrings.teamHighlightUpcoming,
          onPressed: onHighlightUpcoming,
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.child});

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

class _RosterRowVm {
  const _RosterRowVm({
    required this.number,
    required this.playerId,
    required this.pos,
    required this.name,
    required this.line,
  });

  final String number;
  final int playerId;
  final String pos;
  final String name;
  final String line;
}

class _RosterTable extends StatelessWidget {
  const _RosterTable({
    required this.rows,
  });

  final List<_RosterRowVm> rows;

  static const _headingRowHeight = 40.0;
  static const _dataRowHeight = 44.0;

  static const _numWidth = 56.0;
  static const _posWidth = 64.0;
  static const _nameMinWidth = 220.0;
  static const _lineWidth = 64.0;
  static const double _colSpacing = AppSpacing.md;
  static const double _marginH = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final height = _headingRowHeight + (_dataRowHeight * rows.length) + 2;
    const width =
        _numWidth +
        _posWidth +
        _nameMinWidth +
        _lineWidth +
        (_colSpacing * 3) +
        (_marginH * 2) +
        1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: height,
        child: DataTable2(
          minWidth: width,
          headingRowHeight: _headingRowHeight,
          dataRowHeight: _dataRowHeight,
          horizontalMargin: _marginH,
          columnSpacing: _colSpacing,
          showCheckboxColumn: false,
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.borderGray),
          ),
          headingTextStyle: AppFonts.captionSemibold.copyWith(
            color: AppColors.textBlack,
          ),
          columns: const [
            DataColumn2(
              label: Center(child: Text('#')),
              numeric: true,
              fixedWidth: _numWidth,
            ),
            DataColumn2(
              label: Center(child: Text(AppStrings.teamRosterColPos)),
              fixedWidth: _posWidth,
            ),
            DataColumn2(label: Text(AppStrings.teamRosterColName)),
            DataColumn2(
              label: Center(child: Text(AppStrings.teamRosterColLine)),
              fixedWidth: _lineWidth,
            ),
          ],
          rows: rows.map((r) {
            void openPlayer() {
              unawaited(
                Navigator.pushNamed(
                  context,
                  AppRoutes.player,
                  arguments: r.playerId,
                ),
              );
            }

            return DataRow2(
              cells: [
                DataCell(Center(child: Text(r.number)), onTap: openPlayer),
                DataCell(Center(child: Text(r.pos)), onTap: openPlayer),
                DataCell(
                  Text(
                    r.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: openPlayer,
                ),
                DataCell(Center(child: Text(r.line)), onTap: openPlayer),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ScheduleRowVm {
  const _ScheduleRowVm({
    required this.gameId,
    required this.dateLabel,
    required this.dateUtc,
    required this.opponent,
    required this.status,
  });

  final int gameId;
  final String dateLabel;
  final DateTime? dateUtc;
  final String opponent;
  final String status;
}

class _ScheduleTable extends StatelessWidget {
  const _ScheduleTable({
    required this.rows,
  });

  final List<_ScheduleRowVm> rows;

  static const _headingRowHeight = 40.0;
  static const _dataRowHeight = 44.0;

  static const _dateWidth = 96.0;
  static const _oppMinWidth = 220.0;
  static const _statusWidth = 96.0;
  static const double _colSpacing = AppSpacing.md;
  static const double _marginH = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final height = _headingRowHeight + (_dataRowHeight * rows.length) + 2;
    const width =
        _dateWidth +
        _oppMinWidth +
        _statusWidth +
        (_colSpacing * 2) +
        (_marginH * 2) +
        1;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: width,
        height: height,
        child: DataTable2(
          minWidth: width,
          headingRowHeight: _headingRowHeight,
          dataRowHeight: _dataRowHeight,
          horizontalMargin: _marginH,
          columnSpacing: _colSpacing,
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.borderGray),
          ),
          headingTextStyle: AppFonts.captionSemibold.copyWith(
            color: AppColors.textBlack,
          ),
          columns: const [
            DataColumn2(
              label: Text(AppStrings.teamScheduleColDate),
              fixedWidth: _dateWidth,
            ),
            DataColumn2(label: Text(AppStrings.teamScheduleColOpponent)),
            DataColumn2(
              label: Center(child: Text(AppStrings.teamScheduleColStatus)),
              fixedWidth: _statusWidth,
              numeric: true,
            ),
          ],
          rows: rows
              .map(
                (r) => DataRow2(
                  cells: [
                    DataCell(Text(r.dateLabel)),
                    DataCell(
                      Text(
                        r.opponent,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DataCell(Center(child: Text(r.status))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _TeamStatsTable extends StatelessWidget {
  const _TeamStatsTable({
    required this.last10,
    required this.gfga,
    required this.record,
  });

  final String last10;
  final String gfga;
  final String record;

  static const _border = BorderSide(color: AppColors.borderGray);

  @override
  Widget build(BuildContext context) {
    Widget labelCell(String text) => Padding(
      padding: Insets.allSm,
      child: Text(
        text,
        style: AppFonts.captionSemibold.copyWith(color: AppColors.textBlack),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    Widget valueCell(String text) => Padding(
      padding: Insets.allSm,
      child: Text(
        text,
        style: AppFonts.bodyRegular,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    return Table(
      border: const TableBorder(
        horizontalInside: _border,
        verticalInside: _border,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          children: [
            labelCell(AppStrings.teamStatsGfGa),
            valueCell(gfga),
          ],
        ),
        TableRow(
          children: [
            labelCell(AppStrings.teamStatsWlOtl),
            valueCell(record),
          ],
        ),
        TableRow(
          children: [
            labelCell(AppStrings.teamStatsLast10),
            valueCell(last10),
          ],
        ),
      ],
    );
  }
}

List<_RosterRowVm> _parseRoster(Object? raw) {
  if (raw is! Map) return const [];

  List<Map<String, Object?>> list(String key) {
    final v = raw[key];
    if (v is! List) return const [];
    return v
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, Object?>.from)
        .toList();
  }

  final players = [
    ...list('forwards'),
    ...list('defensemen'),
    ...list('goalies'),
  ];

  final rows = <_RosterRowVm>[];
  for (final p in players) {
    final playerIdValue = p['id'];
    final playerId = playerIdValue is num ? playerIdValue.toInt() : null;
    if (playerId == null) continue;

    final firstNameMap = p['firstName'];
    final first = (firstNameMap is Map)
        ? (Map<String, Object?>.from(firstNameMap)['default'] as String?)
        : null;
    final lastNameMap = p['lastName'];
    final last = (lastNameMap is Map)
        ? (Map<String, Object?>.from(lastNameMap)['default'] as String?)
        : null;
    final name = [first, last].whereType<String>().join(' ').trim();
    final number = p['sweaterNumber'];
    final pos = (p['positionCode'] as String?) ?? '-';
    rows.add(
      _RosterRowVm(
        number: number is num ? '${number.toInt()}' : '-',
        playerId: playerId,
        pos: pos,
        name: name.isEmpty ? '-' : name,
        line: pos,
      ),
    );
  }

  rows.sort((a, b) => a.number.compareTo(b.number));
  return rows.take(24).toList();
}

List<_ScheduleRowVm> _parseSchedule(
  Object? raw, {
  required String teamAbbrev,
}) {
  if (raw is! Map) return const [];
  final games = raw['games'];
  if (games is! List) return const [];

  final rows = <_ScheduleRowVm>[];
  for (final g in games) {
    if (g is! Map) continue;
    final m = g.cast<String, Object?>();
    final id = m['id'];
    if (id is! num) continue;

    final gameDate = m['gameDate'] as String?;
    final dateLabel = _shortDate(gameDate);
    final dateUtc = _parseGameDateUtc(gameDate, m['startTimeUTC'] as String?);

    final home = m['homeTeam'];
    final away = m['awayTeam'];
    var opponent = AppStrings.notAvailable;
    if (home is Map && away is Map) {
      final homeAbbrev = home['abbrev'];
      final awayAbbrev = away['abbrev'];
      if (homeAbbrev == teamAbbrev) {
        opponent = _teamLabelFromScheduleTeam(away) ??
            ((awayAbbrev is String && awayAbbrev.isNotEmpty)
                ? awayAbbrev
                : AppStrings.notAvailable);
      } else if (awayAbbrev == teamAbbrev) {
        opponent = _teamLabelFromScheduleTeam(home) ??
            ((homeAbbrev is String && homeAbbrev.isNotEmpty)
                ? homeAbbrev
                : AppStrings.notAvailable);
      }
    }

    final awayScore = (away is Map) ? away['score'] : null;
    final homeScore = (home is Map) ? home['score'] : null;
    final status = (awayScore is num && homeScore is num)
        ? '${awayScore.toInt()}-${homeScore.toInt()}'
        : _timeLabel(m['startTimeUTC'] as String?);

    rows.add(
      _ScheduleRowVm(
        gameId: id.toInt(),
        dateLabel: dateLabel,
        dateUtc: dateUtc,
        opponent: opponent,
        status: status,
      ),
    );
  }

  rows.sort((a, b) {
    final ad = a.dateUtc;
    final bd = b.dateUtc;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return ad.compareTo(bd);
  });

  final nowUtc = DateTime.now().toUtc();
  final todayUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

  final past = <_ScheduleRowVm>[];
  final upcoming = <_ScheduleRowVm>[];
  final unknown = <_ScheduleRowVm>[];
  for (final row in rows) {
    final date = row.dateUtc;
    if (date == null) {
      unknown.add(row);
    } else if (date.isBefore(todayUtc)) {
      past.add(row);
    } else {
      upcoming.add(row);
    }
  }

  past.sort((a, b) => (b.dateUtc ?? todayUtc).compareTo(a.dateUtc ?? todayUtc));
  upcoming.sort(
    (a, b) => (a.dateUtc ?? todayUtc).compareTo(b.dateUtc ?? todayUtc),
  );

  const maxRows = 12;
  const preferredPastLimit = 6;

  final selectedPast = past.take(preferredPastLimit).toList();
  final remaining = maxRows - selectedPast.length;
  final selectedUpcoming = upcoming.take(remaining).toList();

  final selected = <_ScheduleRowVm>[
    ...selectedPast,
    ...selectedUpcoming,
    ...unknown,
  ]
    ..removeWhere((e) => e.dateUtc == null)
    ..sort((a, b) {
      final ad = a.dateUtc;
      final bd = b.dateUtc;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });

  final result = <_ScheduleRowVm>[...selected, ...unknown];
  return result.take(maxRows).toList();
}

DateTime? _parseGameDateUtc(String? gameDate, String? startTimeUtc) {
  if (gameDate != null && gameDate.length >= 10) {
    final parts = gameDate.split('-');
    if (parts.length == 3) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year != null && month != null && day != null) {
        return DateTime.utc(year, month, day);
      }
    }
  }

  return DateTime.tryParse(startTimeUtc ?? '')?.toUtc();
}

String? _teamLabelFromScheduleTeam(Object? team) {
  if (team is! Map) return null;

  final commonName = team['commonName'];
  final common = commonName is Map
      ? (Map<String, Object?>.from(commonName)['default'] as String?)
      : null;

  final placeName = team['placeName'];
  final place = placeName is Map
      ? (Map<String, Object?>.from(placeName)['default'] as String?)
      : null;

  final full =
      [place, common].whereType<String>().where((s) => s.isNotEmpty).join(' ');
  return full.isEmpty ? null : full;
}

String _shortDate(String? yyyyMmDd) {
  if (yyyyMmDd == null || yyyyMmDd.length < 10) return AppStrings.notAvailable;
  final parts = yyyyMmDd.split('-');
  if (parts.length != 3) return AppStrings.notAvailable;
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (month == null || day == null) return AppStrings.notAvailable;

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > 12) return AppStrings.notAvailable;
  return '${months[month - 1]} $day';
}

String _timeLabel(String? startTimeUtc) {
  final dt = DateTime.tryParse(startTimeUtc ?? '')?.toLocal();
  if (dt == null) return AppStrings.notAvailable;
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $amPm';
}


