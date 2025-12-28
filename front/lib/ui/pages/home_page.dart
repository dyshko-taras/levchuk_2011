import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ice_line_tracker/constants/app_images.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/data/models/nhl_schedule_response.dart';
import 'package:ice_line_tracker/providers/home_provider.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_fonts.dart';
import 'package:ice_line_tracker/ui/widgets/common/game_card.dart';
import 'package:ice_line_tracker/utils/async_state.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

enum HomeListFilter {
  liveNow,
  upcoming,
  final_,
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeListFilter _filter = HomeListFilter.liveNow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final home = context.read<HomeProvider>();
      if (home.state is AsyncEmpty<NhlScheduleResponse>) {
        unawaited(home.loadDefault());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final state = home.state;

    final data = state.valueOrNull;
    final activeDate = home.activeDateYyyyMmDd;
    final selectedDay =
        DateTime.tryParse(activeDate ?? '')?.toLocal() ?? DateTime.now();

    final days = data?.gameWeek ?? const <NhlGameDay>[];
    NhlGameDay? day;
    for (final d in days) {
      if (d.date == activeDate) {
        day = d;
        break;
      }
    }
    day ??= days.isNotEmpty ? days.first : null;

    final games = day?.games ?? const <NhlScheduledGame>[];
    final filteredGames = games.where((g) {
      final status = gameStatusForGame(g);
      return switch (_filter) {
        HomeListFilter.liveNow => status == GameStatus.live,
        HomeListFilter.upcoming => status == GameStatus.upcoming,
        HomeListFilter.final_ => status == GameStatus.final_,
      };
    }).toList();

    return RefreshIndicator(
      onRefresh: home.refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.sidePadding,
          AppSpacing.md,
          AppSizes.sidePadding,
          AppSpacing.x2l,
        ),
        children: [
          if (home.showingCached && data != null) const _OfflineBanner(),
          _DateRibbon(
            selectedDay: selectedDay,
            onSelected: (d) => unawaited(home.loadByDate(_toYyyyMmDd(d))),
          ),
          Gaps.hXl,
          _FilterSegmented(
            value: _filter,
            onChanged: (v) => setState(() => _filter = v),
          ),
          Gaps.hXl,
          if (state.isLoading && data == null)
            const Center(
              child: Padding(
                padding: Insets.vXl,
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.hasError && data == null)
            Center(
              child: Padding(
                padding: Insets.vXl,
                child: Column(
                  children: [
                    const Text(AppStrings.splashInitFailed),
                    Gaps.hLg,
                    ElevatedButton(
                      onPressed: () => unawaited(home.refresh()),
                      child: const Text(AppStrings.refresh),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredGames.isEmpty)
            const Padding(
              padding: Insets.vXl,
              child: Center(child: Text('No games')),
            )
          else
            ...filteredGames
                .map((g) => GameCard(game: g))
                .expand(
                  (w) => [w, Gaps.hXl],
                ),

          Gaps.h2Xl,
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;
  static const Color _shadowColor = Color(0x40000000);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.mdValue),
                topRight: Radius.circular(AppRadius.mdValue),
              ),
              child: Image.asset(AppImages.offlineIllustration),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                AppStrings.offlineCachedScores,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSegmented extends StatelessWidget {
  const _FilterSegmented({
    required this.value,
    required this.onChanged,
  });

  final HomeListFilter value;
  final ValueChanged<HomeListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.segmentedControlHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceGray,
        borderRadius: AppRadius.md,
        border: Border.all(color: const Color(0x33000000), width: 0.66),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 1.32),
            blurRadius: 1.32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.md,
        child: Row(
          children: [
            _FilterChip(
              label: AppStrings.liveNow,
              isSelected: value == HomeListFilter.liveNow,
              onTap: () => onChanged(HomeListFilter.liveNow),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.mdValue),
                bottomLeft: Radius.circular(AppRadius.mdValue),
              ),
            ),
            _FilterChip(
              label: AppStrings.upcoming,
              isSelected: value == HomeListFilter.upcoming,
              onTap: () => onChanged(HomeListFilter.upcoming),
            ),
            _FilterChip(
              label: AppStrings.final_,
              isSelected: value == HomeListFilter.final_,
              onTap: () => onChanged(HomeListFilter.final_),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.mdValue),
                bottomRight: Radius.circular(AppRadius.mdValue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.borderRadius,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final BorderRadius? borderRadius;

  static const double _paddingV = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryRed : Colors.transparent,
              borderRadius: borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: _paddingV),
              child: Center(
                child: Text(
                  label,
                  style: AppFonts.bodySemibold.copyWith(
                    color: isSelected ? Colors.white : AppColors.textBlack,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateRibbon extends StatelessWidget {
  const _DateRibbon({
    required this.selectedDay,
    required this.onSelected,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelected;

  static const double _borderWidth = 0.66;
  static const Color _borderColor = Color(0x33000000);
  static const Color _shadowColor = Color(0x40000000);
  static const double _shadowOffsetY = 1.32;
  static const double _shadowBlurRadius = 1.32;

  static const int _yearsBack = 1;
  static const int _yearsForward = 1;

  static const double _cellMarginH = AppSpacing.xs;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final firstDay = DateTime(today.year - _yearsBack);
    final lastDay = DateTime(today.year + _yearsForward, 12, 31);

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
        child: TableCalendar<void>(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: selectedDay,
          calendarFormat: CalendarFormat.week,
          availableCalendarFormats: const {CalendarFormat.week: 'week'},
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerVisible: false,
          daysOfWeekVisible: false,
          selectedDayPredicate: (day) => isSameDay(day, selectedDay),
          onDaySelected: (day, focusedDay) => onSelected(day),
          rowHeight: AppSizes.segmentedControlHeight,
          calendarStyle: const CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: EdgeInsets.symmetric(horizontal: _cellMarginH),
          ),
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) =>
                _buildCell(day, selected: false),
            todayBuilder: (context, day, focusedDay) =>
                _buildCell(day, selected: false),
            selectedBuilder: (context, day, focusedDay) =>
                _buildCell(day, selected: true),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(DateTime day, {required bool selected}) {
    final textColor = selected ? Colors.white : AppColors.textBlack;
    final background = selected ? AppColors.primaryRed : Colors.transparent;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.md,
      ),
      padding: Insets.hMd,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _dowShort(day.weekday),
            style: TextStyle(
              fontSize: AppFonts.captionSemibold.fontSize,
              fontWeight: AppFonts.captionSemibold.fontWeight,
              color: textColor,
            ),
          ),
          Text(
            '${day.day}',
            style: TextStyle(
              fontSize: AppFonts.bodySemibold.fontSize,
              fontWeight: AppFonts.bodySemibold.fontWeight,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  static String _dowShort(int weekday) => switch (weekday) {
    DateTime.monday => 'Mon',
    DateTime.tuesday => 'Tue',
    DateTime.wednesday => 'Wed',
    DateTime.thursday => 'Thu',
    DateTime.friday => 'Fri',
    DateTime.saturday => 'Sat',
    DateTime.sunday => 'Sun',
    _ => '',
  };
}

String _toYyyyMmDd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
