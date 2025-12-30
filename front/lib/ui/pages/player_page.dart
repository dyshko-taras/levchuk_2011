import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/providers/player_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  int? _playerId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arg = ModalRoute.of(context)?.settings.arguments;
    final playerId = switch (arg) {
      int() => arg,
      _ => null,
    };
    if (playerId == null || playerId == _playerId) return;
    _playerId = playerId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(context.read<PlayerProvider>().loadNow(playerId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerId = _playerId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(AppStrings.playerTitle),
        actions: [
          IconButton(
            onPressed: () => unawaited(_shareCurrent(context)),
            icon: SvgPicture.asset(
              AppIcons.share,
              width: AppSizes.iconMd,
              height: AppSizes.iconMd,
              colorFilter: const ColorFilter.mode(
                AppColors.textBlack,
                BlendMode.srcIn,
              ),
            ),
            tooltip: AppStrings.playerShare,
          ),
        ],
      ),
      body: playerId == null
          ? const Center(child: Text(AppStrings.notAvailable))
          : Consumer<PlayerProvider>(
              builder: (context, provider, _) {
                final landingState = provider.landingState;
                final gameLogState = provider.gameLogState;
                final gameLogLoading =
                    gameLogState.isLoading && gameLogState.valueOrNull == null;

                if (landingState.isLoading &&
                    landingState.valueOrNull == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (landingState.hasError && landingState.valueOrNull == null) {
                  return const Center(child: Text(AppStrings.splashInitFailed));
                }

                final landing = _parsePlayerLanding(landingState.valueOrNull);
                final gameLog = _parseGameLog(gameLogState.valueOrNull);

                final sog = landing.isGoalie
                    ? null
                    : (gameLogLoading
                        ? null
                        : gameLog.fold<int>(
                            0,
                            (sum, e) => sum + (e.shots ?? 0),
                          ));

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: Insets.allLg,
                        children: [
                          _PlayerHeaderCard(landing: landing),
                          Gaps.hLg,
                          const Text(
                            AppStrings.playerSeasonStats,
                            style: AppFonts.heading2,
                          ),
                          Gaps.hSm,
                          _CardContainer(
                            child: landing.isGoalie
                                ? const _GoalieSeasonStatsTable()
                                : _SkaterSeasonStatsTable(
                                    featured: landing.featuredSkater,
                                    sog: sog,
                                    avgToi: landing.avgToi,
                                  ),
                          ),
                          Gaps.hLg,
                          const Text(
                            AppStrings.playerPointsByGame,
                            style: AppFonts.heading2,
                          ),
                          Gaps.hSm,
                          _CardContainer(
                            child: SizedBox(
                              height: 210,
                              child: _PointsByGameChart(
                                points: gameLog,
                                isLoading: gameLogLoading,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Gaps.hLg,
                  ],
                );
              },
            ),
    );
  }

  Future<void> _shareCurrent(BuildContext context) async {
    final provider = context.read<PlayerProvider>();
    final landing = _parsePlayerLanding(provider.landingState.valueOrNull);
    final text = landing.shareText;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
  }
}

class _CardContainer extends StatelessWidget {
  const _CardContainer({required this.child});

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

class _PlayerHeaderCard extends StatelessWidget {
  const _PlayerHeaderCard({required this.landing});

  final _PlayerLandingVm landing;

  @override
  Widget build(BuildContext context) {
    final subtitle = landing.subtitleLine;
    final meta = landing.metaLine;

    return _CardContainer(
      child: Padding(
        padding: Insets.allLg,
        child: Row(
          children: [
            _Avatar(url: landing.headshotUrl),
            Gaps.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    landing.displayName,
                    style: AppFonts.heading2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    Gaps.hXs,
                    Text(
                      subtitle,
                      style: AppFonts.bodyRegular,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (meta != null) ...[
                    Gaps.hXs,
                    Text(
                      meta,
                      style: AppFonts.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = url;

    return ClipOval(
      child: SizedBox(
        width: 80,
        height: 80,
        child: u == null || u.isEmpty
            ? const ColoredBox(
                color: AppColors.borderGray,
                child: Icon(Icons.person, size: AppSizes.iconLg),
              )
            : Image.network(
                u,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const ColoredBox(
                    color: AppColors.borderGray,
                    child: Icon(Icons.person, size: AppSizes.iconLg),
                  );
                },
              ),
      ),
    );
  }
}

class _SkaterSeasonStatsTable extends StatelessWidget {
  const _SkaterSeasonStatsTable({
    required this.featured,
    required this.sog,
    required this.avgToi,
  });

  final _SkaterFeaturedStatsVm featured;
  final int? sog;
  final String? avgToi;

  @override
  Widget build(BuildContext context) {
    final headers = <String>[
      AppStrings.statsGp,
      AppStrings.statsG,
      AppStrings.statsA,
      AppStrings.statsP,
      AppStrings.statsPlusMinus,
      AppStrings.statsPim,
      AppStrings.statsSog,
      AppStrings.statsToi,
    ];

    final values = <String>[
      featured.gamesPlayed?.toString() ?? AppStrings.notAvailable,
      featured.goals?.toString() ?? AppStrings.notAvailable,
      featured.assists?.toString() ?? AppStrings.notAvailable,
      featured.points?.toString() ?? AppStrings.notAvailable,
      _formatPlusMinus(featured.plusMinus) ?? AppStrings.notAvailable,
      featured.pim?.toString() ?? AppStrings.notAvailable,
      sog?.toString() ?? AppStrings.notAvailable,
      avgToi ?? AppStrings.notAvailable,
    ];

    return _OneRowStatsTable(headers: headers, values: values);
  }
}

class _GoalieSeasonStatsTable extends StatelessWidget {
  const _GoalieSeasonStatsTable();

  @override
  Widget build(BuildContext context) {
    final headers = <String>[
      AppStrings.statsGs,
      AppStrings.statsW,
      AppStrings.statsL,
      AppStrings.statsOtl,
      AppStrings.statsSvPct,
      AppStrings.statsGaa,
      AppStrings.statsSo,
    ];

    return _OneRowStatsTable(
      headers: headers,
      values: List<String>.filled(headers.length, AppStrings.notAvailable),
    );
  }
}

class _OneRowStatsTable extends StatelessWidget {
  const _OneRowStatsTable({
    required this.headers,
    required this.values,
  });

  final List<String> headers;
  final List<String> values;

  static const _border = BorderSide(color: AppColors.borderGray);

  @override
  Widget build(BuildContext context) {
    const colWidth = FixedColumnWidth(56);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: const TableBorder(horizontalInside: _border),
        columnWidths: {
          for (var i = 0; i < headers.length; i++) i: colWidth,
        },
        children: [
          TableRow(
            children: headers
                .map(
                  (h) => Padding(
                    padding: Insets.allSm,
                    child: Text(
                      h,
                      style: AppFonts.captionSemibold.copyWith(
                        color: AppColors.textBlack,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
          TableRow(
            children: values
                .map(
                  (v) => Padding(
                    padding: Insets.allSm,
                    child: Text(
                      v,
                      style: AppFonts.bodyRegular,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _PointsByGameChart extends StatelessWidget {
  const _PointsByGameChart({
    required this.points,
    required this.isLoading,
  });

  final List<_GameLogVm> points;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (points.isEmpty) {
      return const Center(child: Text(AppStrings.notAvailable));
    }

    final sorted = [...points]
      ..sort((a, b) => a.dateUtc.compareTo(b.dateUtc));
    final spots = <FlSpot>[
      for (var i = 0; i < sorted.length; i++)
        FlSpot(i.toDouble(), (sorted[i].points ?? 0).toDouble()),
    ];

    return Padding(
      padding: Insets.allMd,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                final idx = s.x.toInt();
                if (idx < 0 || idx >= sorted.length) return null;
                final g = sorted[idx];
                final date = _formatShortIsoDate(g.gameDateIso);
                final label = <String?>[
                  date,
                  g.opponentAbbrev,
                ].whereType<String>().where((s) => s.trim().isNotEmpty).join(
                      ' • ',
                    );
                final value = '${g.points ?? 0} P';
                return LineTooltipItem(
                  '$label\n$value',
                  AppFonts.captionSemibold.copyWith(color: Colors.white),
                );
              }).whereType<LineTooltipItem>().toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.liveCyan,
              barWidth: 2.2,
              dotData: FlDotData(
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 3.4,
                  color: AppColors.liveCyan,
                  strokeWidth: 1.2,
                  strokeColor: Colors.black,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.liveCyan.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkaterFeaturedStatsVm {
  const _SkaterFeaturedStatsVm({
    required this.gamesPlayed,
    required this.goals,
    required this.assists,
    required this.points,
    required this.plusMinus,
    required this.pim,
  });

  final int? gamesPlayed;
  final int? goals;
  final int? assists;
  final int? points;
  final int? plusMinus;
  final int? pim;
}

class _PlayerLandingVm {
  const _PlayerLandingVm({
    required this.displayName,
    required this.isGoalie,
    required this.sweaterNumber,
    required this.position,
    required this.shootsCatches,
    required this.birthDateIso,
    required this.country,
    required this.headshotUrl,
    required this.featuredSkater,
    required this.avgToi,
  });

  final String displayName;
  final bool isGoalie;
  final int? sweaterNumber;
  final String? position;
  final String? shootsCatches;
  final String? birthDateIso;
  final String? country;
  final String? headshotUrl;
  final _SkaterFeaturedStatsVm featuredSkater;
  final String? avgToi;

  String? get subtitleLine {
    final parts = <String>[];

    final number = sweaterNumber;
    if (number != null) parts.add('#$number');

    final pos = position;
    if (pos != null && pos.trim().isNotEmpty) parts.add(pos);

    final shoots = shootsCatches;
    if (shoots != null && shoots.trim().isNotEmpty) {
      parts.add('${AppStrings.playerShootsLabel} $shoots');
    }

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String? get metaLine {
    final formattedDob = _formatLongIsoDate(birthDateIso);
    final parts = <String>[];

    final countryValue = country;
    if (countryValue != null && countryValue.trim().isNotEmpty) {
      parts.add(countryValue);
    }
    if (formattedDob != null) parts.add(formattedDob);

    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String? get shareText {
    if (displayName.trim().isEmpty) return null;
    final details = subtitleLine;
    if (details == null) return displayName;
    return '$displayName\n$details';
  }
}

class _GameLogVm {
  const _GameLogVm({
    required this.gameId,
    required this.gameDateIso,
    required this.dateUtc,
    required this.goals,
    required this.assists,
    required this.points,
    required this.shots,
    required this.toi,
    required this.opponentAbbrev,
  });

  final int? gameId;
  final String? gameDateIso;
  final DateTime dateUtc;
  final int? goals;
  final int? assists;
  final int? points;
  final int? shots;
  final String? toi;
  final String? opponentAbbrev;
}

_PlayerLandingVm _parsePlayerLanding(Object? raw) {
  if (raw is! Map) {
    return const _PlayerLandingVm(
      displayName: AppStrings.playerTitle,
      isGoalie: false,
      sweaterNumber: null,
      position: null,
      shootsCatches: null,
      birthDateIso: null,
      country: null,
      headshotUrl: null,
      featuredSkater: _SkaterFeaturedStatsVm(
        gamesPlayed: null,
        goals: null,
        assists: null,
        points: null,
        plusMinus: null,
        pim: null,
      ),
      avgToi: null,
    );
  }

  final m = raw.cast<String, Object?>();

  String? readDefaultText(Object? v) {
    if (v is! Map) return null;
    return Map<String, Object?>.from(v)['default'] as String?;
  }

  final first = readDefaultText(m['firstName']);
  final last = readDefaultText(m['lastName']);
  final name = [first, last].whereType<String>().join(' ').trim();

  final sweaterNumber = m['sweaterNumber'];
  final number = sweaterNumber is num ? sweaterNumber.toInt() : null;

  final position = (m['position'] as String?)?.trim();
  final shootsCatches = (m['shootsCatches'] as String?)?.trim();

  final birthDate = (m['birthDate'] as String?)?.trim();
  final country =
      (m['birthCountry'] as String?)?.trim() ??
      (m['country'] as String?)?.trim();

  final headshotUrl = (m['headshot'] as String?)?.trim();

  final featured = _parseFeaturedSkaterStats(m['featuredStats']);
  final avgToi = _parseAvgToi(m['careerTotals']);

  final isGoalie = position == 'G';

  return _PlayerLandingVm(
    displayName: name.isEmpty ? AppStrings.playerTitle : name,
    isGoalie: isGoalie,
    sweaterNumber: number,
    position: position,
    shootsCatches: shootsCatches,
    birthDateIso: birthDate,
    country: country,
    headshotUrl: headshotUrl,
    featuredSkater: featured,
    avgToi: avgToi,
  );
}

_SkaterFeaturedStatsVm _parseFeaturedSkaterStats(Object? featuredStats) {
  if (featuredStats is! Map) {
    return const _SkaterFeaturedStatsVm(
      gamesPlayed: null,
      goals: null,
      assists: null,
      points: null,
      plusMinus: null,
      pim: null,
    );
  }

  final m = featuredStats.cast<String, Object?>();
  final regularSeason = m['regularSeason'];
  if (regularSeason is! Map) {
    return const _SkaterFeaturedStatsVm(
      gamesPlayed: null,
      goals: null,
      assists: null,
      points: null,
      plusMinus: null,
      pim: null,
    );
  }

  final regular = regularSeason.cast<String, Object?>();
  final subSeason = regular['subSeason'];
  if (subSeason is! Map) {
    return const _SkaterFeaturedStatsVm(
      gamesPlayed: null,
      goals: null,
      assists: null,
      points: null,
      plusMinus: null,
      pim: null,
    );
  }

  final s = subSeason.cast<String, Object?>();

  int? asInt(Object? v) => v is num ? v.toInt() : null;

  return _SkaterFeaturedStatsVm(
    gamesPlayed: asInt(s['gamesPlayed']),
    goals: asInt(s['goals']),
    assists: asInt(s['assists']),
    points: asInt(s['points']),
    plusMinus: asInt(s['plusMinus']),
    pim: asInt(s['pim']),
  );
}

String? _parseAvgToi(Object? careerTotals) {
  if (careerTotals is! Map) return null;
  final m = careerTotals.cast<String, Object?>();
  final regularSeason = m['regularSeason'];
  if (regularSeason is! Map) return null;
  final regular = regularSeason.cast<String, Object?>();
  return (regular['avgToi'] as String?)?.trim();
}

List<_GameLogVm> _parseGameLog(Object? raw) {
  if (raw is! Map) return const [];
  final m = raw.cast<String, Object?>();
  final list = m['gameLog'];
  if (list is! List) return const [];

  int? asInt(Object? v) => v is num ? v.toInt() : null;

  DateTime? dateFromIso(String? iso) {
    if (iso == null || iso.length < 10) return null;
    final parts = iso.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  final result = <_GameLogVm>[];
  for (final item in list) {
    if (item is! Map) continue;
    final g = item.cast<String, Object?>();
    final iso = (g['gameDate'] as String?)?.trim();
    final date = dateFromIso(iso);
    if (date == null) continue;

    result.add(
      _GameLogVm(
        gameId: asInt(g['gameId']),
        gameDateIso: iso,
        dateUtc: date,
        goals: asInt(g['goals']),
        assists: asInt(g['assists']),
        points: asInt(g['points']),
        shots: asInt(g['shots']),
        toi: (g['toi'] as String?)?.trim(),
        opponentAbbrev: (g['opponentAbbrev'] as String?)?.trim(),
      ),
    );
  }

  return result;
}

String? _formatPlusMinus(int? value) {
  if (value == null) return null;
  if (value > 0) return '+$value';
  return value.toString();
}

String? _formatLongIsoDate(String? iso) {
  if (iso == null || iso.length < 10) return null;
  final parts = iso.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;

  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final idx = month - 1;
  if (idx < 0 || idx >= months.length) return null;
  return '${months[idx]} $day, $year';
}

String? _formatShortIsoDate(String? iso) {
  if (iso == null || iso.length < 10) return null;
  final parts = iso.split('-');
  if (parts.length != 3) return null;
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (month == null || day == null) return null;

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

  final idx = month - 1;
  if (idx < 0 || idx >= months.length) return null;
  return '${months[idx]} $day';
}
