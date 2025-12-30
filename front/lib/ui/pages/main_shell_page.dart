import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ice_line_tracker/constants/app_icons.dart';
import 'package:ice_line_tracker/constants/app_radius.dart';
import 'package:ice_line_tracker/constants/app_routes.dart';
import 'package:ice_line_tracker/constants/app_sizes.dart';
import 'package:ice_line_tracker/constants/app_spacing.dart';
import 'package:ice_line_tracker/constants/app_strings.dart';
import 'package:ice_line_tracker/enums/main_tab.dart';
import 'package:ice_line_tracker/providers/home_provider.dart';
import 'package:ice_line_tracker/providers/shell_navigation_provider.dart';
import 'package:ice_line_tracker/providers/standings_provider.dart';
import 'package:ice_line_tracker/ui/pages/compare_page.dart';
import 'package:ice_line_tracker/ui/pages/favorites_page.dart';
import 'package:ice_line_tracker/ui/pages/home_page.dart';
import 'package:ice_line_tracker/ui/pages/standings_page.dart';
import 'package:ice_line_tracker/ui/theme/app_colors.dart';
import 'package:ice_line_tracker/ui/theme/app_gradients.dart';
import 'package:provider/provider.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({
    required this.initialTab,
    super.key,
  });

  final MainTab initialTab;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShellNavigationProvider>().setInitialTab(widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    const tabs = <_TabSpec>[
      _TabSpec(
        iconPath: AppIcons.navHome,
        tab: MainTab.home,
      ),
      _TabSpec(
        iconPath: AppIcons.navStandings,
        tab: MainTab.standings,
      ),
      _TabSpec(
        iconPath: AppIcons.navCompare,
        tab: MainTab.compare,
      ),
      _TabSpec(
        iconPath: AppIcons.navFavorites,
        tab: MainTab.favorites,
      ),
      _TabSpec(
        iconPath: AppIcons.navPredictions,
        tab: MainTab.predictions,
      ),
    ];

    final shell = context.watch<ShellNavigationProvider>();
    final activeTab = shell.activeTab;

    return Scaffold(
      extendBody: true,
      appBar: _buildAppBar(context, activeTab),
      body: IndexedStack(
        index: shell.activeIndex,
        children: const [
          HomePage(),
          StandingsPage(),
          ComparePage(),
          FavoritesPage(),
          Center(child: Text(AppStrings.gameInsightLabTitle)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: AppSpacing.lg,
        ),
        child: Container(
          height: AppSizes.bottomNavHeight,
          decoration: BoxDecoration(
            gradient: AppGradients.bottomNav,
            borderRadius: BorderRadius.circular(AppRadius.bottomNavValue),
            border: Border.all(
              color: const Color(0x33000000),
              width: 0.66,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 1.32),
                blurRadius: 1.32,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.bottomNavValue),
            child: AnimatedBottomNavigationBar.builder(
              itemCount: tabs.length,
              tabBuilder: (index, isActive) {
                final iconColor = isActive
                    ? AppColors.primaryRed
                    : AppColors.textGray;

                return Center(
                  child: Material(
                    color: AppColors.borderGray,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: const Color(0x33000000),
                    child: SizedBox(
                      width: AppSizes.bottomNavItemDiameter,
                      height: AppSizes.bottomNavItemDiameter,
                      child: Center(
                        child: SvgPicture.asset(
                          tabs[index].iconPath,
                          width: AppSizes.iconSm,
                          height: AppSizes.iconSm,
                          colorFilter: ColorFilter.mode(
                            iconColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              activeIndex: shell.activeIndex,
              onTap: (index) {
                shell.setTab(tabs[index].tab);
              },
              height: AppSizes.bottomNavHeight,
              gapLocation: GapLocation.none,
              backgroundColor: Colors.transparent,
              elevation: 0,
              splashColor: Colors.transparent,
              splashRadius: 0,
              scaleFactor: 0,
              safeAreaValues: const SafeAreaValues(
                left: false,
                top: false,
                right: false,
                bottom: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

PreferredSizeWidget _buildAppBar(BuildContext context, MainTab activeTab) {
  return switch (activeTab) {
    MainTab.home => const _HomeAppBar(),
    MainTab.standings => AppBar(
      automaticallyImplyLeading: false,
      title: const Text(AppStrings.standingsTitle),
      actions: [
        IconButton(
          onPressed: () {
            unawaited(context.read<StandingsProvider>().refresh());
          },
          tooltip: AppStrings.refresh,
          icon: SvgPicture.asset(
            AppIcons.refresh,
            colorFilter: const ColorFilter.mode(
              AppColors.textBlack,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    ),
    MainTab.compare => AppBar(
      automaticallyImplyLeading: false,
      title: const Text(AppStrings.teamCompareTitle),
    ),
    MainTab.favorites => AppBar(
      automaticallyImplyLeading: false,
      title: const Text(AppStrings.favoritesTitle),
    ),
    MainTab.predictions => AppBar(
      automaticallyImplyLeading: false,
      title: const Text(AppStrings.gameInsightLabTitle),
    ),
  };
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  static const int _calendarYearsBack = 1;
  static const int _calendarYearsForward = 1;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(AppStrings.liveScoresTitle),
      actions: [
        IconButton(
          onPressed: () => unawaited(_openCalendar(context)),
          icon: SvgPicture.asset(
            AppIcons.calendar,
            colorFilter: const ColorFilter.mode(
              AppColors.textBlack,
              BlendMode.srcIn,
            ),
          ),
          tooltip: AppStrings.openCalendar,
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          icon: SvgPicture.asset(
            AppIcons.settings,
            colorFilter: const ColorFilter.mode(
              AppColors.textBlack,
              BlendMode.srcIn,
            ),
          ),
          tooltip: AppStrings.openSettings,
        ),
      ],
    );
  }

  Future<void> _openCalendar(BuildContext context) async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse(
          context.read<HomeProvider>().activeDateYyyyMmDd ?? '',
        ) ??
        now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - _calendarYearsBack),
      lastDate: DateTime(now.year + _calendarYearsForward),
    );
    if (picked == null || !context.mounted) return;

    final yyyy = picked.year.toString().padLeft(4, '0');
    final mm = picked.month.toString().padLeft(2, '0');
    final dd = picked.day.toString().padLeft(2, '0');
    await context.read<HomeProvider>().loadByDate('$yyyy-$mm-$dd');
  }
}

class _TabSpec {
  const _TabSpec({
    required this.iconPath,
    required this.tab,
  });

  final String iconPath;
  final MainTab tab;
}
